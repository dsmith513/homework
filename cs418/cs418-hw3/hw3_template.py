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
    [YOUR CODE HERE]
    
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

    lemma_tokens = [lemmatizer.lemmatize(token) for token in tokens]

    return lemma_tokens

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
    [YOUR CODE HERE]

#%%
def create_labels(processed_tweets):
    """ creates the class labels from handle
    Inputs:
        processed_tweets: pd.DataFrame: tweets read from train file, containing the column 'handle'
    Outputs:
        numpy.ndarray(int): dense binary numpy array of class labels
    """
    [YOUR CODE HERE]
    
#%%
class MajorityLabelClassifier():
    """
    A classifier that predicts the mode of training labels
    """
    def __init__(self):
        """
        Initialize your parameter here
        """
        [YOUR CODE HERE]
        
    def fit(self, X, y):
        """
        Implement fit by taking training data X and their labels y and finding the mode of y
        i.e. store your learned parameter
        """
        [YOUR CODE HERE]
    
    def predict(self, X):
        """
        Implement to give the mode of training labels as a prediction for each data instance in X
        return labels
        """
        [YOUR CODE HERE]

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
    
    [YOUR CODE HERE]

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
    [YOUR CODE HERE]

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
    [YOUR CODE HERE]
    
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
    [YOUR CODE HERE]