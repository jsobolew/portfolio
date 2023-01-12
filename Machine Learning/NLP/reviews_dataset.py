from typing import Union, Tuple

from torch.utils.data import functional_datapipe, IterDataPipe
from torchtext.data.datasets_utils import _wrap_split_argument
from torchdata.datapipes.iter import IterableWrapper, FileOpener

NUM_LINES = {
    "train": 7476,
    "test": 3000,
}


@_wrap_split_argument(("train", "test"))
def reviews(root: str, split: Union[Tuple[str], str]):
    dp = IterableWrapper([root])
    dp = FileOpener(dp, mode='b')
    dp = dp.parse_json_files()
    return dp.read_dataset().shuffle().set_shuffle(False).sharding_filter()


@functional_datapipe("read_dataset")
class ReviewsCustomDataset(IterDataPipe):

    def __getitem__(self, index) -> None:
        pass

    def __init__(self, source_datapipe) -> None:
        self.source_datapipe = source_datapipe

    def __iter__(self):
        for _, raw_json_data in self.source_datapipe:
            for element in raw_json_data:
                if element['label'] == 'neg':
                    yield 0, element['text']
                elif element['label'] == 'neu':
                    yield 1, element['text']
                else:
                    yield 2, element['text']
