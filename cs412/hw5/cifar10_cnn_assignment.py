
"""
CIFAR-10 CNN Assignment
Parts 1-4 completed in TensorFlow / Keras

Notes:
- This script is ready to run locally or in a notebook.
- Full training can take a while depending on hardware.
- The code saves a simple comparison table at the end.
"""

import time
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.datasets import cifar10
from tensorflow.keras.models import Sequential, Model
from tensorflow.keras.layers import (
    Input, Conv2D, MaxPooling2D, Flatten, Dense, Dropout,
    BatchNormalization, GlobalAveragePooling2D, Activation,
    Add, SeparableConv2D
)
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.utils import to_categorical


# ============================================================
# Part 1: Dataset Selection and Preprocessing
# ============================================================

print("TensorFlow version:", tf.__version__)

# Load CIFAR-10
(X_train, y_train), (X_test, y_test) = cifar10.load_data()

# Normalize images to [0, 1]
X_train = X_train.astype("float32") / 255.0
X_test = X_test.astype("float32") / 255.0

# One-hot encode labels
y_train_cat = to_categorical(y_train, 10)
y_test_cat = to_categorical(y_test, 10)

class_names = [
    "airplane", "automobile", "bird", "cat", "deer",
    "dog", "frog", "horse", "ship", "truck"
]

print("\nPart 1 complete.")
print("Training set shape:", X_train.shape)
print("Test set shape:", X_test.shape)
print("One-hot label shape:", y_train_cat.shape)
print("Pixel range:", X_train.min(), "to", X_train.max())


# ============================================================
# Utility Functions
# ============================================================

def compile_and_train(model, X_tr, y_tr, X_te, y_te, epochs=10, batch_size=64, use_datagen=False):
    """
    Compile, train, and evaluate a model.
    Returns:
        history, test_loss, test_acc, training_time
    """
    model.compile(
        optimizer="adam",
        loss="categorical_crossentropy",
        metrics=["accuracy"]
    )

    start = time.time()

    if use_datagen:
        datagen = ImageDataGenerator(
            rotation_range=15,
            width_shift_range=0.1,
            height_shift_range=0.1,
            horizontal_flip=True
        )
        datagen.fit(X_tr)

        history = model.fit(
            datagen.flow(X_tr, y_tr, batch_size=batch_size),
            epochs=epochs,
            validation_split=0.0,
            validation_data=(X_te, y_te),
            verbose=1
        )
    else:
        history = model.fit(
            X_tr, y_tr,
            epochs=epochs,
            batch_size=batch_size,
            validation_split=0.2,
            verbose=1
        )

    training_time = time.time() - start
    test_loss, test_acc = model.evaluate(X_te, y_te, verbose=0)

    return history, test_loss, test_acc, training_time


def summarize_run(name, history, test_loss, test_acc, training_time):
    """
    Extract summary metrics from a training run.
    """
    best_val_acc = max(history.history.get("val_accuracy", [np.nan]))
    final_train_acc = history.history.get("accuracy", [np.nan])[-1]

    return {
        "model": name,
        "final_train_accuracy": round(float(final_train_acc), 4),
        "best_validation_accuracy": round(float(best_val_acc), 4) if not np.isnan(best_val_acc) else np.nan,
        "test_accuracy": round(float(test_acc), 4),
        "test_loss": round(float(test_loss), 4),
        "training_time_sec": round(float(training_time), 2)
    }


# ============================================================
# Part 2: Build a Baseline CNN
# ============================================================

def build_baseline_cnn():
    model = Sequential([
        Conv2D(32, (3, 3), activation="relu", input_shape=(32, 32, 3)),
        MaxPooling2D((2, 2)),
        Flatten(),
        Dense(64, activation="relu"),
        Dense(10, activation="softmax")
    ])
    return model


baseline_model = build_baseline_cnn()
baseline_model.summary()

print("\nTraining baseline CNN...")
baseline_history, baseline_test_loss, baseline_test_acc, baseline_time = compile_and_train(
    baseline_model, X_train, y_train_cat, X_test, y_test_cat, epochs=10, batch_size=64
)

results = []
results.append(
    summarize_run("Baseline CNN", baseline_history, baseline_test_loss, baseline_test_acc, baseline_time)
)

print("\nPart 2 complete.")
print("Baseline test accuracy:", round(baseline_test_acc, 4))


# ============================================================
# Part 3: Experimentation and Architecture Tuning
# ============================================================

# 1. More convolutional layers + same padding
def build_deeper_cnn():
    model = Sequential([
        Input(shape=(32, 32, 3)),
        Conv2D(32, (3, 3), padding="same", activation="relu"),
        Conv2D(32, (3, 3), padding="same", activation="relu"),
        MaxPooling2D((2, 2)),

        Conv2D(64, (3, 3), padding="same", activation="relu"),
        Conv2D(64, (3, 3), padding="same", activation="relu"),
        MaxPooling2D((2, 2)),

        Flatten(),
        Dense(128, activation="relu"),
        Dense(10, activation="softmax")
    ])
    return model


# 2. Batch normalization + dropout
def build_bn_dropout_cnn():
    model = Sequential([
        Input(shape=(32, 32, 3)),

        Conv2D(32, (3, 3), padding="same"),
        BatchNormalization(),
        Activation("relu"),
        Conv2D(32, (3, 3), padding="same"),
        BatchNormalization(),
        Activation("relu"),
        MaxPooling2D((2, 2)),
        Dropout(0.25),

        Conv2D(64, (3, 3), padding="same"),
        BatchNormalization(),
        Activation("relu"),
        Conv2D(64, (3, 3), padding="same"),
        BatchNormalization(),
        Activation("relu"),
        MaxPooling2D((2, 2)),
        Dropout(0.25),

        Flatten(),
        Dense(128),
        BatchNormalization(),
        Activation("relu"),
        Dropout(0.5),
        Dense(10, activation="softmax")
    ])
    return model


