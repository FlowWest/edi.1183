library(tidyverse)
library(readr)
library(lubridate)


# save cleaned data to `data/`
data_raw <- read_csv("data-raw/FISHBIO submission/FISHBIO_RBT_weir_passages.csv")

view(data_raw)

data_raw$`Vaki/Trap`%>% unique()
cleaned_passage_data$PassageDirection %>% unique()

cleaned_passage_data <- data_raw  %>%
  mutate(PassageDate = as.Date(PassageDate, "%m/%d/%y")) %>%
  mutate_if(is.character, toupper)

write_csv(cleaned_passage_data, "data/FISHBIO_RBT_weir_passages.csv")


