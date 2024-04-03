# Scraping PDF with OpenAI API in R

# 1. OpenAI API Setup -----

# Install and load the OpenAI R package
install.packages("openai")
library(openai)

# It's recommended to set your API Key in an environment file or variable for security reasons
# Set your OpenAI API Key (replace 'your_api_key_here' with your actual key)
Sys.setenv(OPENAI_API_KEY = 'your_api_key_here')


# 2. PDF Text Extraction -----

# Add required libraries for handling PDF files and data
install.packages("pdftools")
install.packages("tidyverse")
library(tidyverse)
library(pdftools)

# Define the path to the PDF document
pdf_path <- "path_to_your_pdf/filename.pdf"

# Extract text from the PDF
extracted_text <- pdf_text(pdf_path)

# Optionally, save and reload the extracted text for ease of use
extracted_text %>% write_rds("extraction/extracted_text.rds")
extracted_text <- read_rds("extraction/extracted_text.rds")

# Example: View text from specific pages
length(extracted_text) # Total number of pages extracted
extracted_text[1] # Text from the first page
extracted_text[6] # Text from the sixth page

# 3. Summarizing Document with OpenAI API -----

# Load the httr package for HTTP requests
install.packages("httr")
library(httr)

# Set the API endpoint for chat completions
api_endpoint <- "https://api.openai.com/v1/chat/completions"

# prompt for analysis
analysis_prompt <- "In what ways has Goldin's research contributed to our understanding of the dynamics behind the gender gap in earnings and employment?"

# Clean text
formatted_text <- str_c(extracted_text, collapse = "\\n")
# Trim text to fit model's token limit (e.g., 30,000 characters)
formatted_text_short <- str_sub(formatted_text, 1, 30000)

# Construct the API request Body
request_body <- list(
  model = "gpt-3.5-turbo",
  messages = list(
    list(role = "system", content = "You are a helpful assistant."),
    list(role = "user", content = str_c(analysis_prompt, formatted_text_short))
  )
)

# Execute the POST request to the OpenAI API
api_response <- POST(
  url = api_endpoint,
  body = request_body,
  encode = "json",
  add_headers(`Authorization` = paste("Bearer", Sys.getenv("OPENAI_API_KEY")), `Content-Type` = "application/json")
)

# Process the response from the API
response_data <- content(api_response, "parsed")

# Save and optionally reload the response data for review
response_data %>% write_rds("answer/analysis_results.rds")
response_data <- read_rds("answer/analysis_results.rds")

# Extract the summary from the API's response and display it
api_summary <- response_data$choices[[1]]$message$content
cat(api_summary,file = "output.txt")
