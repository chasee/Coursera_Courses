# Load packages
require(plyr)

# Get data
if(!file.exists("./data")) {dir.create("./data")}
file.Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
data.Loc <- "./data/dataset.zip"
download.file(file.Url, data.Loc)

unzip(data.Loc, exdir = "./data")
data.path <- file.path("./data", "UCI HAR Dataset")
files <- list.files(data.path, recursive = TRUE)

data.Activity_Test <- read.table(file.path(data.path, files[16]), header = FALSE)
data.Activity_Train <- read.table(file.path(data.path, files[28]), header = FALSE)
data.Subject_Test <- read.table(file.path(data.path, files[14]), header = FALSE)
data.Subject_Train <- read.table(file.path(data.path, files[26]))
data.Features_Test <- read.table(file.path(data.path, files[15]))
data.Features_Train <- read.table(file.path(data.path, files[27]))
data.Features_Names <- read.table(file.path(data.path, files[2]))

# Merge data
data.Subject <- rbind(data.Subject_Train, data.Subject_Test)
data.Activity <- rbind(data.Activity_Train, data.Activity_Test)
data.Features <- rbind(data.Features_Train, data.Features_Test)

names(data.Subject) <- "subject"
names(data.Activity) <- "activity"
names(data.Features) <- data.Features_Names$V2

combine <- cbind(data.Subject, data.Activity)
data <- cbind(data.Features, combine)

# Get mean and sd
sub_data.Features_Names <- data.Features_Names$V2[grep("mean\\(\\)|std\\(\\)", data.Features_Names$V2)]
sel.Names <- c(as.character(sub_data.Features_Names), "subject", "activity")
data_sub <- subset(data, select = sel.Names)

# Rename activities
activity.Labs <- read.table(file.path(data.path, files[1]), header = FALSE)
data_sub$activity <- as.factor(data_sub$activity)
levels(data_sub$activity) <- activity.Labs$V2

# Rename vars
names(data_sub) <- gsub("Acc", "Accelerometer", names(data_sub))
names(data_sub) <- gsub("BodyBody", "Body", names(data_sub))
names(data_sub) <- gsub("^f", "frequency", names(data_sub))
names(data_sub) <- gsub("Gyro", "Gyroscope", names(data_sub))
names(data_sub) <- gsub("Mag", "Magnitude", names(data_sub))
names(data_sub) <- gsub("^t", "time", names(data_sub))

# Create new tidy dataset
data.New <- aggregate(. ~subject + activity, data_sub, mean)
data.New <- data.New[order(data.New$subject, data.New$activity), ]
write.table(data.New, file = "tidydata.txt", row.name = FALSE)