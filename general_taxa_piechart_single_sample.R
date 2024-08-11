library(phyloseq)
library(dplyr)
library(ggplot2)
library(plotly)
library(scales)
library(qiime2R)

##########################FOR SINGLE SAMPLE#####################################
# Set working directory
setwd("/path/to/wd")

# Replace files with your own
metadata <- readr::read_tsv("metadata.tsv")
colnames(metadata)[1] <- 'SampleID'

# phyloseq object
physeq<-qza_to_phyloseq(
  features="features.qza",
  tree="rooted-tree.qza",
  taxonomy="taxonomy.qza",
  metadata = "metadata.tsv"
)


create_interactive_pie_chart <- function(physeq, sample_name, ranks = c("Phylum", "Class", "Order", "Family", "Genus", "Species")) {
  
  # Transform to relative abundance
  ps.rel <- transform_sample_counts(physeq, function(x) x / sum(x) * 100)
  
  # Define a list to hold plotly pie charts
  pie_charts <- list()
  
  # Loop through each rank and create a pie chart
  for (rank in ranks) {
    
    # Agglomerate taxa at the current rank
    glom <- tax_glom(ps.rel, taxrank = rank, NArm = FALSE)
    ps.melt <- psmelt(glom)
    
    # Convert taxonomic rank to character for easy adjustments
    ps.melt[[rank]] <- as.character(ps.melt[[rank]])
    
    # Summarize abundance
    ps.melt_sum <- ps.melt %>%
      group_by(Sample, !!sym(rank)) %>%
      summarise(Abundance = sum(Abundance))
    
    # Filter for a specific sample
    ps.melt_sum <- ps.melt_sum %>%
      filter(Sample == sample_name) %>%
      filter(Abundance >= 0.01) %>%
      mutate(Label = paste0(!!sym(rank), " (", round(Abundance, 1), "%)"))
    
    # Create the pie chart using plotly
    pie_chart <- plot_ly(
      data = ps.melt_sum,
      labels = ~Label,
      values = ~Abundance,
      type = 'pie',
      textinfo = 'label',
      hoverinfo = 'label',
      marker = list(colors = hue_pal()(length(unique(ps.melt_sum$Label))))
    ) %>%
      layout(
        title = paste("Abundance of", rank, "in Sample", sample_name),
        showlegend = TRUE,
        legend = list(title = list(text = paste(rank, "Abundance (%)")))
      )
    
    # Append to the list
    pie_charts[[rank]] <- pie_chart
  }
  
  return(pie_charts)
}


# Assuming 'physeq' is your phyloseq object and "sample1" is your sample of interest
create_interactive_pie_chart(physeq, "sample1")

# To view a pie chart for a specific rank, for example, "Phylum":
interactive_pie_charts[["Phylum"]]