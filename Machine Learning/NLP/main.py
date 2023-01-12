import time
import torch
from torch.utils.data import DataLoader, random_split
from torchtext.data import to_map_style_dataset

from reviews_dataset import reviews
from trainer import Trainer

# Hyperparameters
EPOCHS = 10  # epoch
LR = 5  # learning rate
BATCH_SIZE = 64  # batch size for training


def get_model(trainer: Trainer, dataset_path: str, EPOCHS = 10, LR = 5, BATCH_SIZE = 64):
    total_accu = None
    train_iter, test_iter = reviews(root=dataset_path)
    train_dataset = to_map_style_dataset(train_iter)
    test_dataset = to_map_style_dataset(test_iter)
    num_train = int(len(train_dataset) * 0.95)
    split_train_, split_valid_ = \
        random_split(train_dataset, [num_train, len(train_dataset) - num_train])

    train_dataloader = DataLoader(split_train_, batch_size=BATCH_SIZE,
                                  shuffle=True, collate_fn=trainer.collate_batch)
    valid_dataloader = DataLoader(split_valid_, batch_size=BATCH_SIZE,
                                  shuffle=True, collate_fn=trainer.collate_batch)
    test_dataloader = DataLoader(test_dataset, batch_size=BATCH_SIZE,
                                 shuffle=True, collate_fn=trainer.collate_batch)

    for epoch in range(1, EPOCHS + 1):
        epoch_start_time = time.time()
        trainer.train(train_dataloader, epoch)
        accu_val = trainer.evaluate(valid_dataloader)
        if total_accu is not None and total_accu > accu_val:
            trainer.scheduler.step()
        else:
            total_accu = accu_val
        print('-' * 59)
        print('| end of epoch {:3d} | time: {:5.2f}s | '
              'valid accuracy {:8.3f} '.format(epoch,
                                               time.time() - epoch_start_time,
                                               accu_val))
        print('-' * 59)

    print('Checking the results of test dataset.')
    accu_test = trainer.evaluate(test_dataloader)
    print('test accuracy {:8.3f}'.format(accu_test))

    trainer.model = trainer.model.to("cpu")

    return trainer.model


if __name__ == "__main__":
    dataset_path = 'ProcessedDatasets/all_reviews.json'
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    dataset = reviews(root=dataset_path, split='train')

    trainer = Trainer(dataset, device, LR)
    trainer.model = get_model(trainer, dataset_path)

    reviews_labels = {1: "Negative",
                      2: "Neutral",
                      3: "Positive"}

    ex_text_str1 = "Super mega proszek, bardzo dobry"
    ex_text_str2 = "Totalny badziew szkoda pieniędzy, beznadziejny, porażka"
    ex_text_str3 = "Nie domywa ale ładnie pachnie. Zostają smugi"
    ex_text_str4 = "Nie rozpuszczają się, dobrze domywają, ładnie pachną, ale bardzo drogie"

    print("This is a %s review" % reviews_labels[trainer.predict(ex_text_str1)])
    print("This is a %s review" % reviews_labels[trainer.predict(ex_text_str2)])
    print("This is a %s review" % reviews_labels[trainer.predict(ex_text_str3)])
    print("This is a %s review" % reviews_labels[trainer.predict(ex_text_str4)])
