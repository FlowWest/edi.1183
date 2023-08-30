# remotes::install_github('CVPIA-OSC/EMLaide', force = TRUE)

library(EMLaide)
library(tidyverse)
library(readxl)
library(EML)

# files and parameters to enter directly into the R script ---------------------
excel_path <- "data-raw/FISHBIO_submission/FISHBIO_passage_metadata.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/FISHBIO_submission/FISHBIO_abstract.docx"
methods_docx <- "data-raw/FISHBIO_submission/FISHBIO_methods.docx"

datatable_metadata <- list(filepath =  c("data/FISHBIO_RBT_weir_passages_2005_2023.csv",
                                         "data/FISHBIO_PIT_tag_detections_2021_2023.csv",
                                          "data/FISHBIO_trapping_2023.csv",
                                          "data/FISHBIO_Weir_operations_log_2021_2023.csv",
                                         "data/FISHBIO_Pit_operations_log_2021_2023.csv"
                                         ),
                           attribute_info = c("data-raw/FISHBIO_submission/FISHBIO_passage_metadata.xlsx",
                                              "data-raw/FISHBIO_submission/FISHBIO_PIT_detection_metadata.xlsx",
                                               "data-raw/FISHBIO_submission/FISHBIO_trapping_metadata.xlsx",
                                               "data-raw/FISHBIO_submission/FISHBIO_Weir_Operations_metadata.xlsx",
                                              "data-raw/FISHBIO_submission/FISHBIO_PIT_Operations_metadata.xlsx"
                                              ),
                           datatable_description = c("Weir Passage Data",
                                                     "Pit Tag Detections",
                                                      "Fish Trapping Info",
                                                     "Weir Operations",
                                                     "Pit Operations"
                                                     )
                           # datatable_url = paste0("https://raw.githubusercontent.com/FlowWest/fishbio-stanislaus-o.mykiss/main/data/",
                           #                        c("FISHBIO_RBT_weir_passages_2005_2022.csv",
                           #                          "FISHBIO_PIT_tag_detections_2021_2022.csv",
                           #                          "FISHBIO_trapping_2021.csv",
                           #                          "FISHBIO_Weir_operations_log_2021_2022.csv",
                           #                           "FISHBIO_Pit_operations_log_2021_2022.csv"
                           #                          ))
                           )


#TODO reserve new EDI number
# reserve_edi_id(user_id = Sys.getenv("edi_user_id"),
#                password = Sys.getenv("edi_password"),
#                environment = "production") # when ready to post change to production

edi_number <- "edi.1183.2"

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

custom_units <- data.frame(id = c("panels", "NTU", "microsiemensPerCentimeter", "millimeter"),
                           unitType = c("dimensionless", "dimensionless", "density", "dimensionless"),
                           parentSI = c(NA, NA, NA, NA),
                           multiplierToSI = c(NA, NA, NA, NA),
                           description = c("number of panels",
                                           "Nephlometric Turbidity Unit",
                                           "Unit of electric conductivity",
                                           "TODO weight of fish"))

unitList <- EML::set_unitList(custom_units)

edi_number

# Add dataset and additional elements of eml to eml list -----------------------
eml <- list(packageId = edi_number,
            system = "EDI",
            access = add_access(),
            dataset = dataset,
            additionalMetadata = list(metadata = list(unitList = unitList)))

edi_number
# Write and validate EML
EML::write_eml(eml, "edi.1183.2.xml")
EML::eml_validate("edi.1183.2.xml")

evaluate_edi_package(user_id = Sys.getenv("edi_user_id"),
                     password = Sys.getenv("edi_password"),
                     eml_file_path = "edi.1183.2.xml",
                     environment = "staging")

update_edi_package(user_id = Sys.getenv("edi_user_id"),
                   password = Sys.getenv("edi_password"),
                   eml_file_path = "edi.1183.1.xml",
                   environment = "staging",
                   existing_package_identifier = "edi.944.2")
