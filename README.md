# Microbial Visualization Tools

This repository contains a collection of R scripts designed for visualizing microbial community data. These scripts generate various types of interactive plots and charts from microbiome data, leveraging packages such as `ggplot2`, `plotly`, and `phyloseq`. They are intended for users working with microbiome data who need to generate informative visualizations.

## Included Scripts

- **`general_taxa_barplot.r`**: Generates a relative abundance bar plot for the top N taxa across samples, with optional faceting by metadata categories.
- **`general_taxa_heatmap.r`**: Creates a heatmap of taxa abundance with options for normalization and hierarchical clustering.
- **`phyloseq_abundance_barplot.r`**: Produces a bar plot of taxa abundance at a specified taxonomic level using `phyloseq`.
- **`general_taxa_piechart_single_sample.r`**: Generates interactive pie charts for a specific sample at different taxonomic ranks.
- **`general_taxa_piechart_groupwise.r`**: Creates pie charts of taxa abundance for each group, visualizing relative abundances across groups.

## Getting Started

To use these scripts, you need to set your working directory and provide paths to your input files (e.g., metadata, feature tables, taxonomy files). Each script includes example usage to guide you in generating the desired plots.

## Dependencies

The scripts require the following R packages:

- `dplyr`
- `tidyr`
- `ggplot2`
- `plotly`
- `qiime2R`
- `tibble`
- `patchwork`
- `htmlwidgets`
- `phyloseq`
- `scales`
- `viridisLite`

Install the necessary packages with:

```r
install.packages(c("dplyr", "tidyr", "ggplot2", "plotly", "viridisLite", "scales", "tibble", "patchwork", "htmlwidgets"))
devtools::install_github("jbisanz/qiime2R")
BiocManager::install("phyloseq")
```


## General Taxa Barplot

This R script generates a relative abundance bar plot for the top N taxa across samples, with optional faceting by metadata categories. It uses `ggplot2` and `plotly` for visualization.

### Overview

- **Purpose:** Create a bar plot of taxa abundance with options for normalization and faceting.
- **Libraries Used:** `dplyr`, `tidyr`, `ggplot2`, `plotly`, `qiime2R`, `tibble`, `patchwork`, `htmlwidgets`


### Script Details

1. **Load Libraries**
2. **Set Working Directory and Load Data**
3. **Define `create_taxa_barplt()` Function**
4. **Generate and Save Plot**

#### Example Usage

```r
# Set your working directory and file paths
setwd("/path/to/wd")

# Load and prepare data
metadata <- readr::read_tsv("metadata.tsv")
colnames(metadata)[1] <- 'SampleID'
SVs <- read_qza("features.qza")$data
taxonomy <- read_qza("taxonomy.qza")$data %>% parse_taxonomy()
taxasums <- summarize_taxa(SVs, taxonomy)$Phylum

# Create and save the bar plot
create_taxa_barplt(taxasums, metadata, category = "group", normalize = "percent")
saveWidget(barplot, file = "/path/to/htmlfile.html")
```

## General Taxa Heatmap

This R script generates a heatmap of taxa abundance, with options for normalization and hierarchical clustering. It uses `ggplot2` and `plotly` for visualization.

### Overview

- **Purpose:** Create a heatmap of taxa abundance with hierarchical clustering.
- **Libraries Used:** `dplyr`, `tidyr`, `ggplot2`, `plotly`, `viridis`, `qiime2R`, `tibble`, `htmlwidgets`

### Script Details

1. **Load Libraries**
2. **Set Working Directory and Load Data**
3. **Define `create_taxa_heatmap()` Function**
4. **Generate and Save Heatmap**

#### Example Usage

```r
# Set your working directory and file paths
setwd("/path/to/wd")

# Load and prepare data
metadata <- readr::read_tsv("metadata.tsv")
colnames(metadata)[1] <- 'SampleID'
SVs <- read_qza("features.qza")$data
taxonomy <- read_qza("taxonomy.qza")$data %>% parse_taxonomy()
taxasums <- summarize_taxa(SVs, taxonomy)$Phylum

# Create and save the heatmap
heatmap <- create_taxa_heatmap(taxasums, metadata, "group")
saveWidget(heatmap, file = "/path/to/file.html", selfcontained = TRUE)
```

