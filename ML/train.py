from __future__ import print_function, division
import copy
import torch
import torch.nn as nn
import torch.optim as optim
import time
from torch.optim import lr_scheduler
from tqdm import tqdm

from utils import create_model
from data_loading import load_data

# specific path for GColab + GDrive
train_path = '/content/drive/My Drive/VTB_data/train_set.pkl'
val_path = '/content/drive/My Drive/VTB_data/val_set.pkl'

def train_model(dataloaders, dataset_sizes, model, criterion, optimizer, scheduler, output_path, device, num_epochs=15):
    since = time.time()

    best_model_wts = copy.deepcopy(model.state_dict())
    best_acc = 0.0

    for epoch in range(num_epochs):
        print('Epoch {}/{}'.format(epoch, num_epochs - 1))
        print('-' * 10)

        for phase in ['train', 'val']:
            if phase == 'train':
                model.train()  # Set model to training mode
            else:
                model.eval()   # Set model to evaluate mode

            running_loss = 0.0
            running_corrects = 0

            for batch in tqdm(dataloaders[phase]):
                inputs = batch['data'].to(device).type(torch.float32)
                labels = batch['label'].to(device).type(torch.long)

                optimizer.zero_grad()

                # forward
                with torch.set_grad_enabled(phase == 'train'):
                    outputs = model(inputs)
                    _, preds = torch.max(outputs, 1)
                    loss = criterion(outputs, labels)
                    if phase == 'train':
                        loss.backward()
                        optimizer.step()

                # statistics
                running_loss += loss.item() * inputs.size(0)
                running_corrects += torch.sum(preds == labels.data)
            if phase == 'train':
                scheduler.step()

            epoch_loss = running_loss / dataset_sizes[phase]
            epoch_acc = running_corrects.double() / dataset_sizes[phase]

            print('{} Loss: {:.4f} Acc: {:.4f}'.format(
                phase, epoch_loss, epoch_acc))

            if phase == 'val' and epoch_acc > best_acc:
                best_acc = epoch_acc
                best_model_wts = copy.deepcopy(model.state_dict())
                best_model_name = '{}/mnet2_epoch_{}_vacc_{:.3f}.pth'.format(output_path, epoch, best_acc)
                torch.save(best_model_wts, best_model_name)

    time_elapsed = time.time() - since
    print('Training complete in {:.0f}m {:.0f}s'.format(
        time_elapsed // 60, time_elapsed % 60))
    print('Best val Acc: {:4f}'.format(best_acc))

    # load best model weights
    model.load_state_dict(best_model_wts)
    return best_model_name

def train():
    dataloaders, dataset_sizes, class_names = load_data(train_path, val_path)
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    print('Using {}'.format(device))
    model_ft = create_model(n_classes=5, device=device)

    criterion = nn.CrossEntropyLoss()
    optimizer_ft = optim.SGD(model_ft.parameters(), lr=0.001, momentum=0.9)
    exp_lr_scheduler = lr_scheduler.StepLR(optimizer_ft, step_size=7, gamma=0.1)

    best_model_name = model_ft = train_model(dataloaders, dataset_sizes, model_ft, criterion, optimizer_ft, exp_lr_scheduler,
                                             output_path='/content/drive/My Drive/VTB_data/models/',
                                             num_epochs=10, device=device)
    print('Training finished, best model is saved at {}'.format(best_model_name))

def main():
    train()

if __name__ == '__main__':
    main()