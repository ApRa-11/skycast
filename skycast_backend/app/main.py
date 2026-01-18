from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from app.routes import weather

load_dotenv()

app = FastAPI(
    title="SkyCast API",
    description="Weather Forecast & Disaster Alert System",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # allow all for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(weather.router)

@app.get("/")
def root():
    return {"message": "SkyCast backend is running 🌦️"}
