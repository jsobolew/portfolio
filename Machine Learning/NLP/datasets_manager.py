import random
import openpyxl
import json
import argparse
import pickle

from enum import Enum
from time import sleep
from typing import Tuple, List

from bs4 import BeautifulSoup
from math import floor, ceil
from selenium import webdriver
from selenium.common.exceptions import WebDriverException

PROCESSED_DATASETS_FOLDER = "ProcessedDatasets/"


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


class Review:
    def __init__(self, text: str, label: str, score: int):
        self.text = text
        self.label = label
        self.score = score

    def __str__(self):
        return str(self.label) + " " + str(self.score) + " " + str(self.text)

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


def resolve_label(score_and_max: str) -> Label:
    scores_str = score_and_max \
        .replace(",", ".") \
        .split("/")

    max_score = int(scores_str[1])
    score = float(scores_str[0])

    if score < 0 or score > max_score:
        raise Exception("Invalid scores")

    if score <= max_score / 2.5:
        return Label.NEGATIVE
    elif max_score / 2 <= score <= max_score / 1.4:
        return Label.NEUTRAL
    else:
        return Label.POSITIVE


def parse_reviews_from_excel(file_name: str) -> [Review]:
    reviews: [Review] = []

    file = openpyxl.load_workbook(file_name, data_only=True).active
    number_of_reviews = {
        Label.POSITIVE: 0,
        Label.NEUTRAL: 0,
        Label.NEGATIVE: 0
    }

    for row in file.iter_rows(min_row=2, min_col=2, max_col=3):
        label = resolve_label(row[1].value)
        number_of_reviews[label] += 1
        review_description = row[0].value \
            .replace("\n", " ") \
            .replace("<br>", " ") \
            .replace("</br>", " ") \
            .replace("<br/>", " ")

        reviews.append(Review(review_description, str(label.value)))

    number_of_all_reviews = len(reviews)
    print("Number of reviews:")
    print("positive : {} \nneutral: {} \nnegative: {} \nall: {}"
          .format(number_of_reviews[Label.POSITIVE], number_of_reviews[Label.NEUTRAL],
                  number_of_reviews[Label.NEGATIVE], number_of_all_reviews))
    return reviews


def find_products_id(urls_with_pages: List[Tuple[str, int]]) -> List[str]:
    product_ids = set()

    for base_url, pages_limit in urls_with_pages:
        print(base_url)
        for i in range(0, pages_limit + 1):
            url = f"{base_url}{i}.htm"

            try:
                page_content = get_page(url)
            except WebDriverException:
                print("Error")
                continue

            soup = BeautifulSoup(page_content, 'html.parser')

            for div in soup.select('div[class*="cat-prod-box js"]'):
                pid = div.get('data-productid')
                product_ids.add(pid)

            for div in soup.select('div[class*="cat-prod-box last"]'):
                pid = div.get('data-productid')
                product_ids.add(pid)

            for div in soup.select('div[class*="cat-prod-row js"]'):
                pid = div.get('data-productid')
                product_ids.add(pid)

            for div in soup.select('div[class*="-prod-row js"]'):
                pid = div.get('data-productid')
                product_ids.add(pid)

            print(f"Visited {url}")

    with open('pids.txt', 'w') as f:
        for pid in product_ids:
            f.write(f"{pid}\n")

    return list(product_ids)


def get_page(url: str) -> str:
    user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.50 Safari/537.36'
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument(f'--user-agent="{user_agent}"')
    driver = webdriver.Chrome(options=chrome_options)
    driver.get(url)

    cookies = pickle.load(open("cookies.pkl", "rb"))
    for cookie in cookies:
        driver.add_cookie(cookie)
    # pickle.dump(driver.get_cookies(), open("cookies.pkl", "wb")) # sometimes you have to invoke it for new cookies
    curr_url = driver.current_url

    if "Captcha" in curr_url:
        driver.get(url)
        cookies = pickle.load(open("cookies.pkl", "rb"))
        for cookie in cookies:
            driver.add_cookie(cookie)

        print(f'After captcha: {curr_url}')

    return driver.page_source


class OpinionsInfo:
    def __init__(self, pid: str, opinions_count: int, pages_count: int):
        self.pid = pid
        self.opinions_count = opinions_count
        self.pages_count = pages_count


def get_number_of_opinions_for_products(products_ids: List[str]) -> [Review]:
    print('Getting reviews')
    print(f'Pids number: {len(products_ids)}')

    found_opinons_info = []

    with open('products.txt', 'w') as f:
        for pid in products_ids:

            url = f"https://www.ceneo.pl/{pid}/opinie-1"

            sleep(1 + random.uniform(-0.5, 0.5))
            try:
                page_content = get_page(url)
            except WebDriverException:
                print(f'Not worked for {pid}')
                continue

            soup = BeautifulSoup(page_content, 'html.parser')

            try:
                number_of_reviews = int(soup.find('div', class_='score-extend__review').getText().strip().split()[0])
                number_of_pages = ceil(number_of_reviews / 10)
                f.write(f'PID {pid} PRODS {number_of_reviews} PAGES {number_of_pages}\n')
                print(f'PID {pid} PRODS {number_of_reviews} PAGES {number_of_pages}')
                found_opinons_info.append(OpinionsInfo(pid, number_of_reviews, number_of_pages))
            except AttributeError:
                print(f"No opinions for product {pid}")
                continue

    return found_opinons_info


