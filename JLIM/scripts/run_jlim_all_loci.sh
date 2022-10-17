#!/bin/bash
#SBATCH -n 1                              # Request one core
#SBATCH -N 1                               # Request one node (if you request more than one core with -n, also using
                                           # -N 1 means all cores will be on the same node)
#SBATCH -t 0-12:00                         # Runtime in D-HH:MM format
#SBATCH -p short                           # Partition to run in
#SBATCH --mem=16G                          # Memory total in MB (for all cores)
#SBATCH -o run_jlim%j.out                 # File to which STDOUT will be written, including job ID
#SBATCH -e run_jlim%j.err                 # File to which STDERR will be written, including job ID

# prepare_jlim
# 0. Create bimbam and map files
# 1. Create indexSNP.tsv for ATAC
# 2. Create loci.chr.txt


# run_jlim_first (parallelize)
# 3. Run genLDfiles
# 4. Run cutbimbam
# 5. Create phenotypes file for PU.1
# 6. Create association stat file for ATAC

# run_jlim_second (together)
# 7. Run Makedosage
# 8. Run runRegression
# 9. Run METAmergecohorts
# 10. Run JLIM




SECONDARY=PU1
JLIM_DIR=/data/bulyk/Raehoon/tools/jlim
PRIMARY_DIR=/data/bulyk/Raehoon/QTL_o2/jlim_PU1_bloodcell/bloodcell
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

  # 7. Run Makedosage
  python ${JLIM_DIR}/bin/Makedosage.py 1 ${chr} ${QTL_GENO_DIR}/PU1.$key.dosage.gz ${QTL_GENO_DIR}/PU1.$key.data.gz ${QTL_GENO_DIR}/PU1.$key.snps.gz

  # 8. Run runRegression
  python ${JLIM_DIR}/bin/RunRegressions.py ${QTL_GENO_DIR}/PU1.$key.data.gz ${QTL_GENO_DIR}/PU1.$key.snps.gz \
    ${DATA_DIR}/PU1/supp/PU1.samples ${QTL_PHENO_DIR}/$peak.phenotypes ${DATA_DIR}/PU1/supp/PU1.covariates \
    ${PU1_OUT_DIR}/regression/PU1.$key 0 100000 ${chr} 1

  # 9. Run METAmergecohorts
  python ${JLIM_DIR}/bin/METAmergecohorts.py 1 ${PU1_OUT_DIR}/regression/PU1.$key.assoc.linear.gz ${PU1_OUT_DIR}/regression/PU1.$key \
    ${PU1_OUT_DIR}/regression/PU1.$key.betas.mperm.dump.all.gz ${PU1_OUT_DIR}/regression/PU1.$key.vars.mperm.dump.all.gz

  # Can comment these out if the user wants to inspect these files
  rm ${PU1_OUT_DIR}/regression/PU1.$key.assoc.linear.gz
  rm ${PU1_OUT_DIR}/regression/PU1.$key.betas.mperm.dump.all.gz
  rm ${PU1_OUT_DIR}/regression/PU1.$key.vars.mperm.dump.all.gz

  # 10. Run JLIM
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
