import pickle as pkl
from torch.utils.data import DataLoader
from utils import dict_collate_fn, class_names

def load_data(train_set_pkl, val_set_pkl):
    with open(train_set_pkl, 'rb') as f:
        train_dataset = pkl.load(f)
    with open(val_set_pkl, 'rb') as f:
        val_dataset = pkl.load(f)
    train_loader = DataLoader(train_dataset, batch_size=8,
                    shuffle=True, num_workers=0, collate_fn=dict_collate_fn)
    val_loader = DataLoader(val_dataset, batch_size=8,
                    shuffle=False, num_workers=0, collate_fn=dict_collate_fn)
    dataloaders = {'train': train_loader, 'val': val_loader}
    dataset_sizes = {'train': len(train_dataset), 'val': len(val_dataset)}
    return dataloaders, dataset_sizes, class_names
