#!/usr/bin/env python 
# -*- coding:utf-8 -*-
# @Time     ：2021/9/2 11:06
# @File     ：domain.py
# __author__='admin'
#此脚本是基于这个api进行编写的，注意其不兼用性(https://docs.dnspod.cn/api/5f5629e9e75cf42d25bf6864/)
#运行些脚本前需要准备好对应账号的ID和Token，代换函数里面的对应值

import requests
import json
import sys
import re
import tldextract

headers = {
    "User-Agent": "Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Mobile Safari/537.36"
}


def domain_handle(domain):
    domain = tldextract.extract(domain)
    submain = domain.subdomain
    domain = domain.domain + '.' + domain.suffix
    return submain, domain


def Domain_id(domain, header):
    Url = 'https://dnsapi.cn/Domain.List'
    data = {
        'login_token': 'ID,Token',
        'format': 'json'
    }
    response = requests.post(Url, data=data, headers=header)
    dict_list = response.json()
    dict_list = dict_list['domains']
    for list in dict_list:
        if domain in list['name']:
            return list['id']


def Domain_create(domain_id, submain, IP, headers):
    Url = 'https://dnsapi.cn/Record.Create'
    data = {
        'login_token': 'ID,Token',
        'format': 'json',
        'domain_id': domain_id,
        'sub_domain': submain,
        'record_type': 'A',
        'record_line_id': '10=0',
        'value': IP
    }

    request = requests.post(Url, data=data, headers=headers)


def Record_id(submain, domain, headers, IP):
    Url = 'https://dnsapi.cn/Record.List'
    data = {
        'login_token': 'ID,Token',
        'format': 'json',
        'domain': domain
    }
    request = requests.post(Url, data, headers)
    request = request.json()
    record_list = request['records']
    for list in record_list:
        if IP in list['value']:
            if submain in list['name']:
                return list['id']


def Domain_remove(recrd_id, domain, headers):
    Url = 'https://dnsapi.cn/Record.Remove'

    data = {
        'login_token': 'ID,Token',
        'format': 'json',
        'domain': domain,
        'record_id': recrd_id
    }
    request = requests.post(Url, data=data, headers=headers)


if __name__ == '__main__':
    # 输入传入三个参数，分别为：类型(add、del)，域名，ip地址
    #例如：
    # python domain.py add test.test.com 2.2.2
    # python domain.py del test.test.com 2.2.2

    option = sys.argv[1]
    domain = sys.argv[2]
    IP = sys.argv[3]
    # 处理域名，区分subdomain和domain
    submain,domain = domain_handle(domain)

    if option == 'add':
        domain_id = Domain_id(domain, headers)
        Domain_create(domain_id, submain, IP, headers)
        print(submain+'.'+domain+"域名添加解释成功~")
    elif option == 'del':
        recrd_id = Record_id(submain, domain, headers, IP)
        Domain_remove(recrd_id, domain, headers)
        print(submain + '.' + domain + "域名删除解释成功~")
    else:
        print("传入参数错误，请重新传入")
