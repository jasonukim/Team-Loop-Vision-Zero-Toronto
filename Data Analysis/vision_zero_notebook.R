#loading datasets 

library(readr)
vz <- read_csv("D:/Google Drive/Loop/Vision Zero/Collisions Dataset/clean-collisions-hoods.csv",
               col_types = cols(collision_date = col_date(format = "%m/%d/%Y")))
# loading on mac
vz <- read_csv("/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/clean-collisions-hoods.csv",
               col_types = cols(collision_date = col_date(format = "%m/%d/%Y")))

hoodprofiles <- read_csv("Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Cleaned - Hood Profiles 2016.csv")

income <- read_csv("/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Cleaned - THP-Income.csv")

civics <- read_csv("/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Cleaned - WB-Civics.csv")

economics <- read_csv("/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Cleaned - WB-Economics.csv")

transportation <- read_csv("/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Cleaned - WB-Transportation.csv")  

language <- read_csv("/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/THP-Language.csv")

##################### 
## Pre-processing ##
####################

## Hood Profiles - binarizing attributes for target populations 

mean_child <- mean(hoodprofiles$`Children (0-14 years)`)
mean_senior <- mean(hoodprofiles$`Seniors (65+ years)`)
mean_minority <- mean(hoodprofiles$`% Visible Minority`)
mean_immigrant <- mean(hoodprofiles$`% Immigrants`)
mean_commute_car <- mean(hoodprofiles$`% Commute in Car truck`)

## Does the neighbourhood have more children/seniors/visible minorities/immigrants living in it than is average for the city?
hoodprofiles$child_check <- ifelse(hoodprofiles$`Children (0-14 years)` > mean_child, 1, 0)
hoodprofiles$senior_check <- ifelse(hoodprofiles$`Seniors (65+ years)` > mean_senior, 1, 0)
hoodprofiles$minority_check <- ifelse(hoodprofiles$`% Visible Minority` > mean_minority, 1, 0)
hoodprofiles$immigrants_check <- ifelse(hoodprofiles$`% Immigrants` > mean_immigrant, 1, 0)

## Does the neighbourhood have more people who use car as primary mode of transporation to work than is average for the city?
hoodprofiles$commute_car_check <- ifelse(hoodprofiles$`% Commute in Car truck` > mean_commute_car, 1, 0) 

# Remove variables having high missing percentage (50%)
hoodprofiles <- hoodprofiles[, colMeans(is.na(hoodprofiles)) <= .5]
# Remove variables with zero or near zero variance (aka nearly all rows have same value)
library(caret)
nzv <- nearZeroVar(hoodprofiles)
nzv # 0 variables found
write.csv(hoodprofiles, file = "Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Processed - Hood Profiles 2016.csv", row.names = FALSE)

## Does the neighbourhood have an above average percentage of low income households as defined by the Low Income Measure?
income$lim_check <- ifelse(income$`Total % In LIM-AT` > mean(income$`Total % In LIM-AT`), 1, 0)
# Remove variables with zero or near zero variance (aka nearly all rows have same value)
nzv <- nearZeroVar(income)
nzv # 0 variables found
write.csv(income, file = "Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Processed - Income.csv", row.names = FALSE)

## Does the neighbourhood have a below avg equity score / walk score / diversity index / voter turnout?
civics$equity_check <- ifelse(civics$`Neighbourhood Equity Score` < mean(civics$`Neighbourhood Equity Score`), 1, 0)
civics$walk_check <- ifelse(civics$`Walk Score` < mean(civics$`Walk Score`), 1, 0)
civics$diversity_check <- ifelse(civics$`Diversity Index - 2008` < mean(civics$`Diversity Index - 2008`), 1, 0)
civics$turnout_check <- ifelse(civics$`Voter Turnout - 2008` < mean(civics$`Voter Turnout - 2008`), 1, 0)

# Remove variables with zero or near zero variance (aka nearly all rows have same value)
nzv <- nearZeroVar(civics)
nzv # 0 found 

write.csv(civics, file = "Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Processed - Civics.csv", row.names = FALSE)

## Does the neighbourhood have above avg number of businesses, child care spaces, home prices, local employment, and social assistance recepients?

