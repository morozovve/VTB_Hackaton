import io
import json
import torch
import cv2
from torchvision import models
import torchvision.transforms as transforms
from PIL import Image
from flask import Flask, jsonify, request
import base64
import numpy as np

import sys
sys.path.append('../ML')
from inference import prepare_image, load_model, inference
class_names = ["KIA Rio", "SKODA OCTAVIA", "Hyundai SOLARIS", "Volkswagen Polo", "Volkswagen Tiguan"]

mpath = '../eval/model.pth'
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
model = load_model(mpath, device)

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    if request.method == 'POST':
        bm = request.form['content']
        bb = bm.encode('ascii')
        m = base64.b64decode(bb)
        nparr = np.fromstring(m, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR) / 255.
        data = prepare_image(image)['image'].to(device).type(torch.float)
        res = inference(model, data)[0]
        res_dict = {k: v for k, v in zip(class_names, res)}
        return jsonify({'default': res_dict})


if __name__ == '__main__':
    app.run()
