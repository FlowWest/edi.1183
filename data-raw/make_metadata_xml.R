library(EMLaide)
library(tidyverse)
library(EDIutils)
library(readxl)
library(EML)

# files and parameters to enter directly into the R script ---------------------
excel_path <- "data-raw/FISHBIO_submission/FISHBIO_passage_metadata.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/FISHBIO_submission/FISHBIO_abstract.docx"
methods_docx <- "data-raw/FISHBIO_submission/FISHBIO_methods.docx"

datatable_metadata <- list(filepath =  c("data/FISHBIO_RBT_weir_passages_2005_2022.csv"),
                           attribute_info = c("data-raw/FISHBIO_submission/FISHBIO_passage_metadata.xlsx"),
                           datatable_description = c("Weir Passage Data"),
                           datatable_url = paste0("https://raw.githubusercontent.com/FlowWest/fishbio-stanislaus-o.mykiss/main/data/",
                                                  c("FISHBIO_RBT_weir_passages_2005_2022.csv")))

#TODO reserve new EDI number
# reserve_edi_id(user_id = Sys.getenv("user_id"),
#                password = Sys.getenv("password"),
#                environment = "staging") # when ready to post change to production

edi_number <- "edi.921.1"

# Create dataset list and pipe on metadata elements ----------------------------
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

# Add dataset and additional elements of eml to eml list -----------------------
eml <- list(packageId = edi_number,
            system = "EDI",
            access = add_access(),
            dataset = dataset)

edi_number
# Write and validate EML
EML::write_eml(eml, "edi.921.1.xml")
EML::eml_validate("edi.921.1.xml")

evaluate_edi_package(user_id = Sys.getenv("user_id"),
                     password = Sys.getenv("password"),
                     eml_file_path = "edi.921.1.xml",
                     environment = "staging")

# upload_edi_package(user_id = Sys.getenv("user_id"),
#                    password = Sys.getenv("password"),
#                    eml_file_path = "edi.921.1.xml",
#                    environment = "staging")
