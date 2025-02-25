# Loading necessary libraries
library(dplyr)
library(readr)
# Loading the dataset
df <- read_csv("D:/GDC-BREAST/Breast_cancer_Betta.csv")
# View dataset structure
str(df)
# Rename first column if it's an index
colnames(df)[1] <- "ID"
# Converting all numeric columns to proper format
df[, -1] <- lapply(df[, -1], as.numeric)
# Checking for missing values
missing_values <- sum(is.na(df))
print(paste("Total missing values:", missing_values))
# Removing columns with too many missing values (if any)
df <- df %>% select(where(~ sum(is.na(.)) / nrow(df) < 0.2))
# Filling missing values with column mean (if needed)
df <- df %>% mutate(across(where(is.numeric), ~ ifelse(is.na(.), mean(., na.rm = TRUE), .)))
# Removing duplicate rows
df <- df %>% distinct()
# Normalize values between 0 and 1
df[, -1] <- lapply(df[, -1], function(x) (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE)))
# Saving cleaned dataset
write_csv(df, "Breast_cancer_Betta_Cleaned.csv")
print("Data cleaning completed successfully!")


colSums(is.na(df))  
sum(is.na(df))  
str(df) 
nrow(df) == nrow(distinct(df))
colnames(df)
summary(df)
df_cleaned <- read_csv("Breast_cancer_Betta_Cleaned.csv")
View(df_cleaned)
write_csv(df, "Breast_cancer_Betta_Cleaned.csv")
print("Cleaned data saved successfully!")


# Now, we will remove low-variance probes
#Load the data
data <- read.csv("Breast_cancer_Betta_Cleaned.csv")
# Checking the data and exclude non-numeric columns
numeric_data <- data[, -1]  # Exclude the first column (if it contains non-numeric data)
# Calculating the variance for each column
variance <- apply(numeric_data, 2, var)
print(variance)
# Keep columns with variance greater than a threshold = 0.1)
filtered_data <- numeric_data[, variance > 0.1]
print (filtered_data)
dim(filtered_data)
head(filtered_data)
write.csv(filtered_data, "Filtered_Breast_Cancer_Data.csv", row.names = FALSE)
data <- read.csv("Filtered_Breast_Cancer_Data.csv")
