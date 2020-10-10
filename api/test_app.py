import requests
import base64

with open('../eval/sample_octavia.jpeg', 'rb') as f:
    data = f.read()
b64_data = base64.b64encode(data).decode('ascii')
print('B64 data of len {}: {}...'.format(len(b64_data), b64_data[:10]))
resp = requests.post("http://84.201.184.112:5000/predict",
                     data={"content": b64_data})
print(resp.json())