## Phyloseq Abundance Barplot

This R script generates a bar plot of taxa abundance at a specified taxonomic level using `phyloseq`. It uses `ggplot2` and `plotly` for visualization.

### Overview

- **Purpose:** Create a bar plot of taxa abundance at a specified taxonomic level.
- **Libraries Used:** `dplyr`, `tidyr`, `ggplot2`, `plotly`, `qiime2R`, `tibble`, `htmlwidgets`, `phyloseq`

### Script Details

1. **Load Libraries**
2. **Set Working Directory and Load Data**
3. **Define `create_abundance_barplot()` Function**
4. **Generate and Save Bar Plot**

#### Example Usage

```r
# Set your working directory and file paths
setwd("/path/to/wd")

# Load and prepare data
metadata <- readr::read_tsv("metadata.tsv")
colnames(metadata)[1] <- 'SampleID'
colnames(metadata)[2] <- 'condition'
physeq <- qza_to_phyloseq(features="features.qza", tree="rooted-tree.qza", taxonomy="taxonomy.qza", metadata="metadata.tsv")

# Create and save the bar plot
barplt <- create_abundance_barplot(physeq, category = "group", level = "Phylum")
saveWidget(barplt, file = "/path/to/file.html")
```

## General Taxa Pie Chart (Single Sample)

This R script generates interactive pie charts for a specific sample at different taxonomic ranks. It uses `plotly` for visualization.

### Overview

- **Purpose:** Create pie charts for a specific sample at various taxonomic ranks.
- **Libraries Used:** `phyloseq`, `dplyr`, `ggplot2`, `plotly`, `scales`, `qiime2R`

### Script Details

1. **Load Libraries**
2. **Set Working Directory and Load Data**
3. **Define `create_interactive_pie_chart()` Function**
4. **Generate Pie Charts**

#### Example Usage

```r
# Set your working directory and file paths
setwd("/path/to/wd")

# Load and prepare data
metadata <- readr::read_tsv("metadata.tsv")
colnames(metadata)[1] <- 'SampleID'
physeq <- qza_to_phyloseq(features="features.qza", tree="rooted-tree.qza", taxonomy="taxonomy.qza", metadata="metadata.tsv")

# Create and view pie charts
create_interactive_pie_chart(physeq, "sample1")
# To view a pie chart for a specific rank
interactive_pie_charts[["Phylum"]]
```

## General Taxa Pie Chart (Groupwise)

This R script generates pie charts of taxa abundance for each group, visualizing relative abundances across groups. It uses `plotly` for visualization.

### Overview

- **Purpose:** Create pie charts for each group, visualizing taxa abundance.
- **Libraries Used:** `phyloseq`, `dplyr`, `plotly`, `viridisLite`

### Script Details

1. **Load Libraries**
2. **Set Working Directory and Load Data**
3. **Define `create_individual_pie_charts()` Function**
4. **Generate Pie Charts for Each Group**

#### Example Usage

```r
# Set your working directory and file paths
setwd("/path/to/wd")

# Load and prepare data
metadata <- readr::read_tsv("metadata.tsv")
colnames(metadata)[1] <- 'SampleID'
colnames(metadata)[2] <- 'condition'
physeq <- qza_to_phyloseq(features="features.qza", tree="rooted-tree.qza", taxonomy="taxonomy.qza", metadata="metadata.tsv")

# Create and view pie charts
pie_charts <- create_individual_pie_charts(physeq, taxrank = 'Phylum')
# Print each pie chart individually
for (chart in pie_charts) {
  print(chart)
}
```

## Acknowledgements

- The barplot and heatmap functions were inspired by code from Jordan Bisanz in qiime2R
- The qiime2R repository can be found here: https://github.com/jbisanz/qiime2R
