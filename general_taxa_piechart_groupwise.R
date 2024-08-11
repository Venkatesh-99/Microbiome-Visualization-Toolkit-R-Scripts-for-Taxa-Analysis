###############################FOR ALL SAMPLES##################################
library(phyloseq)
library(dplyr)
library(plotly)
library(viridisLite)

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



create_individual_pie_charts <- function(physeq, taxrank = 'Phylum', abundance_threshold = 1) {
  
  # Transform to relative abundance
  ps.rel <- transform_sample_counts(physeq, function(x) x / sum(x) * 100)
  
  # Agglomerate taxa at the specified taxonomic rank
  glom <- tax_glom(ps.rel, taxrank = taxrank, NArm = FALSE)
  ps.melt <- psmelt(glom)
  
  # Convert taxrank column to character for easy adjustment
  ps.melt <- ps.melt %>%
    mutate(!!sym(taxrank) := as.character(!!sym(taxrank)))
  
  # Summarize the data by group and taxonomic rank
  ps.melt_sum_all <- ps.melt %>%
    group_by(Sample, group, !!sym(taxrank)) %>%
    summarise(Abundance = sum(Abundance), .groups = 'drop') %>%
    group_by(group, !!sym(taxrank)) %>%
    summarise(Abundance = sum(Abundance), .groups = 'drop') %>%
    filter(Abundance > abundance_threshold) %>%
    group_by(group) %>%
    mutate(Abundance = Abundance / sum(Abundance) * 100) %>%  # Normalize to 100% within each group
    ungroup() %>%
    mutate(Label = paste0(!!sym(taxrank), " (", round(Abundance, 2), "%)"))
  
  # Create a list to store pie charts for each group
  pie_charts <- list()
  
  groups <- unique(ps.melt_sum_all$group)
  
  for (cond in groups) {
    pie_data <- ps.melt_sum_all %>% filter(group == cond)
    
    pie_chart <- plot_ly(
      data = pie_data,
      labels = ~Label,
      values = ~Abundance,
      type = 'pie',
      textinfo = 'label',
      hoverinfo = 'label',
      marker = list(colors = viridisLite::viridis(length(unique(pie_data[[taxrank]]))))
    ) %>%
      layout(
        title = paste("Abundance of", taxrank, "in group", cond),
        showlegend = TRUE,
        legend = list(title = list(text = paste(taxrank, "Abundance (%)"))),
        margin = list(l = 0, r = 0, t = 40, b = 0)  # Adjust margins if needed
      )
    
    pie_charts[[cond]] <- pie_chart
  }
  
  return(pie_charts)
}



# Assuming 'physeq' is your phyloseq object
pie_charts <- create_individual_pie_charts(physeq, taxrank = 'Phylum')

# Print each pie chart individually
for (chart in pie_charts) {
  print(chart)
}