from pydantic import BaseModel
from typing import List, Optional

class Alert(BaseModel):
    type: str
    severity: str
    message: str

class WeatherResponse(BaseModel):
    city: str
    temperature: float
    feels_like: float
    humidity: int
    weather: str
    wind_speed: float
    alerts: Optional[List[Alert]] = []
