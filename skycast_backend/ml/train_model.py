import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
import joblib

print("Loading dataset...")

# Load dataset
df = pd.read_csv("C:\\Users\\appar\\OneDrive\\Desktop\\skycast\\skycast_backend\\ml\\weather_data.csv")

print("Dataset loaded successfully!")
print(df.head())

# ---- CREATE DISASTER LABELS ----
def classify_disaster(row):
    if row["Wind_Speed_kmh"] > 90 and row["Precipitation_mm"] > 50:
        return 4  # Cyclone
    elif row["Precipitation_mm"] > 100:
        return 1  # Flood
    elif row["Temperature_C"] > 38:
        return 2  # Heatwave
    elif row["Wind_Speed_kmh"] > 60:
        return 3  # Storm
    else:
        return 0  # Normal

df["Disaster"] = df.apply(classify_disaster, axis=1)

print("Disaster column created!")

# Features
X = df[[
    "Temperature_C",
    "Humidity_pct",
    "Precipitation_mm",
    "Wind_Speed_kmh"
]]

y = df["Disaster"]

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print("Training model...")

# Train model
model = RandomForestClassifier(n_estimators=100)
model.fit(X_train, y_train)

print("Model trained successfully!")

# Evaluate
y_pred = model.predict(X_test)
print(classification_report(y_test, y_pred))

# Save model
joblib.dump(model, "disaster_model.pkl")

print("Model saved as disaster_model.pkl")
