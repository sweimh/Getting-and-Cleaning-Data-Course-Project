---
title: "Code Book"
author: "Mark Hsu"
date: "Saturday, July 25, 2015"
output: markdown
---

Output Variables
----------------

Variable               | Description
-----------------------|------------
Subject.Number         | Subject ID, ranges from 1 to 30. Each Subject ID represent a test participant. 
Activity.Name          | Name of activity preformed by the subject. Six possible activities.
Feature.Domain         | Time domain signal or frequency domain signal. (data: time or frequency)
Feature.Device         | Device measuring the observation. (data: Accelerometer or Gyroscope)
Feature.Source.Signal  | Type of acceleration signal. (data: Body or Gravity)
Feature.Is.Jerk        | Whether the observation is a Jerk. (data: TRUE or FALSE)
Feature.Is.Magnitude   | Whether the observation is a Magnitude. (data: TRUE or FALSE)
Feature.Variable       | Type of calculation variable. (data: Mean or SD)
Feature.Axial          | Directional signals in the X, Y and Z directions. NA when the observation is a Magnitude. (data: X, Y, Z, or NA)
Feature.Count          | Count of data points used to compute
Feature.Average        | Average value for each activity per subject


The variables are created based on observing UCI HAR Dataset, its README file, and tidy data principles, with highlights below. 

## Excerpt from UCI HAR Dataset README.txt
> The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

## Tidy Data Principles

[link](github.com/jtleek/datasharing#the-tidy-data-set)
