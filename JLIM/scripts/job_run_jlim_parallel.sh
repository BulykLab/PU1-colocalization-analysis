#!/bin/bash


DATA_DIR=/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/JLIM/data


SECONDS=0


## Divide up loci by blood cell trait and chromosome
for pheno in baso_count baso_percentage eosino_count eosino_percentage hb_concentration high_light_scat_ret_count high_light_scat_ret_percentage \
  ht_percentage imm_ret_frac lym_count lym_percentage MCHC MCH MCV mono_count mono_percentage MPV MRV MSCV neut_count neut_percentage plt_count \
  plt_crit plt_dist_width rbc_count rbc_dist_width ret_count ret_percentage wbc_count
do
  for i in {1..22}
  do
    chrom=chr$i
    grep -w ${pheno} ${DATA_DIR}/PU1_bloodcell.jlim.loci.txt | grep -w ${chrom} > ${DATA_DIR}/PU1_bloodcell.${pheno}.${chrom}.jlim.loci.txt
    filename=${DATA_DIR}/PU1_bloodcell.${pheno}.${chrom}.jlim.loci.txt

    ## Checking if there is a line in the file
    ## and skipping if the file is empty
    if [ $(wc -l < "$filename") -gt "0" ];
    then
      ## Submitting a job to run JLIM for the chosen blood cell trait and chromosome
      bsub -q normal -R rusage[mem=8000] -n 1 -o output/runJLIM-%J.out -e output/runJLIM-%J.err "bash run_jlim_parallel.sh ${pheno} ${chrom}"
    else
      rm $filename
    fi
  done
done

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
exit