economics$businesses_check <- ifelse(economics$`Number of Businesses` > mean(economics$`Number of Businesses`), 1, 0)
economics$childcare_check <- ifelse(economics$`Child Care Spaces` > mean(economics$`Child Care Spaces`), 1, 0)
economics$homeprice_check <- ifelse(economics$`Home Prices` > mean(economics$`Home Prices`), 1, 0)
economics$localemployment_check <- ifelse(economics$`Local Employment` > mean(economics$`Local Employment`), 1, 0)
economics$socialasst_check <- ifelse(economics$`Social Assistance Recipients` > mean(economics$`Social Assistance Recipients`), 1, 0)

# Remove variables with zero or near zero variance (aka nearly all rows have same value)
nzv <- nearZeroVar(economics)
nzv # none found 

write.csv(economics, file = "Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Processed - Economics.csv", row.names = FALSE)

## Does the neighbourhood have above average TTC stops, road kilometeres, road volume?
transportation$ttc_check <- ifelse(transportation$`TTC Stops` > mean(transportation$`TTC Stops`), 1, 0)
transportation$road_km_check <- ifelse(transportation$`Road Kilometres` > mean(transportation$`Road Kilometres`), 1, 0)
transportation$road_vol_check <- ifelse(transportation$`Road Volume` > mean(transportation$`Road Volume`), 1, 0)

# Remove variables with zero or near zero variance (aka nearly all rows have same value)
nzv <- nearZeroVar(transportation)
nzv #none found 
write.csv(transportation, file = "Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Processed - Transportation.csv", row.names = FALSE)

## Does the neighbourhood have above average % of people who speak a non-official language at home?
language$language_check <- ifelse(language$`% NON-OFFICIAL LANG AT HOME` > mean(language$`% NON-OFFICIAL LANG AT HOME`), 1, 0)

# Remove variables with zero or near zero variance (aka nearly all rows have same value)
nzv <- nearZeroVar(language)
nzv # none found
write.csv(language, file = "Google Drive/Loop/Vision Zero/Collisions Dataset/Joinable datasets/Processed - Language.csv", row.names = FALSE)

# Pre-processing on Collisions dataset 
## Binarizing injury outcomes 
vz$ksi_check <- ifelse(vz$involved_injury_class == "FATAL" | vz$involved_injury_class == "MAJOR", 1, 0)
vz$fatal_check <- ifelse(vz$involved_injury_class == "FATAL", 1, 0)

## Binarizing location
sum(is.na(vz$location_desc))
vz <- vz[!is.na(vz$location_desc),]
vz$intersection_check <- ifelse(vz$location_desc == "INTERSECTION", 1, 0)
sum(vz$intersection_check)

## Binarizing age
vz$is_senior <- ifelse(vz$involved_age >= 65, 1, 0)
vz$is_child <- ifelse(vz$involved_age < 18, 1, 0)

## Binarizing light, visibility, road condition, road class, involved_class
vz$daylight_check <- ifelse(vz$light == "DAYLIGHT", 1, 0)
vz$visibilily_check <- ifelse(vz$visibility == "CLEAR", 1, 0) 
vz$road_surface_cond <- ifelse(vz$road_surface_cond == "DRY", 1, 0)
vz$arterial_check <- ifelse(vz$road_class == "MAJOR ARTERIAL" | vz$road_class == "MINOR ARTERIAL", 1, 0)
vz$pedestrian_check <- ifelse(vz$involved_class == "PEDESTRIAN", 1, 0)

## cleaning rows w null values for certain key attributes 
vz <- vz[!is.na(vz$AREA_S_CD),]
vz <- vz[!is.na(vz$LFN_ID),]
vz <- vz[!is.na(vz$involved_age),]
vz <- vz[!is.na(vz$location_desc),]
vz <- vz[!is.na(vz$daylight_check),]
# Remove variables having high missing percentage (50%)
vz <- vz[, colMeans(is.na(vz)) <= .5]
# Remove variables with zero or near zero variance (aka nearly all rows have same value)
nzv <- nearZeroVar(vz)
nzv # 2 variables found
vz <- vz[, -nzv]

## subsetting numeric variables
vz$collision_id <- as.factor(vz$collision_id)
vz$LFN_ID <- as.factor(vz$LFN_ID)
vz$AREA_S_CD <- as.factor(vz$AREA_S_CD)
vz$px <- as.factor(vz$px)
vz_num <- Filter(is.numeric, vz)

