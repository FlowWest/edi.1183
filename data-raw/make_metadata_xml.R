library(EMLaide)
library(tidyverse)
library(EDIutils)
library(readxl)
library(EML)

# save cleaned data to `data/`
#-------------------------------------------------------------------------------
# files and parameters to enter directly into the R script
excel_path <- "data-raw/FISHBIO submission/FISHBIO_passage_metadata.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/FISHBIO submission/FISHBIO_abstract.docx"
methods_docx <- "data-raw/FISHBIO submission/FISHBIO_methods.docx"

datatable_metadata <- list(filepath =  "data/FISHBIO_RBT_weir_passages.csv",
                           attribute_info = "data-raw/FISHBIO submission/FISHBIO_passage_metadata.xlsx",
                           datatable_description = "Weir Passage Data")

# EDI number -------------------------------------------------------------------
edi_number = "edi.750.1"

# Add Access -------------------------------------------------------------------
# Create dataset list and pipe on metadata elements
dataset <- list() %>%
  add_pub_date() %>%
  add_title(metadata$title) %>%
  add_personnel(metadata$personnel) %>%
  add_keyword_set(metadata$keyword_set) %>%
  add_abstract(abstract_docx) %>%
  add_license(metadata$license) %>%
  add_method(methods_docx) %>%
  add_maintenance(metadata$maintenance) %>%
  add_project(metadata$funding) %>%
  add_coverage(metadata$coverage, metadata$taxonomic_coverage) %>%
  add_datatable(datatable_metadata)

# Add dataset and additiobal elements of eml to eml list
eml <- list(packageId = "edi.750.1",
            system = "EDI",
            access = add_access(),
            dataset = dataset)

# Write and validate EML
EML::write_eml(eml, "edi.750.1.xml")
EML::eml_validate("edi.750.1.xml")
