#!/usr/bin/env python

import gzip

with gzip.open('GCF_000005845.2_ASM584v2_genomic.fna.gz', 'rt') as f:
    sequence = ''.join(line.strip() for line in f if not line.startswith('>'))

print(len(sequence))