## write processed collisions csv

write.csv(vz, file = "/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/processed-collisions-hoods.csv", row.names = FALSE)

## Pre-processing collisions by hood and collisions by street datasets 
# Join neighbourhood-level detail datasets to collisions dataset

m1 <- merge(vz, hoodprofiles, by.x = "AREA_S_CD", by.y = "Hood ID", all.x = T)
m1 <- merge(m1, income, by.x = "AREA_S_CD", by.y = "HOOD ID", all.x = T)
m1 <- merge(m1, language, by.x = "AREA_S_CD", by.y = "HOOD ID", all.x = T)
m1 <- merge(m1, civics, by.x = "AREA_S_CD", by.y = "Neighbourhood Id", all.x = T)
m1 <- merge(m1, economics, by.x = "AREA_S_CD", by.y = "Neighbourhood Id", all.x = T)
m1 <- merge(m1, transportation, by.x = "AREA_S_CD", by.y = "Neighbourhood Id", all.x = T)
View(m1)

#cleaning redundant columns
m1$`HOOD NAME.x` <- NULL
m1$`Hood Name`<- NULL
m1$`HOOD NAME.y`<- NULL
m1$Neighbourhood.x <- NULL
m1$Neighbourhood.y <- NULL
m1$Neighbourhood <- NULL

#write the m1 (everything joined) dataset

write.csv(m1, file = "Google Drive/Loop/Vision Zero/Collisions Dataset/Processed - Everything Joined.csv", row.names = FALSE)

#subset numeric attributes 

m1_num <- Filter(is.numeric, m1)

hinhoods <- read.csv("/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/collisions-by-hood.csv", header = T, sep = ",")
hinstreets <- read.csv("/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/collisions-by-street.csv", header = T, sep = ",")

hinhoods$HOOD.ID <- as.factor(hinhoods$HOOD.ID)
hinhoods$AREA.NAME<- as.factor(hinhoods$AREA.NAME)

hinstreets$LFN_ID <- as.factor(hinstreets$LFN_ID)
hinstreets$street1 <- as.factor(hinstreets$street1)

# joining datasets 
# join all neighbourhood-level data 
hinhoods <- merge(x = hinhoods, y = civics[,c(2:13)], by.x ="HOOD.ID", by.y = "Neighbourhood Id", all.x = T)
hinhoods <- merge(x = hinhoods, y = economics[,c(2:13)], by.x ="HOOD.ID", by.y = "Neighbourhood Id", all.x = T)
hinhoods <- merge(x = hinhoods, y = income[,c(1,3)], by.x ="HOOD.ID", by.y = "HOOD ID", all.x = T)
hinhoods <- merge(x = hinhoods, y = language[,c(1,3:8)], by.x ="HOOD.ID", by.y = "HOOD ID", all.x = T)
hinhoods <- merge(x = hinhoods, y = hoodprofiles[,c(2:36)], by.x ="HOOD.ID", by.y = "Hood ID", all.x = T)
hinhoods <- merge(x = hinhoods, y = transportation[,c(2:10)], by.x ="HOOD.ID", by.y = "Neighbourhood Id", all.x = T)

# add street lengths in km 
hinstreets <- merge(x = hinstreets, y = vz[,c("LFN_ID", "total_length")], by ="LFN_ID", all.x = T)
library(dplyr)
hinstreets <- hinstreets %>% distinct
hinhoods$HOOD.ID <- as.factor(hinhoods$HOOD.ID)
hinstreets$LFN_ID <- as.factor(hinstreets$LFN_ID)


## Creating new variables for the collisions by hoods and street datasets 
# new hoods variables
# collision density measures
hinhoods$collisions.per.road.km <- hinhoods$Number.of.Collisions/hinhoods$Road.Kilometres
hinhoods$ksi.per.road.km <- hinhoods$Number.of.KSIs/hinhoods$Road.Kilometres
hinhoods$deaths.per.road.km <- hinhoods$Number.of.Deaths/hinhoods$Road.Kilometres
hinstreets$collisions.per.road.km <- hinstreets$Number.of.Collisions/hinstreets$total_length.x
hinstreets$ksi.per.road.km <- hinstreets$Number.of.KSIs/hinstreets$total_length.x
#death per km near zero variance that's why not included 

