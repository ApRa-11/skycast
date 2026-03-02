import time
import requests

for i in range(20):
    try:
        r = requests.get('http://127.0.0.1:8000/', timeout=2)
        print(r.status_code)
        print(r.text)
        break
    except Exception as e:
        time.sleep(0.5)
        if i == 19:
            print('failed:', e)
