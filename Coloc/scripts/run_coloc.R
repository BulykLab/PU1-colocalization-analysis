library(coloc, quietly=TRUE)
library(argparser, quietly=TRUE)

WriteTable <- function(data, filename, index.name) {
    datafile <- file(filename, open = "wt")
    on.exit(close(datafile))
    #header <- c(index.name, colnames(data))
    #writeLines(paste0(header, collapse="\t"), con=datafile, sep="\n")
    write.table(data, datafile, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE)
}


p <- arg_parser("Run coloc")
p <- add_argument(p, "trait", help="")
p <- add_argument(p, "peak", help="")
#p <- add_argument(p, "n", help="Number of hidden confounders to estimate")
#p <- add_argument(p, "--covariates", help="Observed covariates")
#p <- add_argument(p, "--alphaprior_a", help="", default=0.001)
#p <- add_argument(p, "--alphaprior_b", help="", default=0.01)
#p <- add_argument(p, "--epsprior_a", help="", default=0.1)
#p <- add_argument(p, "--epsprior_b", help="", default=10)
#p <- add_argument(p, "--max_iter", help="", default=1000)
#p <- add_argument(p, "--output_dir", short="-o", help="Output directory", default=".")
argv <- parse_args(p)

gwas_for_coloc <- read.csv(gzfile(paste('/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/Coloc/data/GWAS/',argv$trait,'_',argv$peak,'.gwas_input.txt.gz', sep='')), header=T, sep='\t', stringsAsFactors=F)
#colnames(gwas) <- c("chr", "position", "A1", "A2", "MAF", "HWE-P", "iscore", "snp", "beta", "se", "p")
#gwas["varbeta"] <- gwas$se^2
#gwas_for_coloc <- as.list(gwas[c("beta", "varbeta", "snp", "position")])
gwas_for_coloc <- as.list(gwas_for_coloc[!duplicated(gwas_for_coloc$snp), ])
gwas_for_coloc$type <- "quant"
gwas_for_coloc$sdY <- 1

#gwas.res <- finemap.abf(dataset = gwas_for_coloc)

bqtl_for_coloc <- read.csv(gzfile(paste('/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/Coloc/data/PU1/',argv$peak,'.pu1_input.txt.gz', sep='')), header=T, sep='\t', stringsAsFactors=F)
#colnames(bqtl) <- c("peakname", "chr", "start", "end", "strand", "numsnp", "distance", "snp", "chr2", "position", "position_end", "p", "beta", "lead")
#bqtl["varbeta"] <- (bqtl$beta/qnorm(bqtl$p/2, lower.tail = FALSE))^2
#bqtl_for_coloc <- as.list(bqtl[c("beta", "varbeta", "snp", "position")])
bqtl_for_coloc <- as.list(bqtl_for_coloc[!duplicated(bqtl_for_coloc$snp), ])
bqtl_for_coloc$type <- "quant"
bqtl_for_coloc$sdY <- 1
#bqtl.res <- finemap.abf(dataset = bqtl_for_coloc)

coloc.res <- coloc.abf(dataset1 = gwas_for_coloc, dataset2 = bqtl_for_coloc, p12 = 1e-6)

final <- coloc.res$summary
final["peak"] <- argv$peak
final["trait"] <- argv$trait
final <- t(final)
#final <- cbind(argv$trait, argv$peak, coloc.res$summary)

write.table(final, paste('/data/bulyk/Raehoon/QTL_o2/PU1-colocalization-analysis/Coloc/results/',argv$trait,'_',argv$peak,'.coloc.txt', sep=''), sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE)
