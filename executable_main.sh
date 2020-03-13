#!/usr/bin/env python
from bs4 import BeautifulSoup
import requests
import csv
import json
import sys


def valuable_items_intervals():
    response_ducats = requests.get('https://api.warframe.market/v1/tools/ducats').json()
    ducat_list = response_ducats['payload']['previous_hour']

    wa_all_items = [0] * 15
    counter = 0
    for item in ducat_list:
        # print(json.dumps(item, indent=2))
        wa_all_items[int(item['ducats_per_platinum_wa'] // 1)] += 1

    [print(f'{i}: {x}') for i, x in enumerate(wa_all_items)]

    print(sum(wa_all_items[7:]))


def get_valuable_items(threshold_min: int):
    response_ducats = requests.get('https://api.warframe.market/v1/tools/ducats').json()
    ducat_list = response_ducats['payload']['previous_hour']
    #
    valuable_items = [dict(
                        id=item['item'],
                        val=item['ducats_per_platinum_wa'],
                        ducats=item['ducats'],
                        plat=item['wa_price'])
                      for item in ducat_list
                      if int(item['ducats_per_platinum_wa']) // 1 >= threshold_min]
    return valuable_items


def get_all_items():
    response_items = requests.get('https://api.warframe.market/v1/items').json()
    return response_items['payload']['items']


def beautiful_json(items: list, indent: int):
    for item in items:
        print(json.dumps(item, indent=indent))


def filter_all_items_by_list(ducat_items: list):
    all_items = get_all_items()

    for ducat_item in ducat_items:
        for item in all_items:
            if ducat_item['id'] == item['id']:
                ducat_item['name'] = item['item_name']

    return ducat_items


threshold = int(sys.argv[1]) if len(sys.argv) == 2 else 7
val_items = get_valuable_items(threshold)

filtered_val_items = filter_all_items_by_list(val_items)
filtered_val_items = sorted(filtered_val_items, key=lambda x: (x['name'], x['val']))
print(beautiful_json(filtered_val_items, 2))