## collision rate 
hinhoods$collisions.per.100k <- hinhoods$Number.of.Collisions/(sum(hinhoods$Population.2016)/100000)
hinhoods$ksi.per.100k <- hinhoods$Number.of.KSIs/(sum(hinhoods$Population.2016)/100000)
hinhoods$deaths.per.100k <- hinhoods$Number.of.Deaths/(sum(hinhoods$Population.2016)/100000)

## non-KSI occurences 
hinhoods$Number.of.NonKSIs <- (hinhoods$Number.of.Collisions - hinhoods$Number.of.KSIs)
hinstreets$Number.of.NonKSIs <- (hinstreets$Number.of.Collisions - hinstreets$Number.of.KSIs)

## cleaning 
colnames(hinhoods)
hinhoods <- hinhoods[,-82] # this column uses data made obsolete by the Number of Collisions column

# Remove variables having high missing percentage (50%)
hinhoods <- hinhoods[, colMeans(is.na(hinhoods)) <= .5]
hinstreets <- hinstreets[, colMeans(is.na(hinstreets)) <= .5]
# Remove variables with zero or near zero variance (aka nearly all rows have same value)
nzv <- nearZeroVar(hinhoods)
nzv # no variables found 

# Remove variables with zero or near zero variance (aka nearly all rows have same value)
nzv <- nearZeroVar(hinstreets)
nzv # variable #5 (aka Total Deaths) doesn't contribute much to dataset since it has near zero variance
hinstreets <- hinstreets[, -nzv]


# write new csvs 
write.csv(hinhoods, "/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/collisions-by-hood.csv", row.names = FALSE)
write.csv(hinstreets, "/Users/jasonkim/Google Drive/Loop/Vision Zero/Collisions Dataset/collisions-by-street.csv", row.names = FALSE)


# subset numeric variables 
hinhoods_num <- Filter(is.numeric, hinhoods)
hinstreets_num <- Filter(is.numeric, hinstreets)

#########################################
## Correlation, Significant Variables ##
########################################

# Correlation and Significance 
set.seed(1)
library(mlbench)
library(caret)
library(corrplot)

# Function to calc p values in correlation matrix
cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}
# Collisions Dataset 
# Is there a significant relationship b/w non-KSI occurrence and KSIs in a given neighbourhood? 
cor.test(hinhoods$Number.of.NonKSIs, hinhoods_num$Number.of.KSIs, data = hinhoods_num)
plot(hinhoods_num$Number.of.KSIs,hinhoods$Number.of.NonKSIs)
# With a Pearson's R of 0.93 and p-value of < 0.01, we can say that there is a highly significant, strong positive correlation b/w non-KSIs and KSIs; that is, the more non-KSIs a neighbourhood has, it tends to have more KSIs. 
# However, because the correlation is so strong, this is grounds to suspect this is a pair-wise correlation (collinearity).
# This is why we chose to identify all pair-wise correlations and exclude them below 

############################
# Collisions (vz) dataset ##
############################
set.seed(1)
cor_vz <- cor(vz_num)
# find attributes that are highly corrected i.e. >|0.9| (candidates for removal due to pair-wise correlations)
highlyCorrelated_vz <- findCorrelation(cor_vz, cutoff=0.8, verbose = T)
# print indexes of highly correlated attributes
print(highlyCorrelated_vz)
# print names of highly correlated attributes 
highlyCorrelated_vz_names <- colnames(vz_num)[highlyCorrelated_vz]
highlyCorrelated_vz_names
# remove highly correlated attributes and create new dataframe
vz_clean <- vz[, -which(colnames(vz) %in% highlyCorrelated_vz_names)]
dim(vz_clean)

# show correlation matrix with highly correlated pair-wise attributes removed 
cor_vz_cutoff <- cor(Filter(is.numeric, vz_clean), method = "spearman")
colnames(cor_vz_cutoff) <- abbreviate(colnames(cor_vz_cutoff), minlength=30)
rownames(cor_vz_cutoff) <- abbreviate(rownames(cor_vz_cutoff), minlength=30)
p.mat <- cor.mtest(cor_vz_cutoff)
corrplot(cor_vz_cutoff, method = "ellipse", type = "lower", diag = F, insig = "p-value", sig.level = 0.05, p.mat = p.mat)
# There's a weak positive correlation of a KSI collision and age, but it isn't statistifically significant. The p-values of the insignificant
# variables are listed in the matrix. In order to see if neighbourhood-level factors affect individual collisions, we will look at correlation of all variables from the everything joined dataset. 

