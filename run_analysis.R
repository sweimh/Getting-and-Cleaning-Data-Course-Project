library("reshape2")
library("data.table")
rootPath <- getwd()

# function to display prompt in console
makeprompt <- function(...) {
  cat("[run_analysis.R]", ..., "\n")
}

# 1. Merges the training and the test sets to create one data set.

## read result from the unzip process and learned zip files unzipped into one directory, 
## and path to test and train directories
## store path to root project directory as well as test and train sub directories
list.files()
list.dirs(rootPath)
projectPath <- file.path(rootPath, "UCI HAR Dataset")
testDirPath <- file.path(projectPath, "test")
trainDirPath <- file.path(projectPath, "train")


## read in files to prep for merge - picking only the suject files and Y (activities label) files 
## in both the test and train folders (requirement from the project instruction)

makeprompt('Reading data files...')

dataSubject_Train <- data.table(
  read.table(
    file.path(trainDirPath, "subject_train.txt")
  )
)

dataSubject_Test <- data.table(
  read.table(
    file.path(testDirPath, "subject_test.txt")
  )
)

dataActivity_Train <- data.table(
  read.table(
    file.path(trainDirPath, "y_train.txt")
  )
)

dataActivity_Test <- data.table(
  read.table(
    file.path(testDirPath, "y_test.txt")
  )
)

dataTrain <- data.table(
  read.table(
    file.path(trainDirPath, "X_train.txt")
  )
)

dataTest <- data.table(
  read.table(
    file.path(testDirPath, "X_test.txt")
  )
)


## combine similar data sets together by row combine, and set column name, 
## manually assign column name by referencing description in README.txt

makeprompt('Combine training and testing data...')

dataSubject <- rbind(dataSubject_Train, dataSubject_Test)
dataActivity <- rbind(dataActivity_Train, dataActivity_Test)

setnames(dataSubject, "V1", "Subject.Number")
setnames(dataActivity, "V1", "Activity.Code")

## merge "descriptive" data columns subject & label
dataRowLabels <- cbind(dataSubject, dataActivity)

## get activity names from activity_labels.txt
makeprompt('Merging activity names...')

dataActivityNames <- fread(file.path(projectPath, "activity_labels.txt"))
setnames(dataActivityNames, "V1", "Activity.Code")

## merge "measurement" data columns, reference feature.txt for column names
dataRowLabels <- merge(dataActivityNames, dataRowLabels, by="Activity.Code", all.x=TRUE)
setnames(dataRowLabels, "V2", "Activity.Name")

## read in feature.txt, which contains the dataset column names
dataFeatures <- data.table(read.table(file.path(projectPath, "features.txt")))
dataFeatures


# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

## project requires code to "Subset only measurements for the mean and standard deviation"
## which meant feature names containing mean() and std() text strings
## forward slashes were needed to escape (), which are special characters
## without the slashes %like% mean() pull up same data set as %like% mean
makeprompt('Extracting measurements on mean() & std()...')

dataFeaturesRequired <- dataFeatures[dataFeatures$V2 %like% "mean\\(\\)" | dataFeatures$V2 %like% "std\\(\\)"]

setnames(dataFeaturesRequired, "V1", "Feature.Number")
setnames(dataFeaturesRequired, "V2", "Feature.Name")

## combine to the two observation data sets
dataSets <- rbind(dataTrain, dataTest)

## subset dataSets for only required features
dataSets <- dataSets[, dataFeaturesRequired$Feature.Number, with=FALSE]

# 3. Uses descriptive activity names to name the activities in the data set
makeprompt('Applying feature names...')

## setup column name
options(warn=-1)
colnames(dataSets) <- as.character(dataFeaturesRequired$Feature.Name)
options(warn=0)

## merge data labels & datasets to create the final data table
dataTable <- cbind(dataRowLabels, dataSets)

# 4. Appropriately labels the data set with descriptive variable names. 
makeprompt('Melting...')

dataTable <- melt(data = dataTable, 
                  id = c("Subject.Number","Activity.Code","Activity.Name"), 
                  measure.vars = colnames(dataTable[,grep("mean|std",colnames(dataTable))]))

setnames(dataTable, "variable", "Feature.Name")

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

d <- dataTable

makeprompt('Apply descriptive variable names w/ tidy data principle...')

## grepl two objects
greplTwoObjects <- function (regex1, name1, regex2, name2, hasNA = FALSE) {
  y <- matrix((1:2),nrow=2)
  x <- matrix( 
    c(
      grepl(regex1, d$Feature.Name), 
      grepl(regex2, d$Feature.Name)
    ),
    ncol=nrow(y)
  )
  if(hasNA) {
    factor(x %*% y, labels=c(NA, name1, name2))
  } else {
    factor(x %*% y, labels=c(name1, name2))
  }
  
}

## grepl three objects
greplThreeObjects <- function (regex1, name1, regex2, name2, regex3, name3, hasNA = FALSE) {
  y <- matrix((1:3),nrow=3)
  x <- matrix( 
    c(
      grepl(regex1, d$Feature.Name), 
      grepl(regex2, d$Feature.Name),
      grepl(regex3, d$Feature.Name)
    ),
    ncol=nrow(y)
  )
  if(hasNA) {
    factor(x %*% y, labels=c(NA, name1, name2, name3))
  } else {
    factor(x %*% y, labels=c(name1, name2, name3))
  }
  
}

## feature name contains Jerk meant this was a Jerk measurement, otherwise, this is not
cIs.Jerk <- factor(grepl("Jerk", d$Feature.Name), labels=c(FALSE,TRUE))

## feature name contains Mag meant this was a Magnitude measurement, otherwise, this is not
cIs.Magnitude <- factor(grepl("Mag", d$Feature.Name), labels=c(FALSE,TRUE))

## feature name start w/ t = Time or f = Frequency
cDomain <- greplTwoObjects("^t", "time", "^f", "frequency")

## feature name contains "Acc" = Accelerometer or "Gyro" = Gyroscope
cDevice <- greplTwoObjects("Acc", "Accelerometer", "Gyro", "Gyroscope")

## feature name contains "mean()" = Mean or "std" = Standard deviation
cVariable <- greplTwoObjects("mean()", "Mean", "std", "Standard Deviation")

## feature name contains "Body" = Body or "Gravity" = Gravity
cSource.Signal <- greplTwoObjects("Body", "Body", "Gravity", "Gravity")

## X, Y, Z, or na
cAxial = greplThreeObjects("-X", "X", "-Y", "Y", "-Z", "Z", hasNA = TRUE)

d$feature.Domain <- cDomain   					## time / freq
d$feature.Device <- cDevice						## acc. / gyro
d$feature.Source.Signal <- cSource.Signal		## body / gravity
d$feature.Is.Jerk <- cIs.Jerk					## true / false
d$feature.Is.Magnitude <- cIs.Magnitude			## true / false
d$feature.Variable <- cVariable					## mean / std
d$feature.Axial <- cAxial						## x / y / z / na

setkey(d 
       ,Subject.Number
       ,Activity.Name
       ,feature.Domain
       ,feature.Device
       ,feature.Source.Signal
       ,feature.Is.Jerk
       ,feature.Is.Magnitude
       ,feature.Variable
       ,feature.Axial)

dTidy <- d[, list(count = .N, average = mean(value)), by=key(d)]


makeprompt('Writing tidy data to project-output.txt...')

write.table(dTidy, "project-output.txt", row.name=FALSE)






