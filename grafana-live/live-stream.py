import os
import asyncio
import websockets 
import time
import random

# Docs
# https://grafana.com/docs/grafana/latest/setup-grafana/set-up-grafana-live/
# https://grafana.com/tutorials/stream-metrics-from-telegraf-to-grafana/
# https://websockets.readthedocs.io/en/stable/intro/index.html
# https://docs.influxdata.com/influxdb/cloud/reference/syntax/line-protocol/

grafanaApiToken = os.environ.get("GRAFANA_API_TOKEN", "API Key Missing")
channelId = "random"
url = "ws://grafana1.local:3000/api/live/push/{channel_id}".format(channel_id=channelId)
headers = { "Authorization": f"Bearer {grafanaApiToken}" }

print( grafanaApiToken, url, headers )

async def test1():
    async with websockets.connect(url, extra_headers=headers ) as ws:
        for i in range(1000):
            metric = "data,type={} users={} {}".format(
                    random.randint(1,3), random.randint(1,10), time.time_ns())
            print(i, metric )
            await ws.send(metric)
            await asyncio.sleep(2)  # yield control to the event loop

asyncio.get_event_loop().run_until_complete( test1() )