cor_m1 <- cor(m1_num)
# find attributes that are highly corrected i.e. >|0.9| (candidates for removal due to pair-wise correlations)
highlyCorrelated_m1 <- findCorrelation(cor_m1, cutoff=0.8, verbose = T)
# print indexes of highly correlated attributes
print(highlyCorrelated_m1)
# print names of highly correlated attributes 
highlyCorrelated_m1_names <- colnames(m1_num)[highlyCorrelated_m1]
highlyCorrelated_m1_names
# remove highly correlated attributes and create new dataframe
m1_clean <- m1[, -which(colnames(m1) %in% highlyCorrelated_m1_names)]
dim(m1_clean)

# show correlation matrix with highly correlated pair-wise attributes removed 
cor_m1_cutoff <- cor(Filter(is.numeric, m1_clean), method = "spearman")
colnames(cor_m1_cutoff) <- abbreviate(colnames(cor_m1_cutoff), minlength=30)
rownames(cor_m1_cutoff) <- abbreviate(rownames(cor_m1_cutoff), minlength=30)
p.mat <- cor.mtest(cor_m1_cutoff)
corrplot(cor_m1_cutoff, method = "ellipse", type = "lower", diag = F, insig = "blank", sig.level = 0.05, p.mat = p.mat, tl.cex = 0.55)

# There are no significant variables which correlate to KSIs according to spearman 

# Feature selection w  logistic regression

library(caret)
install.packages('e1071', dependencies=TRUE)
library(e1071)
#subset numeric variables
m1_clean2 <- Filter(is.numeric, m1_clean)
# define training control
control <- trainControl(method="repeatedcv", number=10, repeats = 3)
# train the logistic regression model
m1_clean2$ksi_check <- as.factor(m1_clean2$ksi_check)
model <- train(ksi_check~., data=m1_clean2, trControl=control, method="glm", family="binomial")
# summarize results
print(model)

# Logistic regression has 91.8% accuracy using 10-fold cross validation and a kappa value of 0.001 (lower is better)

#### Feature selection using Recursive Feature Elimination and logistic regression 
set.seed(1)
library(mlbench)
library(caret)
library(randomForest)

# run the RFE algorithm
control <- rfeControl(functions=rfFuncs, method="cv", number=10)
results2 <- rfe(m1_clean2[,c(1:6, 8:60)], m1_clean2[,7], sizes=c(1:59), rfeControl=control)
# summarize the results
print(results2)
# list the chosen features
predictors(results)
reduced.predictors <- predictors(results)
# plot the results
plot(results, type=c("g", "o"))



#
# Correlation of Variables 

library(corrplot)
colnames(hinhoods_num)
reduced.hinhoods.df <- hinhoods_num[,c(1:3, 6:7, 16:38, 40:44, 51:53, 55:58, 60:90)] 
cor_hinhoods <- cor(reduced.hinhoods.df, method = "pearson")
p.mat <- cor.mtest(reduced.hinhoods.df)
corrplot(cor_hinhoods, method = "ellipse", sig.level = 0.05, type = "upper", diag = F)


# Collisions Dataset
# matrix of the p-value of the correlations
p.mat <- cor.mtest(reduced.model.df)

# creating a dataframe with reduced model variables
# collisions dataset
colnames(m1)
reduced.model.df <- m1_num[,c(1:3, 6:7, 9:10, 12, 14:15, 23, 45)] 
cor_m1 <- cor(reduced.model.df, method = "spearman")
corrplot(cor_m1, method = "ellipse", sig.level = 0.05)



##########################################
# Collisions by Hoods (hinhoods) dataset #
##########################################

# Based on traffic and statistical theory, we should assume the distribution of ksis to be a poisson distribution and not normal.
# We will check whether we can hold this assumption:
hist(hinhoods_clean$ksi.per.road.km, breaks = 10)
mean(hinhoods_clean$ksi.per.road.km)
var(hinhoods_clean$ksi.per.road.km)
# The distribution of ksi density among the 140 neighbourhoods is right-skewed, and the mean is greater than variance, 
# which suggests it is not overdispersed therefore poisson regression is applicable

