#!/usr/bin/env python

import argparse
from Bio import SeqIO
from Bio.SeqUtils import gc_fraction
import gzip

parser = argparse.ArgumentParser(description='Description of your script')
parser.add_argument('-i', dest='input', help='Description of input', required=True)
parser.add_argument('-g', dest='gc_content', help='Name of output file containing the GC content', required=True)
parser.add_argument('-l', dest='length', help='Name of the output file containing the length', required=True)
args = parser.parse_args()

with open(args.input, 'rt') as f:
    record = SeqIO.read(f, 'fasta')

with open(args.gc_content, 'wt') as w:
    
    w.write(f"The GC fraction is: {gc_fraction(record.seq)}")

with open(args.length, 'wt') as w:
    w.write(f"The length is: {len(record.seq)}")