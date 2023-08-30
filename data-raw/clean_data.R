library(tidyverse)
library(readr)
library(readxl)

# save cleaned data to `data/`

# weir passage data ------------------------------------------------------------
weir_passage_2020 <- read_csv("data-raw/FISHBIO_submission/FISHBIO_RBT_weir_passages.csv") %>%
  janitor::clean_names() %>%
  rename(fish_condition = condition) %>%
  glimpse

#view(weir_passage_2020)

weir_passage_2020$`vaki_trap`%>% unique()

cleaned_passage_data_2020 <- weir_passage_2020  %>%
  mutate(passage_date = as.Date(passage_date, "%m/%d/%y")) %>%
  bind_rows(weir_passage_data_2022) |>
  mutate_if(is.character, tolower)

cleaned_passage_data_2020$passage_direction %>% unique()
cleaned_passage_data_2020$vaki_trap %>% unique()


weir_passage_2022 <- read_csv("data-raw/FISHBIO_submission/FISHBIO_passage_2021-22.csv") %>%
  janitor::clean_names() %>%
  select(-entered_by, -qcd_by) %>%
  glimpse

cleaned_passage_data_2022 <- weir_passage_2022  %>%
  mutate_if(is.character, tolower) %>%
  mutate(passage_date = as.Date(passage_date, "%m/%d/%y"),
         vaki_trap = ifelse(vaki_trap == "trapping", "trap", vaki_trap)) %>%
  glimpse

cleaned_passage_data_2022$passage_direction %>% unique()
cleaned_passage_data_2022$vaki_trap %>% unique()

# weir passage 2022-2023
weir_passage_data_2023 <- read_excel("data-raw/updated_fishbio_submission/FISHBIO_passage_2022-23.xlsx") |>
  janitor::clean_names() %>%
  mutate(passage_time = hms::as_hms(passage_time),
         passage_direction = ifelse(passage_direction == "U", "UP", passage_direction)) |>
  glimpse()

cleaned_passage_data_2023 <- weir_passage_data_2023  %>%
  mutate_if(is.character, tolower) %>%
  mutate(vaki_trap = ifelse(vaki_trap == "trapping", "trap", vaki_trap)) %>%
  glimpse
# Combine Weir passage data

weir_passage <- bind_rows(cleaned_passage_data_2020, cleaned_passage_data_2022, cleaned_passage_data_2023) %>%
  mutate(ad_clip = case_when(ad_clip %in% c("y", "yes") ~ "yes",
                             ad_clip %in% c("n", "no") ~ "no"),
         video_problems = ifelse(video_problems == "n/a", NA_character_, video_problems),
         silhouette_quality = ifelse(silhouette_quality == "n/a", NA_character_, silhouette_quality),
         video_quality = ifelse(video_quality == "n/a", NA_character_, video_quality),
         fish_condition = ifelse(fish_condition == "n/a", NA_character_, fish_condition)) %>% glimpse


weir_passage$passage_date %>% summary()
weir_passage$passage_time %>% summary()
weir_passage$passage_direction %>% table(useNA = "ifany")
weir_passage$species %>% table(useNA = "ifany")
weir_passage$body_depth %>% summary()
weir_passage$length_coefficient %>% summary()
weir_passage$total_length %>% summary()
weir_passage$life_stage %>% table(useNA = "ifany")
weir_passage$count %>% summary()
weir_passage$sex %>% table(useNA = "ifany")
weir_passage$ad_clip %>% table(useNA = "ifany")
weir_passage$fish_condition %>% table(useNA = "ifany") #TODO ask about fish condition
weir_passage$id_certainty %>% table(useNA = "ifany")
weir_passage$video_quality %>% table(useNA = "ifany")
weir_passage$video_problems %>% table(useNA = "ifany")
weir_passage$vaki_trap %>% table(useNA = "ifany")

weir_passage$comments %>% table(useNA = "ifany")

clean_weir_passage <- weir_passage %>%
  mutate(comments = gsub(",", ";", comments))

clean_weir_passage$comments %>% table(useNA = "ifany")

write_csv(clean_weir_passage, "data/FISHBIO_RBT_weir_passages_2005_2023.csv")

# Pit tag data -----------------------------------------------------------------
raw_pit_tag <- read_csv("data-raw/FISHBIO_submission/FISHBIO_PIT Tag Detections_2021-22.csv") %>% glimpse

# Nothing to add here empty table
# raw_pit_tag_2023 <- read_excel("data-raw/updated_fishbio_submission/FISHBIO_PIT_Tag_Detections_2022_2023.xlsx") |> glimpse()

clean_pit_tag <- bind_rows(raw_pit_tag) %>%
  janitor::clean_names() %>%
  rename(pit_number = pit_num) %>%
  mutate(date = as.Date(date, "%m/%d/%y"),
         tag_date = as.Date(tag_date, "%m/%d/%y")) %>%
  mutate_if(is.character, tolower) %>%
  glimpse

write_csv(clean_pit_tag, "data/FISHBIO_PIT_tag_detections_2021_2023.csv")


# trapping ---------------------------------------------------------------------

