#!/bin/bash

# default build
# https://www.ncbi.nlm.nih.gov/books/NBK279671/#introduction.Source_tarball
cd {{ tmpdr }}
tar zxf download
cd ncbi-blast-{{ version }}+

for i in $( ls ); do
  mv $i {{ lbpth }}
done
