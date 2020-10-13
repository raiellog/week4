# Variables for file download and unzip

file_name <- "UCIdata.zip"
url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- "UCI HAR Dataset"

# If file doesn't exist, download to working directory
if(!file.exists(file_name)){
  download.file(url,file_name, mode = "wb") 
}

# File unzip verification
if(!file.exists(dir)){
  unzip("UCIdata.zip", files = NULL, exdir=".")
}

# Reading Data
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

X_test <- read.table("UCI HAR Dataset/test/X_test.txt")

X_train <- read.table("UCI HAR Dataset/train/X_train.txt")

y_test <- read.table("UCI HAR Dataset/test/y_test.txt")

y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")

features <- read.table("UCI HAR Dataset/features.txt")  

# Merging training and test sets to create one
dataSet <- rbind(X_train,X_test)

# Extract only the measurements on the mean and standard deviation for each measurement 

Mean_Std<- grep("mean()|std()", features[, 2]) 
dataSet <- dataSet[,Mean_Std]

# Appropriately labels the data set with descriptive activity names
CleanFeatNames <- sapply(features[, 2], function(x) {gsub("[()]", "",x)})
names(dataSet) <- CleanFeatNames[Mean_Std]

subject <- rbind(subject_train, subject_test)
names(subject) <- 'subject'
activity <- rbind(y_train, y_test)
names(activity) <- 'activity'

dataSet <- cbind(subject,activity, dataSet)

#Uses descriptive activity names to name the activities in the data set
act_group <- factor(dataSet$activity)
levels(act_group) <- activity_labels[,2]
dataSet$activity <- act_group

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

# Install reshape2 package
install.packages("reshape2")

library("reshape2")

# melt data to tall skinny data and cast means. Finally write the tidy data to the working directory as "tidy_data.txt"
baseData <- melt(dataSet,(id.vars=c("subject","activity")))
secondDataSet <- dcast(baseData, subject + activity ~ variable, mean)
names(secondDataSet)[-c(1:2)] <- paste("[mean of]" , names(secondDataSet)[-c(1:2)] )
write.table(secondDataSet, "tidy_data.txt", sep = ",")