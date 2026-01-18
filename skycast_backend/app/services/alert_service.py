def generate_alerts(weather: dict):
    alerts = []

    temp = weather["temperature"]
    wind = weather["wind_speed"]

    if temp >= 40:
        alerts.append({
            "type": "Heatwave",
            "severity": "High",
            "message": "Extreme heat conditions. Stay hydrated and avoid sun exposure."
        })
    elif temp >= 35:
        alerts.append({
            "type": "High Temperature",
            "severity": "Medium",
            "message": "High temperatures detected. Take precautions."
        })

    if wind >= 15:
        alerts.append({
            "type": "Storm",
            "severity": "High",
            "message": "Strong winds detected. Stay indoors."
        })

    if temp <= 5:
        alerts.append({
            "type": "Cold Wave",
            "severity": "Medium",
            "message": "Low temperatures detected. Keep warm."
        })

    return alerts
