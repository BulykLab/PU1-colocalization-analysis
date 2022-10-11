#!/bin/bash
#SBATCH -n 1                              # Request one core
#SBATCH -N 1                               # Request one node (if you request more than one core with -n, also using
                                           # -N 1 means all cores will be on the same node)
#SBATCH -t 0-12:00                         # Runtime in D-HH:MM format
#SBATCH -p short                          # Partition to run in
#SBATCH --mem=16G                          # Memory total in MB (for all cores)
#SBATCH --mail-type=FAIL                    # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=rjeong@g.harvard.edu   # Email to which notifications will be sent
#SBATCH -o coloc%j.out                 # File to which STDOUT will be written, including job ID
#SBATCH -e coloc%j.err                 # File to which STDERR will be written, including job ID

SECONDS=0

#module load gcc/6.2.0
#module load samtools/1.11
module load R/3.6.3


#PRIMARY=$1

#VCF=/n/data2/bch/medicine/bulyk/Raehoon/QTL/PU1/vcf/final
#QTLTOOLS=/n/data2/bch/medicine/bulyk/Raehoon/tools/QTLtools
#PHENO_DIR=/n/data2/bch/medicine/bulyk/Raehoon/QTL/PU1/phenotype/PEER
#GWAS_DIR=/n/data2/bch/medicine/bulyk/Raehoon/GWAS/blood/UKBB/qc/combined
SCRIPT_DIR=/data/bulyk/Raehoon/QTL_o2/coloc_PU1_bloodcell/scripts
OUT_DIR=/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/Coloc/data
DATA_DIR=/data/bulyk/Raehoon/QTL_o2/jlim_PU1_bloodcell

## Loci where JLIM pval < 0.05


#cd ${OUT_DIR}
#mkdir -p ${OUT_DIR}/temp


for PRIMARY in baso_count baso_percentage eosino_count eosino_percentage hb_concentration high_light_scat_ret_count high_light_scat_ret_percentage ht_percentage imm_ret_frac lym_count lym_percentage MCHC MCH MCV mono_count mono_percentage MPV MRV MSCV neut_count neut_percentage plt_count plt_crit plt_dist_width rbc_count rbc_dist_width ret_count ret_percentage wbc_count
do
  while read chr snp pos start end peak trait
  do
    echo $trait $peak
    # run qtltools (nominal) on PU.1 data with +- 200kb


    Rscript ${SCRIPT_DIR}/make_coloc_input.R ${trait} ${peak}

    gzip -f ${OUT_DIR}/GWAS/${trait}_${peak}.gwas_input.txt
    gzip -f ${OUT_DIR}/PU1/${peak}.pu1_input.txt

  done < ${DATA_DIR}/loci/jlim_loci/${PRIMARY}.PU1.jlim.loci.txt
done
#cat ../result/${PRIMARY}_PU1* | sort -V -k7,7V > ../result/${PRIMARY}_PU1.coloc.txt
#rm ../result/${PRIMARY}_PU1_*.txt

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
exit