def get_review(reviews_info: [OpinionsInfo]) -> [Review]:
    number_of_reviews = {
        Label.POSITIVE: 0,
        Label.NEUTRAL: 0,
        Label.NEGATIVE: 0
    }

    found_reviews = []

    for review_info in reviews_info:
        for i in range(1, review_info.pages_count + 1):
            sleep(7 + random.uniform(-0.5, 0.5))
            url = f"https://www.ceneo.pl/{review_info.pid}/opinie-{i}"
            try:
                page_content = get_page(url)
            except WebDriverException:
                print(f'Not worked for {review_info.pid}')
                continue

            soup = BeautifulSoup(page_content, 'html.parser')

            if len(soup.select('div[class*="user-post__content"]')) == 0:
                print(f"Reviews not found for {review_info.pid}")

            for review in soup.select('div[class*="user-post__content"]'):
                try:
                    text = review.find("div", {"class": "user-post__text"}).getText().strip()
                    score = resolve_label(review.find("span", {"class": "user-post__score-count"}).getText().strip())
                    number_of_reviews[score] += 1
                    found_reviews.append(Review(text, str(score.value), score.resolve_score()))
                except AttributeError:
                    continue

            print(f"Visited {url}")

    print("Number of reviews:")
    print("positive : {} \nneutral: {} \nnegative: {} \nall: {}"
          .format(number_of_reviews[Label.POSITIVE], number_of_reviews[Label.NEGATIVE],
                  number_of_reviews[Label.NEUTRAL], sum(number_of_reviews.values())))

    return found_reviews


def create_train_and_test_datasets(reviews_to_save: [Review], train_test_ratio: float, result_files_prefix: str):
    train_limit_index = floor(len(reviews_to_save) * train_test_ratio)

    if result_files_prefix is not None:
        result_files_prefix.join("_")

    train_file_name = result_files_prefix + "train_reviews.json"
    save_as_json(reviews_to_save[:train_limit_index], train_file_name)
    print("Saved train file as {}".format(train_file_name))

    test_file_name = result_files_prefix + "test_reviews.json"
    save_as_json(reviews_to_save[train_limit_index:], test_file_name)
    print("Saved test file as {}".format(test_file_name))


def create_dataset(reviews_to_save: [Review], result_files_prefix: str):
    if result_files_prefix is not None:
        result_files_prefix.join("_")

    file_name = result_files_prefix + "reviews.json"
    save_as_json(reviews_to_save, file_name)
    print("Saved dataset file as {}".format(file_name))


def save_as_json(reviews_to_save: [Review], json_file_name: str):
    with open(PROCESSED_DATASETS_FOLDER + json_file_name, "w") as outfile:
        json.dump(reviews_to_save, outfile, default=vars, ensure_ascii=False)


def get_pids_from_file(file_name: str) -> List[str]:
    print(f"Pids from file {file_name}")
    with open(file_name, 'r') as file:
        raw = file.readlines()
    return [line.strip() for line in raw]


def get_reviews_info_from_file(file_name: str) -> List[OpinionsInfo]:
    print(f"Reviews info from file {file_name}")
    with open(file_name, 'r') as file:
        raw = file.readlines()
    return [OpinionsInfo(line.split()[1], int(line.split()[3]), int(line.split()[5])) for line in raw]


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--prefix", help="Prefix of created json files")
    parser.add_argument("-r", "--ratio", help="Dataset train to test ratio if data is to divide", type=restricted_float,
                        metavar="[0.0-1.0]", default=0.7)
    parser.add_argument("-s", "--split", help="If present data will be split into train and test datasets")
    parser.add_argument("-f", "--pids", help="If present data list of pids will be loaded from given file")
    parser.add_argument("-o", "--reviews", help="If present data list of reviews info will be loaded from given file")
    args = parser.parse_args()

    urls_and_pages = [
        ('https://www.ceneo.pl/Termosy_i_kubki/Rodzaj:Kubki;0020-30-0-0-', 49),
        ('https://www.ceneo.pl/Tabletki_do_zmywarki;0020-30-0-0-', 23),
        ('https://www.ceneo.pl/Proszki_do_prania/Zastosowanie:Do_prania_kolorowego;0191;0020-30-0-0-', 11)]

    prefix = "" if args.prefix is None else args.prefix

    if args.reviews:
        reviews_info = get_reviews_info_from_file(args.reviews)
    else:
        pids = find_products_id(urls_and_pages) if not args.pids else get_pids_from_file(args.pids)
        reviews_info = get_number_of_opinions_for_products(pids)

    reviews = get_review(reviews_info)
    create_dataset(reviews, prefix)

    if args.split:
        ratio = 0.7 if args.ratio is None else args.ratio
        create_train_and_test_datasets(reviews, ratio, prefix)
