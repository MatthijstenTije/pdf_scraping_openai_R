# Scraping PDF with OpenAI API in R

# 1. OpenAI API Setup -----

install.packages("openai")
library(openai)
Sys.setenv(OPENAI_API_KEY = 'your_api_key_here')
api_key = 'secret'
# 2. PDF Text Extraction -----

# Add required libraries for handling PDF files and data
install.packages("pdftools")
install.packages("tidyverse")
library(tidyverse)
library(pdftools)

file_path <- "pdf/economicsciencesprize2023.pdf"
extracted_text <- pdf_text(file_path)

extracted_text %>% write_rds("extraction/extracted_text.rds")
extracted_text <- read_rds("extraction/extracted_text.rds")

length(extracted_text) # Total number of pages extracted
extracted_text[1] # Text from the first page
extracted_text[6] # Text from the sixth page


# 3. SUMMARIZE THE PDF DOCUMENT USING OPENAI API ----

install.packages("httr")
library(httr)

api_endpoint <- "https://api.openai.com/v1/chat/completions"

analysis_prompt <- "In what ways has Goldin's research contributed to our understanding of the dynamics behind the gender gap in earnings and employment?"
formatted_text <- str_c(extracted_text, collapse = "\\n")
formatted_text_short <- str_sub(formatted_text, 1, 30000)

request_body <- list(
  model = "gpt-3.5-turbo",
  messages = list(
    list(role = "system", content = "You are a helpful assistant."),
    list(role = "user", content = str_c(analysis_prompt, formatted_text_short))
  )
)


api_response <- POST(
  url = api_endpoint,
  body = request_body,
  encode = "json",
  add_headers(`Authorization` = paste("Bearer", api_key), `Content-Type` = "application/json")
)

response_data <- content(api_response, "parsed")

response_data %>% write_rds("answer/analysis_results.rds")
response_data <- read_rds("answer/analysis_results.rds")

api_summary <- response_data$choices[[1]]$message$content
cat(api_summary,file = "output.txt")

