from fastapi import APIRouter, HTTPException
from app.services.weather_service import fetch_weather
from app.services.alert_service import generate_alerts
from app.schemas.weather_schema import WeatherResponse

router = APIRouter(prefix="/weather", tags=["Weather"])

@router.get("/", response_model=WeatherResponse)
def get_weather(city: str):
    weather = fetch_weather(city)

    if not weather:
        raise HTTPException(status_code=404, detail="City not found")

    alerts = generate_alerts(weather)
    weather["alerts"] = alerts

    return weather
