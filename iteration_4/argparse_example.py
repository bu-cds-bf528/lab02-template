#!/usr/bin/env python

import argparse

parser = argparse.ArgumentParser(description='Description of your script')
parser.add_argument('-i', dest='input', help='Description of input', required=True)
parser.add_argument('-o', dest='output', help='Description of output', required=True)
args = parser.parse_args()

with open(args.input, 'rt') as f:
    num = f.read()

with open(args.output, 'wt') as w:
    w.write(num)