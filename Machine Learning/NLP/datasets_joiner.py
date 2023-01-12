import os
import json
import random
from collections import namedtuple
from enum import Enum


class Review:
    def __init__(self, text: str, label: str, score: int):
        self.text = text
        self.label = label
        self.score = score

    def __str__(self):
        return str(self.label) + " " + str(self.score) + " " + str(self.text)

    def to_json(self):
        return json.dumps(self, default=lambda o: o.__dict__)


class Label(Enum):
    POSITIVE = "pos"
    NEGATIVE = "neg"
    NEUTRAL = "neu"

    def resolve_score(self) -> int:
        if self.name == self.NEGATIVE.name:
            return 1
        elif self.name == self.NEUTRAL.name:
            return 2
        else:
            return 3


def reviews_decoder(reviews_dict):
    return namedtuple('X', reviews_dict.keys())(*reviews_dict.values())


directory = 'ToJoin'
reviews_array = []

number_of_reviews = {
    Label.POSITIVE: 0,
    Label.NEUTRAL: 0,
    Label.NEGATIVE: 0
}

for filename in os.listdir(directory):
    f = os.path.join(directory, filename)
    if os.path.isfile(f):
        with open(f, 'r') as infile:
            reviews = json.loads(infile.readline())
            for review in reviews:
                label = Label(review['label'])
                reviews_array.append(Review(review['text'], str(label.value), label.resolve_score()))
                number_of_reviews[label] += 1

print("Number of reviews:")
print("positive : {} \nneutral: {} \nnegative: {} \nall: {}"
      .format(number_of_reviews[Label.POSITIVE], number_of_reviews[Label.NEUTRAL],
              number_of_reviews[Label.NEGATIVE], sum(number_of_reviews.values())))

print(f'Sum {len(reviews_array)}')

random.shuffle(reviews_array)

with open("all_reviews.json", 'w') as outfile:
    json.dump(reviews_array, outfile, default=vars, ensure_ascii=False)


