#%%
import numpy as np
import pandas as pd
import nltk
import sklearn 
import string
import re # helps you filter urls
from sklearn.metrics import accuracy_score
from nltk import pos_tag
from nltk.tokenize import sent_tokenize, word_tokenize
from collections import Counter
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression

# Convert part of speech tag from nltk.pos_tag to word net compatible format
# Simple mapping based on first letter of return tag to make grading consistent
# Everything else will be considered noun 'n'
posMapping = {
# "First_Letter by nltk.pos_tag":"POS_for_lemmatizer"
    "N":'n',
    "V":'v',
    "J":'a',
    "R":'r'
}

#%%
def process(text, lemmatizer=nltk.stem.wordnet.WordNetLemmatizer()):
    """ Normalizes case and handles punctuation
    Inputs:
        text: str: raw text
        lemmatizer: an instance of a class implementing the lemmatize() method
                    (the default argument is of type nltk.stem.wordnet.WordNetLemmatizer)
    Outputs:
        list(str): tokenized text
    """
    text = re.sub(r'http\S+', '', text)
                 
    emoji_pattern = re.compile("["
        u"\U0001F600-\U0001F64F"  # emoticons
        u"\U0001F300-\U0001F5FF"  # symbols & pictographs
        u"\U0001F680-\U0001F6FF"  # transport & map symbols
        u"\U0001F1E0-\U0001F1FF"  # flags (iOS)
        u"\U00002702-\U000027B0"  # dingbats
        u"\U000024C2-\U0001F251"  # misc
                           "]+", flags=re.UNICODE)
    text = emoji_pattern.sub(r'', text)

    text = text.replace("'s", "")
    text = text.replace("'", "")

    text = re.sub(r'[' + string.punctuation + ']+', ' ', text).strip()
    
    text = text.lower()
    tokens = word_tokenize(text)

    tagged_tokens = nltk.pos_tag(tokens)
    lemma_tokens = [
        lemmatizer.lemmatize(word, get_wordnet_pos(pos))
        for (word, pos) in tagged_tokens
    ]

    return lemma_tokens
    
#%%
def get_wordnet_pos(treebank_tag): #no need to change this function - used to tag tokens for context specification and then for lemmatization
    if treebank_tag.startswith('J'):
        return nltk.corpus.wordnet.ADJ
    elif treebank_tag.startswith('V'):
        return nltk.corpus.wordnet.VERB
    elif treebank_tag.startswith('R'):
        return nltk.corpus.wordnet.ADV
    else:
        return nltk.corpus.wordnet.NOUN
        
#%%
def process_all(df, lemmatizer=nltk.stem.wordnet.WordNetLemmatizer()):
    """ process all text in the dataframe using process function.
    Inputs
        df: pd.DataFrame: dataframe containing a column 'text' loaded from the CSV file
        lemmatizer: an instance of a class implementing the lemmatize() method
                    (the default argument is of type nltk.stem.wordnet.WordNetLemmatizer)
    Outputs
        pd.DataFrame: dataframe in which the values of text column have been changed from str to list(str),
                        the output from process_text() function. Other columns are unaffected.
    """
    processed_df = df.copy()

    def safe_process(x):
        if isinstance(x, str):
            return process(x, lemmatizer=lemmatizer)
        return []

    processed_df["Content"] = processed_df["Content"].apply(safe_process)

    return processed_df

#%%
def identity(x):
    return x

#%%
def create_features(processed_tweets, stop_words):
    """ creates the feature matrix using the processed tweet text
    Inputs:
        processed_tweets: pd.DataFrame: processed tweets read from train/test csv file, containing the column 'text'
        stop_words: list(str): stop_words by nltk stopwords (after processing)
    Outputs:
        sklearn.feature_extraction.text.TfidfVectorizer: the TfidfVectorizer object used
            we need this to tranform test tweets in the same way as train tweets
        scipy.sparse.csr.csr_matrix: sparse bag-of-words TF-IDF feature matrix
    """
    vectorizer = TfidfVectorizer(
        tokenizer=identity,
        preprocessor=identity,
        token_pattern=None,
        lowercase=False, 
        stop_words=stop_words,
        min_df=2
    )

    X = vectorizer.fit_transform(processed_tweets)

    return vectorizer, X

#%%
def create_labels(processed_tweets):
    """ creates the class labels from handle
    Inputs:
        processed_tweets: pd.DataFrame: tweets read from train file, containing the column 'handle'
    Outputs:
        numpy.ndarray(int): dense binary numpy array of class labels
    """
    label_map = {
        "Zohran Mamdani": 0,
        "Curtis Sliwa": 1,
        "Andrew Cuomo": 2
    }
    
    y = processed_tweets["handle"].map(label_map)
    
    return y.to_numpy(dtype=int)
    
