import sys
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import joblib
import numpy as np
import requests
from urllib.parse import quote
from dotenv import load_dotenv

sys.path.append(
    
    r"C:\\Users\\appar\\OneDrive\\Desktop\\chatbot"
)

from chat_services.chat_service import get_reply

load_dotenv()
OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load ML model (resolve path relative to this file)
base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
model_path = os.path.join(base_dir, "disaster_model.pkl")
if not os.path.exists(model_path):
    # fallback to previous relative path if someone has moved the model
    model_path = os.path.join(os.path.dirname(__file__), "..", "ml", "disaster_model.pkl")
    model_path = os.path.abspath(model_path)

model = joblib.load(model_path)

def disaster_details(pred):
    mapping = {
        0: {
            "type": "Normal",
            "severity": "Low",
            "tips": ["Weather conditions are stable."],
            "recommendation": "No action needed.",
            "risk_score": 10
        },
        1: {
            "type": "Flood",
            "severity": "High",
            "tips": [
                "Avoid low-lying areas.",
                "Keep emergency kit ready.",
                "Do not drive through flooded roads."
            ],
            "recommendation": "Evacuate if possible.",
            "risk_score": 85
        },
        2: {
            "type": "Heatwave",
            "severity": "Medium",
            "tips": [
                "Stay hydrated.",
                "Avoid direct sunlight.",
                "Wear light clothing."
            ],
            "recommendation": "Stay indoors during peak hours.",
            "risk_score": 60
        },
        3: {
            "type": "Storm",
            "severity": "High",
            "tips": [
                "Stay indoors.",
                "Avoid travel.",
                "Secure loose outdoor objects."
            ],
            "recommendation": "Stay indoors and secure property.",
            "risk_score": 75
        },
        4: {
            "type": "Cyclone",
            "severity": "Critical",
            "tips": [
                "Evacuate if advised.",
                "Stock essential supplies.",
                "Stay tuned to official updates."
            ],
            "recommendation": "Evacuate immediately if possible.",
            "risk_score": 95
        },
    }
    return mapping.get(pred, {
        "type": "Unknown",
        "severity": "Unknown",
        "tips": ["No data available."],
        "recommendation": "No recommendation.",
        "risk_score": 0
    })


@app.get("/")
def root():
    return {"message": "SkyCast Backend is running 🚀"}


@app.get("/weather")
def get_weather(city: str):
    try:
        city_encoded = quote(city)
        url = f"https://api.openweathermap.org/data/2.5/weather?q={city_encoded}&appid={OPENWEATHER_API_KEY}&units=metric"
        response = requests.get(url)

        if response.status_code != 200:
            return {"error": "City not found"}

        data = response.json()

        features = np.array([[
            data["main"]["temp"],
            data["main"]["humidity"],
            data.get("rain", {}).get("1h", 0),
            data["wind"]["speed"] * 3.6
        ]])

        prediction = model.predict(features)[0]
        proba = model.predict_proba(features)[0]

        # compute risk from disaster probabilities (ignore Normal = index 0)
        disaster_probs = proba[1:]
        max_disaster_prob = max(disaster_probs)
        risk_score = round(max_disaster_prob * 100, 2)

        disaster_info = disaster_details(prediction)

        # override severity based on real risk
        if prediction == 0:
            risk_score = round((1 - proba[0]) * 100, 2)
            severity = "Low"
            disaster_type = "No Significant Risk"
        else:
            disaster_type = disaster_info["type"]
            if risk_score >= 70:
                severity = "High"
            elif risk_score >= 40:
                severity = "Medium"
            else:
                severity = "Low"

        return {
            "city": data["name"],
            "temperature": data["main"]["temp"],
            "feels_like": data["main"]["feels_like"],
            "humidity": data["main"]["humidity"],
            "weather": data["weather"][0]["main"],
            "wind_speed": data["wind"]["speed"],
            "disaster_type": disaster_type,
            "severity": severity,
            "safety_tips": disaster_info["tips"],
            "recommendation": disaster_info["recommendation"],
            "risk_score": risk_score
        }

    except Exception as e:
        return {"error": str(e)}


@app.post("/predict_disaster")
def predict_disaster(data: dict):
    try:
        features = np.array([[
            data["Temperature_C"],
            data["Humidity_pct"],
            data["Precipitation_mm"],
            data["Wind_Speed_kmh"]
        ]])

        prediction = model.predict(features)[0]
        proba = model.predict_proba(features)[0]

        disaster_probs = proba[1:]
        max_disaster_prob = max(disaster_probs)
        risk_score = round(max_disaster_prob * 100, 2)

        result = disaster_details(prediction)

        if prediction == 0:
            risk_score = round((1 - proba[0]) * 100, 2)
            severity = "Low"
            disaster_type = "No Significant Risk"
        else:
            disaster_type = result["type"]
            if risk_score >= 70:
                severity = "High"
            elif risk_score >= 40:
                severity = "Medium"
            else:
                severity = "Low"

        return {
            "disaster_type": disaster_type,
            "severity": severity,
            "safety_tips": result["tips"],
            "recommendation": result["recommendation"],
            "risk_score": risk_score
        }

    except Exception as e:
        return {"error": str(e)}


from pydantic import BaseModel

class ChatRequest(BaseModel):
    session_id: str
    message: str


@app.post("/chat")
def chat_endpoint(request: ChatRequest):
    reply = get_reply(request.session_id, request.message)
    return {"reply": reply}

fcm_tokens = []

@app.post("/register-token")
async def register_token(data: dict):
    token = data.get("token")

    if token and token not in fcm_tokens:
        fcm_tokens.append(token)

    return {"message": "Token registered"}