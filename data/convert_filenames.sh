#!/bin/bash

### Script specific to project PRJNA912208
### Convert fastq files with _3.fastq.gz and _4.fastq.gz to _R1.fastq.gz and _R2.fastq.gz respectively
### take directory as argument

if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

cd "$1" || exit

for file in *_3.fastq.gz; do
    mv "$file" "${file/_3/_R1}"
done

for file in *_4.fastq.gz; do
    mv "$file" "${file/_4/_R2}"
done