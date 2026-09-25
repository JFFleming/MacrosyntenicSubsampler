
library(macrosyntR)
library(ggplot2)
library(dplyr)

args = commandArgs(trailingOnly=TRUE)
getwd()
# Load table of orthologs and integrate with genomic coordinates :
my_orthologs <- load_orthologs(
  orthologs_table = args[1],
  bedfiles = c(
    "Bflo.bed",
    "Pyes.bed"
  )
)

# Load overlay table containing the subsample support values
overlay_df <- read.table(
    "Unique.Significant.tsv",
    sep = "\t",
    header = FALSE,
    stringsAsFactors = FALSE
)
# Set the overlay table to equal the oxford dot plot
colnames(overlay_df) <- c(
    "sp1.Chr",
    "sp2.Chr",
    "label"
)

# Draw an oxford grid :
p1 <- plot_oxford_grid(my_orthologs,
                       sp1_label = "Branchiostoma",
                       sp2_label = "Mizuhopecten")
p1

# Automatically reorder the Oxford grid and color the detected clusters (communities):
p2 <- plot_oxford_grid(my_orthologs,
                       sp1_label = "Branchiostoma",
                       sp2_label = "Mizuhopecten",
                       reorder = TRUE,
                       color_by = "clust")
p2

# Plot the significant linkage groups :
my_macrosynteny <- compute_macrosynteny(my_orthologs)
write.table(my_macrosynteny, sep="\t", file="Test_Table.tsv")
p3 <- plot_macrosynteny(my_macrosynteny)

# Add the support values as labels
p3 <- p3 +
    geom_text(
        data = overlay_df,
        aes(
            x = sp1.Chr,
            y = sp2.Chr,
            label = label
        ),
        inherit.aes = FALSE,
        size = 2,
        color = "black",
        fontface = "bold"
    )

p3

# Call the reordering function, test significance and plot it :
my_orthologs_reordered <- reorder_macrosynteny(my_orthologs)
my_macrosynteny <- compute_macrosynteny(my_orthologs_reordered)
p4 <- plot_macrosynteny(my_macrosynteny)

# Add the jackknife support values as labels
p4 <- p4 +
    geom_text(
	data = overlay_df,
        aes(
            x = sp1.Chr,
            y = sp2.Chr,
            label = label
        ),
	inherit.aes = FALSE,
        size = 2,
        color = "black",
        fontface = "bold"
    )

p4

