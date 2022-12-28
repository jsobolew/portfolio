from enum import Enum
import openpyxl
import json
import argparse

from math import floor

PROCESSED_DATASETS_FOLDER = "ProcessedDatasets/"


class Label(Enum):
    POSITIVE = "pos"
    NEGATIVE = "neg"


class Review:
    def __init__(self, text: str, label: str):
        self.text = text
        self.label = label

    def __str__(self):
        return str(self.label) + " " + str(self.text)

    def to_json(self):
        return json.dumps(self, default=lambda o: o.__dict__)


def restricted_float(x):
    try:
        x = float(x)
    except ValueError:
        raise argparse.ArgumentTypeError("%r not a floating-point literal" % (x,))

    if x < 0.0 or x > 1.0:
        raise argparse.ArgumentTypeError("%r not in range [0.0, 1.0]" % (x,))
    return x


def resolve_label(score_and_max: str) -> str:
    scores_str = score_and_max \
        .replace(",", ".") \
        .split("/")

    max_score = int(scores_str[1])
    score = float(scores_str[0])

    if score <= 0 or score > max_score:
        raise Exception("Invalid scores")

    return Label.NEGATIVE.value if score < max_score / 2 else Label.POSITIVE.value


def parse_reviews_from_excel(file_name: str) -> [Review]:
    reviews: [Review] = []

    file = openpyxl.load_workbook(file_name, data_only=True).active
    number_of_positive_reviews = 0

    for row in file.iter_rows(min_row=2, min_col=2, max_col=3):
        label = resolve_label(row[1].value)
        number_of_positive_reviews += 1 if label == 'pos' else 0
        review_description = row[0].value \
            .replace("\n", " ") \
            .replace("<br>", " ") \
            .replace("</br>", " ") \
            .replace("<br/>", " ")

        reviews.append(Review(review_description, label))

    number_of_reviews = len(reviews)
    number_of_negative_reviews = number_of_reviews - number_of_positive_reviews
    print("Number of reviews:")
    print("positive : {} \nnegative: {} \nall: {}"
          .format(number_of_positive_reviews, number_of_negative_reviews, number_of_reviews))
    return reviews


def save_as_json(reviews: [Review], json_file_name: str):
    with open(PROCESSED_DATASETS_FOLDER + json_file_name, "w") as outfile:
        json.dump(reviews, outfile, default=vars, ensure_ascii=False)


def create_train_and_test_datasets(reviews: [Review], train_test_ratio: float, result_files_prefix: str):
    train_limit_index = floor(len(reviews) * train_test_ratio)

    if result_files_prefix is not None:
        result_files_prefix.join("_")

    train_file_name = result_files_prefix + "train_reviews.json"
    save_as_json(reviews[:train_limit_index], train_file_name)
    print("Saved train file as {}".format(train_file_name))

    test_file_name = result_files_prefix + "test_reviews.json"
    save_as_json(reviews[train_limit_index:], test_file_name)
    print("Saved test file as {}".format(test_file_name))


def create_datasets(reviews: [Review], result_files_prefix: str):
    if result_files_prefix is not None:
        result_files_prefix.join("_")

    file_name = result_files_prefix + "reviews.json"
    save_as_json(reviews, file_name)
    print("Saved dataset file as {}".format(file_name))


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--dataset", help="Dataset file path", required=True)
    parser.add_argument("-p", "--prefix", help="Prefix of created json files")
    parser.add_argument("-r", "--ratio", help="Dataset train to test ratio if data is to divide", type=restricted_float,
                        metavar="[0.0-1.0]", default=0.5)
    parser.add_argument("-s", "--split", help="If present data will be split into train and test datasets")
    args = parser.parse_args()

    if args.dataset:
        print("Dataset file: {}".format(args.dataset))
        parsed_reviews = parse_reviews_from_excel(args.dataset)
        prefix = "" if args.prefix is None else args.prefix

        if args.split:
            ratio = 0.5 if args.ratio is None else args.ratio
            create_train_and_test_datasets(parsed_reviews, ratio, prefix)
        else:
            create_datasets(parsed_reviews, prefix)
