library(coloc, quietly=TRUE)
library(argparser, quietly=TRUE)

p <- arg_parser("Run coloc")
p <- add_argument(p, "trait", help="")
p <- add_argument(p, "peak", help="")

argv <- parse_args(p)

## Reading GWAS data
gwas_for_coloc <- read.csv(gzfile(paste('/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/Coloc/data/GWAS/',argv$trait,'_',argv$peak,'.gwas_input.txt.gz', sep='')), header=T, sep='\t', stringsAsFactors=F)

# Removing any duplicate variant positions
gwas_for_coloc <- as.list(na.omit(gwas_for_coloc[!duplicated(gwas_for_coloc$position), ]))

# Setting required parameters
gwas_for_coloc$type <- "quant"
gwas_for_coloc$sdY <- 1


## Reading PU.1 bQTL data
bqtl_for_coloc <- read.csv(gzfile(paste('/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/Coloc/data/PU1/',argv$peak,'.pu1_input.txt.gz', sep='')), header=T, sep='\t', stringsAsFactors=F)

# Removing any duplicate variant positions
bqtl_for_coloc <- as.list(na.omit(bqtl_for_coloc[!duplicated(bqtl_for_coloc$position), ]))

# Setting required parameters
bqtl_for_coloc$type <- "quant"
bqtl_for_coloc$sdY <- 1


## Running Coloc with p12 = 1e-6 to be conservative
coloc.res <- coloc.abf(dataset1 = gwas_for_coloc, dataset2 = bqtl_for_coloc, p12 = 1e-6)

final <- coloc.res$summary
final["peak"] <- argv$peak
final["trait"] <- argv$trait
final <- t(final)

# Writing the result to file
write.table(final, paste('/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/Coloc/results/',argv$trait,'_',argv$peak,'.coloc.txt', sep=''), sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE)
