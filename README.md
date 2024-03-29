# PU1-colocalization-analysis

This repository contains code and data for performing colocalization analysis in <a href="https://www.cell.com/cell-genomics/fulltext/S2666-979X(23)00095-2">Jeong and Bulyk (2023)</a>.
The repository for code to generate figures in the manuscript is <a href="https://github.com/BulykLab/PU1-colocalization-manuscript">here</a>.

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
- Code to reproduce the results are in `JLIM/scripts`. The code takes ~ 2hr for each locus on a computing cluster, and there are 1623 loci. So the repo also includes an example script for parallel job submission.
- Need to install <a href="https://github.com/cotsapaslab/jlim">JLIM</a> to run the code. At this time, JLIM v2.5 is released, and here, we uploaded JLIM v2.0 scripts that can run with JLIM v2.5.

```
cd ${THIS_DIR}/JLIM/scripts

# The code expects R/3.6.3 and python 2.7
# It currently loads a module, but feel free to comment it out
bash job_run_jlim_all_loci.sh  # This might take long

# bash job_run_jlim_parallel.sh  # This submits jlim analysis jobs by blood cell trait and chromosome
```

