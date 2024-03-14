# parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
	stop("\n\nUsage: Rscript /projects/enviro_lab/decon_compare/lineagespot/scripts/run_lineagespot.R vcf gff\n",
		"  variant:  name of lineage to download\n\n")
}
require(lineagespot)

vcf <- args[1]
outfile <- args[2]
# q()
# gff <- args[3]

# Run lineagespot
# # use installed lineagespot package
# if (! require(lineagespot)) {
#     devtools::install_github("BiodataAnalysisGroup/lineagespot")
# }

# use lineagepot files instead
# file.sources = list.files(c("/projects/enviro_lab/software/lineagespot/R/"), 
#                           pattern="*.R$", full.names=TRUE, 
#                           ignore.case=TRUE)
# sapply(file.sources,source,.GlobalEnv)

# require(VariantAnnotation)
# require(MatrixGenerics)
# require(SummarizedExperiment)
# require(data.table)
# # require(stringr) # DO NOT USE THIS
# require(httr)
# require(utils)
# source("/projects/enviro_lab/software/lineagespot/R/lineagespot.R")
# source("/projects/enviro_lab/software/lineagespot/R/get_lineage_report.R")
# source("/projects/enviro_lab/software/lineagespot/R/lineagespot_hits.R")
# source("/projects/enviro_lab/software/lineagespot/R/merge_vcf.R")
# source("/projects/enviro_lab/software/lineagespot/R/uniq_variants.R")
# message("Running lineagespot: ", vcf)

# lineages_of_interest <- c("BA.2", "BA.2.12.1", "BA.4", "BA.5")
lineages_of_interest <- c()

# vcf <- "/projects/enviro_lab/WW-UNCC/MixedControl-06-16-23-V2-fastqs/output/samples/Mixture06.pass.vcf.gz"
# gff <- '/projects/enviro_lab/decon_compare/lineagespot/NC_045512.2_annot.gff3'
# message(gff)

results <- lineagespot(
	vcf_fls = c(vcf),
	gff3_path = system.file("extdata",
		"NC_045512.2_annot.gff3",
		package = "lineagespot"),
	ref_folder = system.file("extdata",
		"ref",
		package = "lineagespot"),
	voc = lineages_of_interest
)

# lineagespot report
# print(results$variants.table)
print(results$lineage.hits)
df <- results$lineage.hits
df <- df[df$lineage == 'P.1']
print(df)
# print(results$lineage.report)
# print(typeof(results$lineage.report))
write.csv(results$lineage.report, outfile, row.names=FALSE)
warnings()

# message("Showing session info:")
# sessionInfo()