# 3. Leaky ReLU style activation
def build_leakyrelu_cnn():
    model = Sequential([
        Input(shape=(32, 32, 3)),
        Conv2D(32, (3, 3), padding="same"),
        tf.keras.layers.LeakyReLU(negative_slope=0.1),
        MaxPooling2D((2, 2)),

        Conv2D(64, (3, 3), padding="same"),
        tf.keras.layers.LeakyReLU(negative_slope=0.1),
        MaxPooling2D((2, 2)),

        Flatten(),
        Dense(128),
        tf.keras.layers.LeakyReLU(negative_slope=0.1),
        Dense(10, activation="softmax")
    ])
    return model


tuned_builders = [
    ("Deeper CNN", build_deeper_cnn),
    ("BatchNorm + Dropout CNN", build_bn_dropout_cnn),
    ("LeakyReLU CNN", build_leakyrelu_cnn),
]

for name, builder in tuned_builders:
    print(f"\nTraining {name}...")
    model = builder()
    history, test_loss, test_acc, training_time = compile_and_train(
        model, X_train, y_train_cat, X_test, y_test_cat, epochs=10, batch_size=64
    )
    results.append(summarize_run(name, history, test_loss, test_acc, training_time))

print("\nPart 3 complete.")


# ============================================================
# Part 4: Advanced Exploration
# ============================================================

# 1. Data augmentation + GlobalAveragePooling
def build_gap_augmented_cnn():
    model = Sequential([
        Input(shape=(32, 32, 3)),

        Conv2D(32, (3, 3), padding="same", activation="relu"),
        BatchNormalization(),
        Conv2D(32, (3, 3), padding="same", activation="relu"),
        MaxPooling2D((2, 2)),

        Conv2D(64, (3, 3), padding="same", activation="relu"),
        BatchNormalization(),
        Conv2D(64, (3, 3), padding="same", activation="relu"),
        MaxPooling2D((2, 2)),

        Conv2D(128, (3, 3), padding="same", activation="relu"),
        BatchNormalization(),
        GlobalAveragePooling2D(),

        Dense(64, activation="relu"),
        Dropout(0.3),
        Dense(10, activation="softmax")
    ])
    return model


# 2. Simple residual block model
def residual_block(x, filters):
    shortcut = x

    x = Conv2D(filters, (3, 3), padding="same")(x)
    x = BatchNormalization()(x)
    x = Activation("relu")(x)

    x = Conv2D(filters, (3, 3), padding="same")(x)
    x = BatchNormalization()(x)

    if shortcut.shape[-1] != filters:
        shortcut = Conv2D(filters, (1, 1), padding="same")(shortcut)
        shortcut = BatchNormalization()(shortcut)

    x = Add()([x, shortcut])
    x = Activation("relu")(x)
    return x


def build_residual_cnn():
    inputs = Input(shape=(32, 32, 3))

    x = Conv2D(32, (3, 3), padding="same", activation="relu")(inputs)
    x = residual_block(x, 32)
    x = MaxPooling2D((2, 2))(x)

    x = residual_block(x, 64)
    x = MaxPooling2D((2, 2))(x)

    x = residual_block(x, 128)
    x = GlobalAveragePooling2D()(x)

    x = Dense(64, activation="relu")(x)
    outputs = Dense(10, activation="softmax")(x)

    model = Model(inputs, outputs)
    return model


# 3. Separable convolution model
def build_separable_cnn():
    model = Sequential([
        Input(shape=(32, 32, 3)),

        SeparableConv2D(32, (3, 3), padding="same", activation="relu"),
        BatchNormalization(),
        MaxPooling2D((2, 2)),

        SeparableConv2D(64, (3, 3), padding="same", activation="relu"),
        BatchNormalization(),
        MaxPooling2D((2, 2)),

        SeparableConv2D(128, (3, 3), padding="same", activation="relu"),
        BatchNormalization(),
        GlobalAveragePooling2D(),

        Dense(64, activation="relu"),
        Dense(10, activation="softmax")
    ])
    return model


advanced_builders = [
    ("Augmentation + GAP CNN", build_gap_augmented_cnn, True),
    ("Residual CNN", build_residual_cnn, False),
    ("SeparableConv CNN", build_separable_cnn, False),
]

for name, builder, use_datagen in advanced_builders:
    print(f"\nTraining {name}...")
    model = builder()
    history, test_loss, test_acc, training_time = compile_and_train(
        model,
        X_train,
        y_train_cat,
        X_test,
        y_test_cat,
        epochs=10,
        batch_size=64,
        use_datagen=use_datagen
    )
    results.append(summarize_run(name, history, test_loss, test_acc, training_time))

print("\nPart 4 complete.")


# ============================================================
# Final Comparison
# ============================================================

results_df = pd.DataFrame(results)
results_df = results_df.sort_values(by="test_accuracy", ascending=False).reset_index(drop=True)

print("\nModel comparison:")
print(results_df)

results_df.to_csv("cifar10_cnn_results.csv", index=False)
print("\nSaved results to cifar10_cnn_results.csv")

print("\nDone.")
