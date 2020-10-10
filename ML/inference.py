import sys
import torch
import torch.nn
import cv2
import matplotlib.pyplot as plt

from utils import get_transforms, create_model

def prepare_image(img):
    img_dict = {'image': img, 'label': 0}
    _, val_tf = get_transforms()
    img_dict = val_tf(img_dict)
    img_dict['image'] = img_dict['image'].unsqueeze(0)
    return img_dict

def load_model(model_path, device):
    model = create_model(n_classes=5, device=device)
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.eval()
    return model

def inference(model, data):
    outputs = model(data)
    probas = torch.softmax(outputs, 1)
    return probas.detach().cpu().numpy().tolist()
    # _, preds = torch.max(outputs, 1)

def main():
    fpath = sys.argv[1]
    mpath = sys.argv[2]

    image = cv2.imread(fpath) / 255.

    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    data = prepare_image(image)['image'].to(device).type(torch.float)
    model = load_model(mpath, device)

    res = inference(model, data)
    print(res)

if __name__ == '__main__':
    main()
