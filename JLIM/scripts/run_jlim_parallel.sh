#!/bin/bash




# run_jlim_parallel.sh
# 1. Run Makedosage
# 2. Run runRegression
# 3. Run METAmergecohorts
# 4. Run JLIM



## Modify these directory names as appropriate
JLIM_TOOL_DIR=/data/bulyk/Raehoon/tools/jlim

JLIM_DIR=/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/JLIM
DATA_DIR=${JLIM_DIR}/data

QTL_GENO_DIR=${JLIM_DIR}/data/PU1/geno
QTL_PHENO_DIR=${JLIM_DIR}/data/PU1/pheno

GWAS_OUT_DIR=${JLIM_DIR}/data/GWAS
PU1_OUT_DIR=${JLIM_DIR}/data/PU1
RESULTS_DIR=${JLIM_DIR}/results


SECONDS=0

module load R/3.6.3

# Reading command line arguments
pheno=$1
chrom=$2


while read chr snp pos start end peak trait
do
  echo $peak
  echo $trait
  key=${chr}.${start}.${end}
  echo $key

  # 1. Run Makedosage
  python ${JLIM_DIR}/bin/Makedosage.py 1 ${chr} ${QTL_GENO_DIR}/PU1.${trait}.$key.dosage.gz ${QTL_GENO_DIR}/PU1.$key.data.gz ${QTL_GENO_DIR}/PU1.$key.snps.gz

  # 2. Run runRegression
  python ${JLIM_DIR}/bin/RunRegressions.py ${QTL_GENO_DIR}/PU1.$key.data.gz ${QTL_GENO_DIR}/PU1.$key.snps.gz \
    ${DATA_DIR}/PU1/supp/PU1.samples ${QTL_PHENO_DIR}/$peak.phenotypes ${DATA_DIR}/PU1/supp/PU1.covariates \
    ${PU1_OUT_DIR}/regression/PU1.${trait}.$key 0 100000 ${chr} 1

  # 3. Run METAmergecohorts
  python ${JLIM_DIR}/bin/METAmergecohorts.py 1 ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.assoc.linear.gz ${PU1_OUT_DIR}/regression/PU1.${trait}.$key \
    ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.betas.mperm.dump.all.gz ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.vars.mperm.dump.all.gz

  # Can comment these out if the user wants to inspect these files
  rm ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.assoc.linear.gz
  rm ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.betas.mperm.dump.all.gz
  rm ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.vars.mperm.dump.all.gz

  # 4. Run JLIM
  ${JLIM_DIR}/run_jlim.sh --index-snp ${chr}:${pos} \
    --maintr-file ${DATA_DIR}/GWAS/${trait}.${chr}.${start}.${end}.txt \
    --sectr-file ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.meta.assoc.linear.gz \
    --ref-ld ${DATA_DIR}/ld0/locus.${chr}.${start}.${end}.txt.gz \
    --sectr-ld ${QTL_GENO_DIR}/PU1.${trait}.$key.dosage.gz \
    --perm-file ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.meta.mperm.dump.all.gz \
    --manual-window-boundary ${start}-${end} --output-file ${RESULTS_DIR}/${trait}_${peak}.JLIM.out.txt

  # Can comment these out if the user wants to inspect these files
  rm ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.meta.assoc.linear.gz
  rm ${QTL_GENO_DIR}/PU1.${trait}.$key.dosage.gz
  rm ${QTL_GENO_DIR}/PU1.$key.merge1.positions.npy
  rm ${PU1_OUT_DIR}/regression/PU1.${trait}.$key.meta.mperm.dump.all.gz


done < ${DATA_DIR}/PU1_bloodcell.${pheno}.${chrom}.jlim.loci.txt

rm ${DATA_DIR}/PU1_bloodcell.${pheno}.${chrom}.jlim.loci.txt

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
exit
