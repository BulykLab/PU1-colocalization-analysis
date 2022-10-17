# PU1-colocalization-analysis

This repository contains code and data for performing colocalization analysis in Jeong and Bulyk (in prep).

Raehoon Jeong (rjeong@g.harvard.edu), Martha Bulyk Lab (mlbulyk@genetics.med.harvard.edu).


## Coloc
- GWAS summary statistics and PU.1 bQTL data for tested loci are in `Coloc/data`.
- Coloc results are in `Coloc/results`.
- Code to reproduce the results are in `Coloc/scripts`. The code took ~1.5 hr to run on a computing cluster.
- Need to install <a href="https://github.com/chr1swallace/coloc">Coloc</a> to run the code.

```
cd ${THIS_DIR}/Coloc/scripts

# The code expects R/3.6.3
# It currently loads a module, but feel free to comment it out
bash job_run_coloc.sh 
```

## JLIM
- GWAS summary statistics and PU.1 phenotype and genotype data for tested loci are in `JLIM/data`.
- JLIM results are in `JLIM/results`.
- Code to reproduce the results are in `JLIM/scripts`. The code takes ~ 1hr for each locus, and there are 1623 loci.
- Need to install <a href="https://github.com/cotsapaslab/jlim">JLIM</a> to run the code. At this time, JLIM v2.5 is released, but we used JLIM v2.0 scripts. The uploaded code can run on JLIM v2.5.

```
cd ${THIS_DIR}/JLIM/scripts

# The code expects R/3.6.3 and pythone 2.7
# It currently loads a module, but feel free to comment it out
bash job_run_jlim_all_loci.sh
```

