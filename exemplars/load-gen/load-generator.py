import random
import requests
import time
import traceback

HOSTS = [
    'us-east',
    'eu-north',
    'ap-south',
]


HOSTS = [
    'app-java-1',
]

VEHICLES = [
    'bike',
    'scooter',
    'car',
]

if __name__ == "__main__":
    print(f"starting load generator")
    time.sleep(3)
    while True:
        host = HOSTS[random.randint(0, len(HOSTS) - 1)]
        vehicle = VEHICLES[random.randint(0, len(VEHICLES) - 1)]
        print(f"requesting {vehicle} from {host}")
        try:
            resp = requests.get(f'http://{host}:5000/{vehicle}')
            resp.raise_for_status()
            print(f"received {resp}")
        except BaseException as e:
            print (f"http error {e}")

        #time.sleep(random.uniform(0.7, 0.4))
        #time.sleep(random.uniform(0.7, 2.4))
        time.sleep( 5 )
