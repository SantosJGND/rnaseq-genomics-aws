#!/bin/bash

ENTREZ_BINDIR=/usr/bin
SRATOOLKIT_BIN=/path/to/sratoolkit.3.3.0-ubuntu64
OUTPUT_DIR=test_data

BIOPROJECT=PRJNA912208

## download only a subset of reads for testing
## use -N 1000000 -X 1100000 to specify the range of reads to be downloaded

esearch -db sra -query $BIOPROJECT | \
efetch -format runinfo | \
cut -d ',' -f 1 | \
grep SRR | \
xargs $SRATOOLKIT_BIN/bin/fastq-dump \
-N 1000000 \
-X 1100000 \
--split-files --gzip -O $OUTPUT_DIR