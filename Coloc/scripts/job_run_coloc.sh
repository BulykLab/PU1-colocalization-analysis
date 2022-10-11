#!/bin/bash

SECONDS=0

module load R/3.6.3



while read peak trait
do
  echo $trait $peak

  Rscript run_coloc.R ${trait} ${peak}

done < ../data/Coloc.loci.txt

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
exit
