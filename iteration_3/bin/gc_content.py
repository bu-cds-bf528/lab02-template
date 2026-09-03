#!/usr/bin/env python

from Bio import SeqIO
from Bio.SeqUtils import gc_fraction
import gzip

with gzip.open("GCF_000005845.2_ASM584v2_genomic.fna.gz", 'rt') as f:
    record = SeqIO.read(f, 'fasta')

with open('gc_content.txt', 'wt') as w:
    w.write(f"{gc_fraction(record.seq)}")