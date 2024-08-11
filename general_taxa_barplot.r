########################FINAL RELATIVE ABUNDANCE BARPLOT########################

library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(qiime2R)
library(tibble)
library(patchwork)
library(htmlwidgets)

# Set working directory
setwd("/path/to/wd")

# Load metadata file
metadata <- readr::read_tsv("metadata.tsv")

# Rename first column
colnames(metadata)[1] <- 'SampleID'

# Read features table
SVs<-read_qza("features.qza")$data

# Read taxonomy file
taxonomy<-read_qza("taxonomy.qza")$data %>% parse_taxonomy()

# Summarize your desired taxa
taxasums<-summarize_taxa(SVs, taxonomy)$Phylum

# Combined function for normalization and plotting
create_taxa_barplt <- function(features, metadata, category = NULL, normalize = "percent", ntoplot = 10) {
  
  # Define color palette
  q2r_palette <- c(
    "blue4", "olivedrab", "firebrick", "gold", "darkorchid", "steelblue2",
    "chartreuse1", "aquamarine", "yellow3", "coral", "grey"
  )
  
  # Normalization functions
  normalize_features <- function(features, method) {
    if (is.matrix(features)) {
      features <- as.data.frame(features)
    }
    totals <- colSums(features)
    if (method == "percent") {
      return(t(t(features) / totals * 100))
    } else if (method == "proportion") {
      return(t(t(features) / totals))
    }
  }
  
  # Normalize features
  features <- normalize_features(features, normalize)
  
  # Handle metadata
  if (missing(metadata)) {
    metadata <- data.frame(SampleID = colnames(features))
  }
  if (!"SampleID" %in% colnames(metadata)) {
    metadata <- metadata %>% rownames_to_column("SampleID")
  }
  
  if (!is.null(category) && !category %in% colnames(metadata)) {
    stop(paste(category, "not found as a column in metadata"))
  }
  
  # Create facet_labels with sample counts
  metadata_count <- metadata %>%
    group_by(!!sym(category)) %>%
    summarise(SampleCount = n(), .groups = 'drop')
  
  metadata <- metadata %>%
    left_join(metadata_count, by = category) %>%
    mutate(FacetLabel = paste0(get(category), " (n = ", SampleCount, ")"))
  
  # Select top taxa
  if (is.null(ntoplot)) {
    ntoplot <- nrow(features)
  }
  plotfeats <- names(sort(rowMeans(features), decreasing = TRUE)[1:ntoplot])
  
  # Prepare data for plotting
  fplot <- features %>%
    as.data.frame() %>%
    rownames_to_column("Taxon") %>%
    gather(-Taxon, key = "SampleID", value = "Abundance") %>%
    mutate(Taxon = if_else(Taxon %in% plotfeats, Taxon, "Remainder")) %>%
    group_by(Taxon, SampleID) %>%
    summarize(Abundance = sum(Abundance), .groups = "drop") %>%
    mutate(Taxon = factor(Taxon, levels = rev(c(plotfeats, "Remainder")))) %>%
    left_join(metadata, by = "SampleID") %>%
    # Reorder Taxon within each SampleID based on decreasing Abundance
    group_by(SampleID) %>%
    mutate(Taxon = factor(Taxon, levels = Taxon[order(-Abundance)])) %>%
    ungroup()
  
  # Plotting
  p <- ggplot(fplot, aes(x = SampleID, y = Abundance, fill = Taxon)) +
    geom_bar(stat = "identity") +
    labs(
         x = 'Sample',
         y = paste('Abundance', ifelse(normalize == "percent", "(%)", ""))) +
    theme(
      axis.text.x = element_text(angle = 90, hjust = 1, size = 8, margin = margin(t = 5)),  # Rotate, resize, and adjust margin of x-tick labels
      axis.title.x = element_text(margin = margin(t = 10)),  # Adjust margin between x-axis title and x-axis
      strip.background = element_blank(),  # Remove facet background
      strip.text = element_text(size = 10),  # Adjust facet labels
      panel.background = element_blank(),  # Remove panel background
      legend.position = "bottom",  # Place legend at the bottom
      legend.box.background = element_rect(color = "black", fill = NA),  # Add a border around the legend
      legend.background = element_rect(color = "black"),  # Add background color (optional)
      plot.title = element_text(size = 16, hjust = 0.5)  # Increase title size and center it
    ) +
    scale_fill_manual(values = q2r_palette)
  
  if (!is.null(category)) {
    p <- p + facet_wrap(~FacetLabel, scales = "free_x", nrow = 1)  # Facet wrap if category is specified
  }
  
  fig_combined <- ggplotly(p, tooltip = c("x", "y", "fill"))
  
  return(fig_combined)
}

# Assuming "group" is the category
create_taxa_barplt(taxasums, metadata, category = "group", normalize = "percent")

# Save plot in HTML file
saveWidget(barplot, file = "/path/to/htmlfile.html")


