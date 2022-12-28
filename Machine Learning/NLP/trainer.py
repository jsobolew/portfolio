import time

import torch
from torch.nn import CrossEntropyLoss
from torch.utils.data import DataLoader
from torchtext.data import get_tokenizer
from torchtext.vocab import build_vocab_from_iterator

from model import TextClassificationModel


class Trainer:

    def __init__(self, dataset, device, learning_rate):
        self.dataset = dataset
        self.device = device
        self.tokenizer = get_tokenizer('spacy', 'pl_core_news_md')
        self.vocab = build_vocab_from_iterator(self.yield_tokens(dataset), specials=["<unk>"])
        self.vocab.set_default_index(self.vocab["<unk>"])

        num_class = len(set([label for (label, text) in dataset]))
        vocab_size = len(self.vocab)
        emsize = 64
        self.model = TextClassificationModel(vocab_size, emsize, num_class).to(self.device)
        self.criterion = torch.nn.CrossEntropyLoss()
        self.optimizer = torch.optim.SGD(self.model.parameters(), lr=learning_rate)
        self.scheduler = torch.optim.lr_scheduler.StepLR(self.optimizer, 1, gamma=0.1)

    def text_pipeline(self, text: str):
        return self.vocab(self.tokenizer(text))

    def train(self, dataloader, epoch):
        self.model.train()
        total_acc, total_count = 0, 0
        log_interval = 500
        start_time = time.time()

        for idx, (label, text, offsets) in enumerate(dataloader):
            self.optimizer.zero_grad()
            predicted_label = self.model(text, offsets)
            loss = self.criterion(predicted_label, label)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(self.model.parameters(), 0.1)
            self.optimizer.step()
            total_acc += (predicted_label.argmax(1) == label).sum().item()
            total_count += label.size(0)
            if idx % log_interval == 0 and idx > 0:
                elapsed = time.time() - start_time
                print('| epoch {:3d} | {:5d}/{:5d} batches '
                      '| accuracy {:8.3f}'.format(epoch, idx, len(dataloader),
                                                  total_acc / total_count))
                total_acc, total_count = 0, 0
                start_time = time.time()

    def evaluate(self, dataloader: DataLoader):
        self.model.eval()
        total_acc, total_count = 0, 0

        with torch.no_grad():
            for idx, (label, text, offsets) in enumerate(dataloader):
                predicted_label = self.model(text, offsets)
                loss = self.criterion(predicted_label, label)
                total_acc += (predicted_label.argmax(1) == label).sum().item()
                total_count += label.size(0)
        return total_acc / total_count

    def collate_batch(self, batch):
        label_list, text_list, offsets = [], [], [0]
        for (_label, _text) in batch:
            label_list.append(_label)
            processed_text = torch.tensor(self.text_pipeline(_text), dtype=torch.int64)
            text_list.append(processed_text)
            offsets.append(processed_text.size(0))

        label_list = torch.tensor(label_list, dtype=torch.int64)
        offsets = torch.tensor(offsets[:-1]).cumsum(dim=0)
        text_list = torch.cat(text_list)
        return label_list.to(self.device), text_list.to(self.device), offsets.to(self.device)

    def yield_tokens(self, data_iter):
        for _, text in data_iter:
            yield self.tokenizer(text)

    def predict(self, text):
        with torch.no_grad():
            text = torch.tensor(self.text_pipeline(text))
            output = self.model(text, torch.tensor([0]))
            return output.argmax(1).item() + 1