#%%
class MajorityLabelClassifier():
    """
    A classifier that predicts the mode of training labels
    """
    def __init__(self):
        """
        Initialize your parameter here
        """
        self.majority_label = None
        
    def fit(self, X, y):
        """
        Implement fit by taking training data X and their labels y and finding the mode of y
        i.e. store your learned parameter
        """
        counts = Counter(y)
        self.majority_label = counts.most_common(1)[0][0]
        return self
    
    def predict(self, X):
        """
        Implement to give the mode of training labels as a prediction for each data instance in X
        return labels
        """
        num_samples = X.shape[0]
        return np.full(num_samples, self.majority_label, dtype=int)

#%%
def learn_classifier(X_train, y_train, penalty):
    """ learns a classifier from the input features and labels using the penalty function supplied
    Inputs:
        X_train: scipy.sparse.csr.csr_matrix: sparse matrix of features, output of create_features()
        y_train: numpy.ndarray(int): dense binary vector of class labels, output of create_labels()
        penalty: str: penalty function to be used with classifier. [none|l2|l1|elasticnet]
    Outputs:
        sklearn.linear_model.LogisticRegression: classifier learnt from data
    """
    
    if penalty == "none":
        classifier = LogisticRegression(
            penalty=None,
            solver="lbfgs",
            max_iter=1000
        )
        
    elif penalty == "l2":
        classifier = LogisticRegression(
            penalty="l2",
            solver="lbfgs",
            max_iter=1000
        )
        
    elif penalty == "l1":
        classifier = LogisticRegression(
            penalty="l1",
            solver="liblinear",
            max_iter=1000
        )
        
    elif penalty == "elasticnet":
        classifier = LogisticRegression(
            penalty="elasticnet",
            solver="saga",
            l1_ratio=0.5,  
            max_iter=1000
        )
        
    else:
        raise ValueError(f"Invalid penalty type: {penalty}")
    
    classifier.fit(X_train, y_train)
    return classifier

#%%
def evaluate_classifier(classifier, X_validation, y_validation):
    """ evaluates a classifier based on a supplied validation data
    Inputs:
        classifier: sklearn.linear_model.LogisticRegression: classifer to evaluate
        X_validation: scipy.sparse.csr.csr_matrix: sparse matrix of features
        y_validation: numpy.ndarray(int): dense binary vector of class labels
    Outputs:
        double: accuracy of classifier on the validation data
    """
    y_prediction = classifier.predict(X_validation)
    
    return accuracy_score(y_validation, y_prediction)

#%%
def best_model_selection(kf, X, y):
    """
    Select the penalty giving best results using k-fold cross-validation.
    Other parameters should be left default.
    Input:
    kf (sklearn.model_selection.KFold): kf object defined above
    X (scipy.sparse.csr.csr_matrix): training data
    y (array(int)): training labels
    Return:
    best_penalty (string)
    """
    penalties = ['none', 'l2', 'l1', 'elasticnet']
    best_penalty = None
    best_avg_acc = -1.0
    
    for penalty in ['none', 'l2', 'l1', 'elasticnet']:
        fold_accuracies = []

        for train_index, val_index in kf.split(X):
            X_train, X_val = X[train_index], X[val_index]
            y_train, y_val = y[train_index], y[val_index]

            clf = learn_classifier(X_train, y_train, penalty)

            acc = evaluate_classifier(clf, X_val, y_val)
            fold_accuracies.append(acc)

        avg_acc = np.mean(fold_accuracies)

        if avg_acc > best_avg_acc:
            best_avg_acc = avg_acc
            best_penalty = penalty
        # Use the documentation of KFold cross-validation to split ..
        # training data and test data from create_features() and create_labels()
        # call learn_classifer() using training split of kth fold
        # evaluate on the test split of kth fold
        # record avg accuracies and determine best model (penalty)
    #return best penalty as string
    return best_penalty
    
#%%
def classify_tweets(tfidf, classifier, unlabeled_tweets):
    """ predicts class labels for raw tweet text
    Inputs:
        tfidf: sklearn.feature_extraction.text.TfidfVectorizer: the TfidfVectorizer object used on training data
        classifier: sklearn.linear_model.LogisticRegression: classifier learned
        unlabeled_tweets: pd.DataFrame: tweets read from tweets_test.csv
    Outputs:
        numpy.ndarray(int): dense binary vector of class labels for unlabeled tweets
    """
    processed_unlabeled = process_all(unlabeled_tweets)
    X_unlabeled = tfidf.transform(processed_unlabeled["Content"])
    y_pred = classifier.predict(X_unlabeled)

    return y_pred