# create dataframes containing the correlation matrix 
cor_hinhoods <- cor(hinhoods_num, method = "pearson")

# find attributes that are highly corrected i.e. >|0.8| (candidates for removal due to pair-wise correlations)
highlyCorrelated_hinhoods <- findCorrelation(cor_hinhoods, cutoff=0.8, verbose = T)
# print indexes of highly correlated attributes
print(highlyCorrelated_hinhoods)
# print names of highly correlated attributes 
highlyCorrelated_hinhoods_names <- colnames(hinhoods_num)[highlyCorrelated_hinhoods]
highlyCorrelated_hinhoods_names
# remove highly correlated attributes and create new dataframe
hinhoods_clean <- hinhoods[, -which(colnames(hinhoods) %in% highlyCorrelated_hinhoods_names)]
dim(hinhoods_clean)

# show correlation matrix with highly correlated pair-wise attributes removed 
cor_hinhoods_cutoff <- cor(Filter(is.numeric, hinhoods_clean), method = "pearson")
colnames(cor_hinhoods_cutoff) <- abbreviate(colnames(cor_hinhoods_cutoff), minlength=30)
rownames(cor_hinhoods_cutoff) <- abbreviate(rownames(cor_hinhoods_cutoff), minlength=30)
p.mat <- cor.mtest(cor_hinhoods_cutoff)
corrplot(cor_hinhoods_cutoff, method = "ellipse", order = "hclust", sig.level = 0.05, type = "upper", diag = F,  tl.cex = 0.55, p.mat = p.mat, insig = "blank")

# Feature selection w random Forest
library(randomForest)
#Train Random Forest
hinhoods_clean2 <- hinhoods_clean[,c(-1,-2)]
rf_hinhoods <-randomForest(ksi.per.road.km~.,data=hinhoods_clean2, importance=TRUE,ntree=1000)
plot(rf_hinhoods) # plot shows acceptable mean squared residuals for 1000 trees
rf_hinhoods # 70.44% of variance in ksi.per.road.km is explained by random forest 

#Evaluate variable importance and order from most important to least 
imp <- importance(rf_hinhoods, type=1)
imp <- data.frame(predictors=rownames(imp),imp)
imp.sort <- arrange(imp,desc(X.IncMSE))
imp.sort$predictors <- factor(imp.sort$predictors,levels=imp.sort$predictors)

# Select the top 10 predictors
imp.10<- imp.sort[1:10,]
print(imp.10)

# Plot Important Variables
varImpPlot(rf_hinhoods, type=1) 

#### method 2 of feature selection using Recursive Feature Elimination and random forest
set.seed(1)
library(mlbench)
library(caret)
# define the control using a random forest selection function
control <- rfeControl(functions=rfFuncs, method="repeatedcv", number=10, repeats = 3)
# run the RFE algorithm
results <- rfe(hinhoods_clean2[,c(1:52, 54:55)], hinhoods_clean2[,53], sizes=c(1:54), rfeControl=control)
# summarize the results
print(results)
# list the chosen features
predictors(results)
reduced.predictors <- predictors(results)
# plot the results
plot(results, type=c("g", "o"))

# The model with 32 variables was selected due to performing the best with lowest RMSE; 
# this reduced our full model of 54 variables down to 32.  



###################################
## Regression and Classification ##
###################################


# logistic regression
# summary(glm(ksi_check ~ ., data = vz_num, family = "binomial"))
summary(glm(ksi_check ~ total_length + involved_age + intersection_check + is_senior + daylight_check + road_surface_cond + pedestrian_check, family = "binomial", data = vz_num))

# creating collision date attributes to see if seasonality is a factor 
library(lubridate)
vz$collision_year <- year(vz$collision_date)
vz$collision_month <- month(vz$collision_date)
vz$collision_day <- day(vz$collision_date)
vz$collision_wday <- wday(vz$collision_date)
vz$collision_time <- as.POSIXct(sprintf("%04.0f", vz$collision_time), format='%H%M')
vz$colllision_hour <- hour(vz$collision_time) 

