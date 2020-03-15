#!/usr/bin/env python
from bs4 import BeautifulSoup
import requests
import csv
import json
import sys
import math


def populate_threshold_from_args(*argv):
    data = [0, 100]
    for i, arg in enumerate(argv[0][1:3]):
        data[i] = int(arg)
    return data


def valuable_items_intervals(threshold_min: int, threshold_max: int):
    threshold_min, threshold_max = swap_threshold_if_needed(threshold_min, threshold_max)

    response_ducats = requests.get('https://api.warframe.market/v1/tools/ducats').json()
    ducat_list = response_ducats['payload']['previous_hour']

    wa_all_items = [0] * 15
    counter = 0
    for item in ducat_list:
        # print(json.dumps(item, indent=2))
        wa_all_items[int(item['ducats_per_platinum_wa'] // 1)] += 1

    [print(f'{i}: {x}') for i, x in enumerate(wa_all_items)]

    print(sum(wa_all_items[threshold_min:threshold_max]))


def get_valuable_items(threshold_min: float, threshold_max: float):
    th_min, th_max = swap_threshold_if_needed(threshold_min, threshold_max)

    response_ducats = requests.get('https://api.warframe.market/v1/tools/ducats').json()
    ducat_list = response_ducats['payload']['previous_hour']
    #
    valuable_items = [dict(
                        id=item['item'],
                        val=item['ducats_per_platinum_wa'],
                        ducats=item['ducats'],
                        plat=item['wa_price'])
                      for item in ducat_list
                      if th_min <= float(item['ducats_per_platinum_wa']) <= th_max]

    return valuable_items


def swap_threshold_if_needed(th_min, th_max):
    return [th_min, th_max] if th_min <= th_max else [th_max, th_min]


def get_all_items():
    response_items = requests.get('https://api.warframe.market/v1/items').json()
    return response_items['payload']['items']


def beautiful_json(items: list, indent: int):
    for item in items:
        print(json.dumps(item, indent=indent))


def filter_all_items_by_valuables(ducat_items: list):
    all_items = get_all_items()

    for ducat_item in ducat_items:
        for item in all_items:
            if ducat_item['id'] == item['id']:
                ducat_item['name'] = item['item_name']

    return ducat_items


threshold_min, threshold_max = populate_threshold_from_args(sys.argv)
threshold_min, threshold_max = swap_threshold_if_needed(threshold_min, threshold_max)
print(threshold_min, threshold_max)

val_items = get_valuable_items(threshold_min, threshold_min)

filtered_val_items = filter_all_items_by_valuables(val_items)
filtered_val_items = sorted(filtered_val_items, key=lambda x: (x['name'], x['val']))
print(beautiful_json(filtered_val_items, 2))
print('\n-----------------------------------------------------------------------------------------------------------\n')
filtered_val_items = sorted(filtered_val_items, key=lambda x: (x['val'], x['name']))
print(beautiful_json(filtered_val_items, 2))
print('\n-----------------------------------------------------------------------------------------------------------\n')