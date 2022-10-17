#!/bin/bash


# run_jlim_second (together)
# 1. Run Makedosage
# 2. Run runRegression
# 3. Run METAmergecohorts
# 4. Run JLIM




SECONDARY=PU1
## Modify these directory names as appropriate
JLIM_DIR=/data/bulyk/Raehoon/tools/jlim


DATA_DIR=/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/JLIM/data

QTL_GENO_DIR=/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/JLIM/data/PU1/geno
QTL_PHENO_DIR=/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/JLIM/data/PU1/pheno

GWAS_OUT_DIR=/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/JLIM/data/GWAS
PU1_OUT_DIR=/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/JLIM/data/PU1
RESULTS_DIR=/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/JLIM/results



SECONDS=0


module load R/3.6.3

while read chr snp pos start end peak trait
do
  echo $peak
  echo $trait
  key=${chr}.${start}.${end}
  echo $key

  # 1. Run Makedosage
  python ${JLIM_DIR}/bin/Makedosage.py 1 ${chr} ${QTL_GENO_DIR}/PU1.$key.dosage.gz ${QTL_GENO_DIR}/PU1.$key.data.gz ${QTL_GENO_DIR}/PU1.$key.snps.gz

  # 2. Run runRegression
  python ${JLIM_DIR}/bin/RunRegressions.py ${QTL_GENO_DIR}/PU1.$key.data.gz ${QTL_GENO_DIR}/PU1.$key.snps.gz \
    ${DATA_DIR}/PU1/supp/PU1.samples ${QTL_PHENO_DIR}/$peak.phenotypes ${DATA_DIR}/PU1/supp/PU1.covariates \
    ${PU1_OUT_DIR}/regression/PU1.$key 0 100000 ${chr} 1

  # 3. Run METAmergecohorts
  python ${JLIM_DIR}/bin/METAmergecohorts.py 1 ${PU1_OUT_DIR}/regression/PU1.$key.assoc.linear.gz ${PU1_OUT_DIR}/regression/PU1.$key \
    ${PU1_OUT_DIR}/regression/PU1.$key.betas.mperm.dump.all.gz ${PU1_OUT_DIR}/regression/PU1.$key.vars.mperm.dump.all.gz

  # Can comment these out if the user wants to inspect these files
  rm ${PU1_OUT_DIR}/regression/PU1.$key.assoc.linear.gz
  rm ${PU1_OUT_DIR}/regression/PU1.$key.betas.mperm.dump.all.gz
  rm ${PU1_OUT_DIR}/regression/PU1.$key.vars.mperm.dump.all.gz

  # 4. Run JLIM
  ${JLIM_DIR}/run_jlim.sh --index-snp ${chr}:${pos} \
    --maintr-file ${DATA_DIR}/GWAS/${trait}.${chr}.${start}.${end}.txt \
    --sectr-file ${PU1_OUT_DIR}/regression/PU1.$key.meta.assoc.linear.gz \
    --ref-ld ${DATA_DIR}/ld0/locus.${chr}.${start}.${end}.txt.gz \
    --sectr-ld ${QTL_GENO_DIR}/PU1.$key.dosage.gz \
    --perm-file ${PU1_OUT_DIR}/regression/PU1.$key.meta.mperm.dump.all.gz \
    --manual-window-boundary ${start}-${end} --output-file ${RESULTS_DIR}/${trait}_${peak}.JLIM.out.txt

  # Can comment these out if the user wants to inspect these files
  rm ${PU1_OUT_DIR}/regression/PU1.$key.meta.assoc.linear.gz
  rm ${QTL_GENO_DIR}/PU1.$key.dosage.gz
  rm ${PU1_OUT_DIR}/regression/PU1.$key.meta.mperm.dump.all.gz

done < ${DATA_DIR}/PU1_bloodcell.jlim.loci.txt


duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
exit
