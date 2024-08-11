# General Taxa Abundance Barplot Visualization

This R script generates an interactive barplot visualizing the relative abundance of taxa in a microbiome dataset. The script reads in feature and taxonomy data from QIIME2 outputs, processes and normalizes the data, and creates a customizable barplot using `ggplot2` and `plotly`. The resulting plot is saved as an HTML file for interactive exploration.

## Features

- **Data Input**: Reads metadata and feature tables from QIIME2 `.qza` files.
- **Normalization**: Supports normalization of data to percentages or proportions.
- **Customization**: Allows for plotting of top taxa and faceting by metadata categories.
- **Interactive Plot**: Generates an interactive barplot using `plotly` for enhanced data exploration.
- **HTML Export**: Saves the interactive plot as an HTML file for easy sharing and viewing.

## Requirements

- R (version 4.0 or higher)
- Required R packages:
  - `dplyr`
  - `tidyr`
  - `ggplot2`
  - `plotly`
  - `qiime2R`
  - `tibble`
  - `patchwork`
  - `htmlwidgets`

## Scripts

This repository contains multiple R scripts. The script to generate the relative abundance barplot is named `relative_abundance_barplot.R`. 

## Usage

1. **Set Working Directory**:
   Update the `setwd("/path/to/wd")` line in the `general_taxa_barplot.R` script to point to your working directory where the data files are located.

2. **Prepare Input Files**:
   - `metadata.tsv`: A tab-separated file containing sample metadata.
   - `features.qza`: QIIME2 artifact containing the feature table.
   - `taxonomy.qza`: QIIME2 artifact containing the taxonomy classification.

3. **Run the Script**:
   Execute the `general_taxa_barplot.R` script in R. The script will generate a barplot showing the relative abundance of taxa, with options for normalization and faceting by a metadata category.

4. **View the Output**:
   The interactive plot will be saved as an HTML file at `/path/to/htmlfile.html`. Update the path as needed.

## Example

```r
# Load the script
source("path/to/relative_abundance_barplot.R")

# Create and save the interactive barplot
create_taxa_barplt(taxasums, metadata, category = "group", normalize = "percent")
