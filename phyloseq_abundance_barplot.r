library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(qiime2R)
library(tibble)
library(htmlwidgets)
library(phyloseq)

# Set working directory
setwd("/path/to/wd")

# Replace with your own files
metadata <- readr::read_tsv("metadata.tsv")
colnames(metadata)[1] <- 'SampleID'
colnames(metadata)[2] <- 'condition'

# phyloseq object
physeq<-qza_to_phyloseq(
  features="features.qza",
  tree="rooted-tree.qza",
  taxonomy="taxonomy.qza",
  metadata = "metadata.tsv"
)
create_abundance_barplot <- function(physeq, category = "condition", level) {
  
  # Normalize sample counts to percentages
  ps.rel <- transform_sample_counts(physeq, function(x) x / sum(x) * 100)
  
  # Agglomerate taxa at the specified level
  glom <- tax_glom(ps.rel, taxrank = level, NArm = TRUE)
  
  # Melt data into long format
  ps.melt <- psmelt(glom)
  
  # Change the specified level to character for easier adjustment
  ps.melt[[level]] <- as.character(ps.melt[[level]])
  
  # Calculate mean abundance per condition and level
  ps.melt <- ps.melt %>%
    group_by(!!sym(category), !!sym(level)) %>%
    mutate(mean = mean(Abundance))
  
  # Keep only taxa with mean abundance > 0, otherwise mark as "< 0%"
  keep <- unique(ps.melt[[level]][ps.melt$mean > 0])
  ps.melt[[level]][!(ps.melt[[level]] %in% keep)] <- "< 0%"
  
  # Summarize data by Sample, condition, and level
  ps.melt_sum <- ps.melt %>%
    group_by(Sample, !!sym(category), !!sym(level)) %>%
    summarise(Abundance = sum(Abundance), .groups = 'drop')
  
  # Calculate the number of unique samples per group (category)
  sample_count <- ps.melt_sum %>%
    group_by(!!sym(category)) %>%
    summarise(SampleCount = n_distinct(Sample))
  
  # Merge sample count with the summarized data
  ps.melt_sum <- ps.melt_sum %>%
    left_join(sample_count, by = category) %>%
    mutate(FacetLabel = paste0(!!sym(category), " (n = ", SampleCount, ")"))
  
  # Create ggplot
  p <- ggplot(ps.melt_sum, aes(x = Sample, y = Abundance, fill = !!sym(level), 
                               text = paste("Sample:", Sample, 
                                            "<br>Abundance:", round(Abundance, 2),"%", 
                                            "<br>", level, ":", !!sym(level)))) + 
    geom_bar(stat = "identity") + 
    labs(x = "Samples", y = "Abundance (%)"
         ) +
    facet_wrap(~FacetLabel, scales = "free_x", nrow = 1) +
    guides(fill = guide_legend(nrow = 15)) + 
    theme(
      strip.background = element_blank(),
      panel.background = element_blank(),
      axis.title.x = element_text(margin = margin(t = 10)),  # Adjust the text size here
      axis.text.x = element_text(size = 8, angle = 90),
      axis.text.y = element_text(size = 10),  # Adjust the text size here
      legend.text = element_text(size = 10),  # Adjust the text size here
      legend.title = element_text(size = 14),  # Adjust the text size here
      strip.text = element_text(size = 10),  # Adjust the text size here
      plot.title = element_text(size = 10, face = "bold"),  # Adjust the text size and style here
      axis.title = element_text(size = 10),
      legend.position = "bottom",  # Place legend at the bottom
      legend.box.background = element_rect(color = "black", fill = NA),  # Add a border around the legend
      legend.background = element_rect(color = "black")
    )
  
  # Convert ggplot to plotly
  interactive_plot <- ggplotly(p, tooltip = "text")
  
  return(interactive_plot)
}


# Replace with your own arguments
barplt <- create_abundance_barplot(physeq, category = "group", level = "Phylum")

# Save plot to HTML file
saveWidget(barplt, file = "/path/to/file.html")