raw_trapping_data <- read_csv("data-raw/FISHBIO_submission/FISHBIO_trapping_2021-22.csv") %>%
  mutate(Date = lubridate::as_date(Date, format = "%m/%d/%y")) |> glimpse()

raw_trapping_data_2023 <- read_excel("data-raw/updated_fishbio_submission/FISHBIO_trapping_2022-23.xlsx") |>
  mutate(Time = hms::as_hms(Time)) |> glimpse()

clean_trap <- bind_rows(raw_trapping_data, raw_trapping_data_2023) %>%
  janitor::clean_names() %>%
  rename(fork_length = forklength) %>%
  select(-fish_condition) %>%
  rename(fish_condition = conditon) %>%
  mutate_if(is.character, tolower) %>%
  mutate(pit_tag = c("pit tag #982091062594309", "pit tag #982091062594274", NA, NA, NA, NA, NA),
         weight = c(2.5, 2.6, 3.64, 3.44, 3.02, 3.86, 2.75),
         floy_tag = c("floy tag #001", "floy tag #002", "floy tag #004", "floy tag #006", "floy tag #007", "floy tag #009","floy tag #010"),
         ad_clip = ifelse(ad_clip == "y", "yes", "no"),
         scales = ifelse(scales == "y", "yes", "no"),
         genetic = ifelse(genetic == "y", "yes", "no"),
         recapture = ifelse(ad_clip == "y", "yes", "no"),
         date = lubridate::as_date(date)) %>%
  select(-comments, -pit_num) %>%
  glimpse()

clean_trap$fish_condition %>% table(useNA = "ifany")

write_csv(clean_trap, "data/FISHBIO_trapping_2023.csv")

# Operations Logs
# Weir operations log -----------------------------------------------------------
weir_operations_log <- read_csv("data-raw/FISHBIO_submission/FISHBIO_Weir operations log_2021-22.csv") %>%
  mutate("Sample Date" = lubridate::as_date(`Sample Date`, format = "%m/%d/%y")) |> glimpse()

na_to_na = function(x){
  x[x=='N/A'] = NA
  return(x)
}
weir_operations_log_2023 <- read_excel("data-raw/updated_fishbio_submission/FISHBIO_Weir_operations_log_2022_2023.xlsx") |>
  mutate_if(is.character, na_to_na)

# write_csv(weir_operations_log_2023, "data-raw/updated_fishbio_submission/FISHBIO_Weir_operations_log_2022_2023.csv")
weir_operations_log_2023 <- read_csv("data-raw/updated_fishbio_submission/FISHBIO_Weir_operations_log_2022_2023.csv") |>
  mutate("Sample Time" = hms::as_hms(`Sample Time`),
         "# of Submerged Panels" = as.numeric(`# of Submerged Panels`),
         "Velocity Downstream" = as.numeric(`Velocity Downstream`)) |> glimpse()

clean_weir_operations <- bind_rows(weir_operations_log, weir_operations_log_2023) %>%
  janitor::clean_names() %>%
  mutate(sample_date = as.Date(sample_date, "%m/%d/%y"),
         comments1 = gsub(",", ";", comments1),
         crew_initials = gsub(",", ";", crew_initials)) %>%
  mutate_if(is.character, tolower) %>%
  rename(downstream_livebox_installed = downstream_livebox_installed_y_n,
         vaki = vaki_y_n,
         barrels = barrels_y_n) %>%
  mutate(downstream_livebox_installed = tolower(downstream_livebox_installed),
         vaki = tolower(vaki),
         barrels = tolower(barrels),
         trapping = tolower(trapping)) %>%
  select(-condition_code) %>%
  glimpse()

write_csv(clean_weir_operations, "data/FISHBIO_Weir_operations_log_2021_2023.csv")

# PIT operations log ------------------------------------------------------------
pit_operations_log <- read_csv("data-raw/FISHBIO_submission/FISHBIO_PIT Operations Log 2021-22.csv") %>%
  mutate(Date = as.Date(Date, "%m/%d/%y")) |> glimpse()

pit_operations_log_2023 <- read_excel("data-raw/updated_fishbio_submission/FISHBIO_PIT_operations_log_2022_2023.xlsx") %>%
  select(-Time) |> glimpse()

clean_pit_tag_operations <- bind_rows(pit_operations_log, pit_operations_log_2023)  %>%
  janitor::clean_names() %>%
  mutate(operational_mode = case_when(operational_mode == "Stpooed" ~ "Stopped",
                                      operational_mode == "Started at 1200" ~ "Started",
                                      operational_mode == "Started 10:11" ~ "Started",
                                      operational_mode == "stopped 10:39" ~ "Stopped",
                                      TRUE ~ as.character(operational_mode)),
         operational_mode = tolower(operational_mode),
         description = gsub(",", ";", description),
         description = tolower(description)) %>%
  glimpse

unique(clean_pit_tag_operations$operational_mode)
unique(clean_pit_tag_operations$description)

write_csv(clean_pit_tag_operations, "data/FISHBIO_Pit_operations_log_2021_2023.csv")

