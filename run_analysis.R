require(dplyr)

## Check for the raw data archive/download and unzip if not present
if (!file.exists("~/R/dataset.zip")) {
  fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileurl, "~/R/dataset.zip")
  unzip("dataset.zip")
}

## Read the variable names into a data frame
varlabels <- read.table("~/R/UCI HAR Dataset/features.txt")

## Read the activity names into a data frame
activitylabels <- read.table("~/R/UCI HAR Dataset/activity_labels.txt")

## Test data
##
## Read the subject numbers for the into a data frame
testsubjects <- read.table("~/R/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")

## Read the data into a data frame and name the variables appropriately
testdata <- read.table("~/R/UCI HAR Dataset/test/X_test.txt", col.names = unlist(varlabels[2]))

## Read the activity identifiers into a data frame as factors
testlabels <- read.table("~/R/UCI HAR Dataset/test/y_test.txt", col.names = "activity", colClasses = "factor")

## Replace the numeric levels with their corresponding activity names
levels(testlabels[,1]) <- unlist(activitylabels[,2])
##
## /Test data

## Train data
##
## Read the subject numbers for the into a data frame
trainsubjects <- read.table("~/R/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")

## Read the data into a data frame and name the variables appropriately
traindata <- read.table("~/R/UCI HAR Dataset/train/X_train.txt", col.names = unlist(varlabels[2]))

## Read the activity identifiers into a data frame as factors
trainlabels <- read.table("~/R/UCI HAR Dataset/train/y_train.txt", col.names = "activity", colClasses = "factor")

## Replace the numeric levels with their corresponding activity names
levels(trainlabels[,1]) <- unlist(activitylabels[,2])
##
## /Train data

## Merge formatted test and train data into one data frame using dplyr functions
data <- bind_rows(bind_cols(trainsubjects, trainlabels, traindata), bind_cols(testsubjects, testlabels, testdata))

## select only columns measuring the mean of a given variable
x <- select(data, matches("mean()"))

## Select only columns measuring the standard deviation of a given variable
y <- select(data, matches("std()"))

## Merge Subject column, Activity column, Mean columns, and Standard Deviation columns
##      into data frame, eliminating unneeded columns 
data <- bind_cols(data[,1:2], x, y)

## sort the data frame by subject
data <- data %>% arrange(subject)

## Create a column that concatenates subject and activity resulting in a single column
##      that uniquely identifies each activity/subject combination
data <- data %>% mutate(unique = paste(subject, activity, sep = ""))

## Group by the new column and calculate means for each variable
data <- data %>% group_by(unique) %>% summarise_each(funs(mean))

## Remove the calculated column described above
data <- data %>% select(-unique)

## Sort by activity, then by subject
data <- data %>% arrange(activity) %>% arrange(subject)

## Replace the numeric levels with their corresponding activity names
data$activity <- as.factor(data$activity)
levels(data$activity) <- unlist(activitylabels[,2])

## Output the tidy data set
write.table(data, "~/R/summarydata.txt", row.names = FALSE)