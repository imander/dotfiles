import requests
import json
import os

location_file = os.getenv('HOME') + '/.config/conky/location'
forecast_file = os.getenv('HOME') + '/.config/conky/forecast'
# image_dir = os.getenv('HOME') + '/.config/conky/images'

r = requests.get('http://ip-api.com/json')
out = json.loads(r.text)
lat = out['lat']
lon = out['lon']

url = f'https://api.weather.gov/points/{lat},{lon}'
r = json.loads(requests.get(url).text)

with open(location_file, 'w+') as f:
    f.write(r['properties']['relativeLocation']['properties']['city'].upper())

forecast = requests.get(r['properties']['forecast']).text
with open(forecast_file, 'w+') as f:
    f.write(forecast)

# data = json.loads(forecast)
# for n in range (0, 3):
#     img_data = requests.get(data['properties']['periods'][n]['icon']).content
#     with open(image_dir + f'/image{n}.png', 'wb') as handler:
#         handler.write(img_data)
