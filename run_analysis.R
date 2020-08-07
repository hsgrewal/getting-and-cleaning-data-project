###############################################################################
# FILE                                                                        #
#   run_analysis.R                                                            #
#                                                                             #
# AUTHOR                                                                      #
#   Harkishan Grewal                                                          #
###############################################################################
library(reshape2)

## Download dataset
filename <- "dataset.zip"
# Check if dataset already download, If not, download it
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}
# Check if dataset unzipped, If not, unzip it
if (!file.exists("UCI HAR Dataset")) {
  unzip(filename)
}

# Load activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

# Load features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
mean_sd <- grep(".*mean.*|.*std.*", features[,2])
mean_sd.names <- features[mean_sd,2]
mean_sd.names = gsub('-mean', 'Mean', mean_sd.names)
mean_sd.names = gsub('-std', 'Std', mean_sd.names)
mean_sd.names <- gsub('[-()]', '', mean_sd.names)

# Load the datasets
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")[mean_sd]
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(subject_train, y_train, x_train)

x_test <- read.table("UCI HAR Dataset/test/X_test.txt")[mean_sd]
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(subject_test, y_test, x_test)

# Merge test and train data sets
combined_data <- rbind(train, test)
colnames(combined_data) <- c("subject", "activity", mean_sd.names)

# turn activities & subjects into factors
combined_data$activity <- factor(combined_data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
combined_data$subject <- as.factor(combined_data$subject)

combined_data.melted <- melt(combined_data, id = c("subject", "activity"))
combined_data.mean <- dcast(combined_data.melted, subject + activity ~ variable, mean)

write.table(combined_data.mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)