# You should create one R script called run_analysis.R that does the following.
# 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


rm(list=ls())
library(reshape2)

# Activity labels 
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])

# Features
features <- read.table("UCI HAR Dataset/features.txt")

# Extract only the data on mean and standard deviation
features_wanted <- grep(".*mean.*|.*std.*", features[,2])
features_wanted_names <- features[features_wanted,2]
features_wanted_names = gsub('-mean', 'Mean', features_wanted_names)
features_wanted_names = gsub('-std', 'Std', features_wanted_names)
features_wanted_names <- gsub('[-()]', '', features_wanted_names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_wanted]
train_activities <- read.table("UCI HAR Dataset/train/y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_wanted]
test_activities <- read.table("UCI HAR Dataset/test/y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test)

# Merging datasets 
all_data <- rbind(train, test)

# Adding labels
colnames(all_data) <- c("subject", "activity", features_wanted_names)

# Convert activities and subjects into factors
all_data$activity <- factor(all_data$activity, levels = activity_labels[,1], labels = activity_labels[,2])
all_data$subject <- as.factor(all_data$subject)

all_data_melted <- melt(all_data, id = c("subject", "activity"))
all_data_mean <- dcast(all_data_melted, subject + activity ~ variable, mean)

write.table(all_data_mean, "tidy.txt", row.names = FALSE, quote = FALSE)