# Logististic regression

summary(glm(ksi_check ~ collision_year + collision_month + collision_day + collision_wday + collision_hour, data = vz, family = "binomial"))

# year, month, day, and weekday were not significiant when predicting KSI and therefore the null hypothesis is not rejected
# year was very significant when predicting fatalities, though due to the sparseness of fatalities, it may be a spurious result

# current ksi model of significant variables in predicting KSIs and deaths:

summary(glm(ksi_check ~ total_length + involved_age + intersection_check + is_senior + daylight_check + road_surface_cond + pedestrian_check, family = "binomial", data = vz_num))
summary(glm(intersection_check ~ ksi_check + fatal_check, data = vz, family = "binomial"))

# Therefore, for KSIs: long road length, seniority, road surface conditions, and being a pedestrian have higher log odds of being involved in a KSI while being at an intersection or occuring in broad daylight lowers the log odds. 
# All of these variables are highly significant when predicting KSIs with p-values < 0.0004


plot(vz$involved_age, vz$ksi_check,xlab="Age",ylab="Probability of KSI") 
age <- glm(ksi_check ~ involved_age, data = vz, family = "binomial")
curve(predict(age,data.frame(involved_age=x),type="resp"),add=TRUE) 


# Collisions by Hood Dataset - Multiple linear regression
hinhoods_reduced_num <- hinhoods[,c("ksi.per.road.km", reduced.predictors)]
summary(glm(ksi.per.road.km~., data = hinhoods_reduced_num))
# define the control 
control <- trainControl(method="cv", number=10)

model <- train(
  ksi.per.road.km ~ .,
  data = hinhoods_reduced_num,
  method = "glm",
  trControl = control)

print(model)
summary(model)



#################################
## Toronto High Injury Network ##
#################################

# The bulk of our exploratory data analysis was done through the creation of a new tool for city planners and ordinary citizens we are calling
# the Toronto High Injury Network (THIN). These are the normalized values we used to calculate the Composite Score:

#The Composite Score is a measure we created to simplify and expedite planning traffic safety implementations. 
# It uses the min-max normalized values of attributes highly correlated to high KSI density. KSI density is used because it was established
# as the overall best outcome variable to use since there is little risk of colinearity and because it overall is good at predicting
# the risk an area or street poses to pedestrians and cyclists. That is, if a street or area has high KSI density, that means it is also likely to have an usually high amount of collisions
# that don't result in either a death or hospitalization. The KSI density also minimizes the effect of particularly long or high volume streets on collisions. 

# But KSI density isn't all. Because of the nature of the Vision Zero Challenge, we've also included normalized
# values for high priority attributes that target streets or areas with above average concentrations of newcomers, seniors, school children, 
# and low income people.  Taken together, the Composite Score quantifies the abstract concept of a high risk zone, making it easy to
# target specific streets and neighbourhoods and compare these against eachother without taking into consideration differences in size and other factors.

# min-max normalizing the variables used to calculate the Composite Score
norm <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

hinhoods_norm <- as.data.frame(lapply(hinhoods[c(8:9, 40, 45, 48, 50, 54, 60, 89:90)], norm))
hinhoods_norm$composite_score <- (rowSums(hinhoods_norm)/length(hinhoods_norm))*100
# distribution of scores -- approximately normal
hist(hinhoods_norm$composite_score)
hinhoods_scored <- cbind(hinhoods, hinhoods_norm$composite_score)

write.csv(hinhoods_scored, file = "Google Drive/Loop/Vision Zero/Collisions Dataset/hin-hoods-scored.csv", row.names = FALSE)


hinstreets_num <- Filter(is.numeric, hinstreets)
hinstreets_norm <- as.data.frame(lapply(hinstreets_num[c(1:2, 5:6, 16:17)], norm))
hinstreets_norm$composite_score <- (rowSums(hinstreets_norm)/length(hinstreets_norm))*100
# distribution of scores -- right skewed, poisson distribution 
hist(hinstreets_norm$composite_score)
hinstreets_scored <- cbind(hinstreets, hinstreets_norm$composite_score)

write.csv(hinstreets_scored, file = "Google Drive/Loop/Vision Zero/Collisions Dataset/hin-streets-scored.csv", row.names = FALSE)


  

