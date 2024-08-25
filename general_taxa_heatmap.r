library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(viridis)
library(qiime2R)
library(tibble)
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

# This function is based on the original work by Jordan Bisanz from https://github.com/jbisanz/qiime2R.
# Modifications by Venkatesh. N to add interactivity.
create_taxa_heatmap <- function(features, metadata, category = NULL, normalize = "log10(percent)", ntoplot = 10) {
  
  # Helper functions for normalization
  make_percent <- function(features) {
    if (is.matrix(features)) {
      features <- as.data.frame(features)
    }
    totals <- colSums(features)
    percent_features <- t(t(features) / totals * 100)
    return(percent_features)
  }
  
  make_clr <- function(features) {
    if (is.matrix(features)) {
      features <- as.data.frame(features)
    }
    features <- as.data.frame(features + 1)  # Add pseudocount
    log_features <- log(features)
    clr_features <- log_features - rowMeans(log_features)
    return(clr_features)
  }
  
  if (is.null(ntoplot) & nrow(features) > 30) { ntoplot = 30 } 
  else if (is.null(ntoplot)) { ntoplot = nrow(features) }
  
  if (normalize == "log10(percent)") {
    features <- log10(make_percent(features + 1))
  } else if (normalize == "clr") {
    features <- make_clr(features)
  } else if (normalize == "none") {
    features <- as.data.frame(features)
  }
  
  if (missing(metadata)) { metadata <- data.frame(SampleID = colnames(features)) }
  if (!"SampleID" %in% colnames(metadata)) { metadata <- metadata %>% rownames_to_column("SampleID") }
  
  if (!is.null(category)) {
    if (!category %in% colnames(metadata)) {
      stop(paste(category, "not found as a column in metadata"))
    }
    
    # Add sample count to facet labels
    metadata_count <- metadata %>%
      group_by(!!sym(category)) %>%
      summarise(SampleCount = n(), .groups = 'drop')
    
    metadata <- metadata %>%
      left_join(metadata_count, by = category) %>%
      mutate(FacetLabel = paste0(get(category), " (n = ", SampleCount, ")"))
  }
  
  plotfeats <- names(sort(rowMeans(features), decreasing = TRUE)[1:ntoplot]) # Extract the top N most abundant features on average
  
  roworder <- hclust(dist(features[plotfeats, ]))
  roworder <- roworder$labels[roworder$order]
  
  colorder <- hclust(dist(t(features[plotfeats, ])))
  colorder <- colorder$labels[colorder$order]
  
  fplot <- features %>%
    as.data.frame() %>%
    rownames_to_column("Taxon") %>%
    gather(-Taxon, key = "SampleID", value = "Abundance") %>%
    filter(Taxon %in% plotfeats) %>%
    mutate(Taxon = factor(Taxon, levels = rev(plotfeats))) %>%
    left_join(metadata) %>%
    mutate(Taxon = factor(Taxon, levels = roworder)) %>%
    mutate(SampleID = factor(SampleID, levels = colorder))
  
  bplot <- ggplot(fplot, aes(x = SampleID, y = Taxon, fill = Abundance, text = paste("SampleID: ", SampleID, "<br>Taxon: ", Taxon, "<br>Abundance: ", round(Abundance, 2)))) +
    geom_tile(stat = "identity") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 8),
          axis.title.x = element_text(margin = margin(t = 10)),
          plot.title = element_text(hjust = 0.5, size = 16),
          legend.title = element_text(size = 12, margin = margin(b = 20))) +
    coord_cartesian(expand = FALSE) +
    xlab("Sample") +
    ylab("Feature") +
    scale_fill_viridis_c() +
    labs(title = "Taxa Heatmap")
  
  if (!is.null(category)) {
    bplot <- bplot + 
      facet_wrap(~FacetLabel, scales = "free_x", nrow = 1) +
      theme(strip.text = element_text(size = 10, face = "bold"))
  }
  
  fig_combined <- ggplotly(bplot, tooltip = "text")
  return(fig_combined)
}

# Assuming "group" is the category you want
heatmap <- create_taxa_heatmap(taxasums, metadata, "group")

# Save the plot to a HTML file
saveWidget(heatmap, file = "/path/to/file.html", selfcontained = TRUE)

