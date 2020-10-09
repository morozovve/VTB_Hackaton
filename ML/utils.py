import cv2
import numpy as np
from tqdm import tqdm

import torch
from torch import nn
from torchvision import transforms, models
from torch.utils.data import Dataset

class_names = ['kiario', 'octavia', 'solaris', 'vwpolo', 'vwtiguan'] # sry for hardcoding :)


def create_model(n_classes, device):
    model_ft = models.mobilenet_v2(pretrained=True)

    num_ftrs = model_ft.classifier[1].in_features
    model_ft.classifier[1] = nn.Linear(num_ftrs, len(class_names))
    model_ft = model_ft.to(device)
    return model_ft

class Rescale(object):
    def __init__(self, output_size):
        assert isinstance(output_size, (int, tuple))
        self.output_size = output_size

    def __call__(self, sample):
        image, label = sample['image'], sample['label']

        h, w = image.shape[:2]
        if isinstance(self.output_size, int):
            if h > w:
                new_h, new_w = self.output_size * h / w, self.output_size
            else:
                new_h, new_w = self.output_size, self.output_size * w / h
        else:
            new_h, new_w = self.output_size

        new_h, new_w = int(new_h), int(new_w)

        img = cv2.resize(image, (new_w, new_h))

        return {'image': img, 'label': label}


class RandomCrop(object):
    def __init__(self, output_size):
        assert isinstance(output_size, (int, tuple))
        if isinstance(output_size, int):
            self.output_size = (output_size, output_size)
        else:
            assert len(output_size) == 2
            self.output_size = output_size

    def __call__(self, sample):
        image, label = sample['image'], sample['label']

        h, w = image.shape[:2]
        new_h, new_w = self.output_size

        top = np.random.randint(0, h - new_h)
        left = np.random.randint(0, w - new_w)

        image = image[top: top + new_h,
                      left: left + new_w]

        return {'image': image, 'label': label}


class ToTensor(object):
    def __call__(self, sample):
        image, label = sample['image'], sample['label']
        image = image.transpose((2, 0, 1))
        return {'image': torch.from_numpy(image),
                'label': label}


class RandomHorizontalFlip(object):
    def __init__(self, p):
         self.p = p

    def __call__(self, sample):
        image, label = sample['image'], sample['label']
        if np.random.rand() < self.p:
            image = np.array(image[:, ::-1, :])
        return {'image': image,
                'label': label}

class Normalize(object):
    def __init__(self, *args, **kwargs):
         self.normalizer = transforms.Normalize(*args, **kwargs)

    def __call__(self, sample):
        image, label = sample['image'], sample['label']
        image = self.normalizer(image)
        return {'image': image,
                'label': label}


def dict_collate_fn(batch_dict_list):
    images = [item['image'] for item in batch_dict_list]
    labels = [item['label'] for item in batch_dict_list]

    batch_dict = dict()
    # Merge images
    batch_dict['data'] = torch.stack(images, 0)

    # Merge labels
    batch_dict['label'] = torch.tensor(np.stack(labels , 0))
    return batch_dict

def get_transforms():
    train_tf = transforms.Compose((
        RandomCrop((210, 280)),
        Rescale((240, 320)),
        RandomHorizontalFlip(0.5),
        ToTensor(),
        Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225], inplace=False),
    ))

    val_tf = transforms.Compose((
        Rescale((240, 320)),
        ToTensor(),
        Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225], inplace=False),
    ))

    return train_tf, val_tf

class CarRecognitionDataset(Dataset):
    """Car Recognition dataset."""

    def __init__(self, flist, labels, transform=None, dst_size=(240, 320), load_to_ram=True):
        """
        Args:
            flist (list[string]): List with absolute paths to image files
            lables (list[int]): List of corresponding labels
            transform (callable, optional): Optional transform to be applied
                on a sample.
        """
        self.flist = flist
        self.labels = labels
        self.transform = transform
        self.dst_size = dst_size[::-1]
        self.data = []
        if load_to_ram:
            for f in tqdm(self.flist):
                self.data.append(cv2.resize(cv2.imread(f)[..., ::-1], self.dst_size))
            self.data = np.array(self.data)

    def __len__(self):
        return len(self.flist)

    def __getitem__(self, idx):
        if torch.is_tensor(idx):
            idx = idx.tolist()
        if len(self.data):
            image = self.data[idx]
        else:
            img_name = self.flist[idx]
            image = cv2.resize(cv2.imread(img_name), self.dst_size)

        label = self.labels[idx]
        sample = {'image': image, 'label': label}

        if self.transform:
            sample = self.transform(sample)

        return sample