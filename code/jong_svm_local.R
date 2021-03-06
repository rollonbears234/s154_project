# jong_svm_local.R

library(caret)
library(kernlab)

setwd("~/Desktop/s154_project")
# Loading Initial Data
load("data/clean/train/train_join.RData")
load("data/clean/test/test_join.RData")
# Quick Data Cleaning
joined_train$n.activity <- as.numeric(as.character(joined_train$n.activity))

# Splitting dataset by 80% train, 20% test (from training dataset)
# Preserves factor distribution of the y variable
set.seed(199)
train.ind <- createDataPartition(joined_train$stars, p = 0.8, list = F, times = 1)

# Cleaning up categoricals with only one category
(l <- sapply(joined_train, function(x) is.factor(x)))
m <- joined_train[, l]
leve <- sapply(1:ncol(m), function(x) return(nlevels(m[,x])))
rm.col <- colnames(m)[which(leve==1)]
rm.col <- which(colnames(joined_train) == rm.col)

joined_train <- joined_train[, -rm.col]

train.set <- joined_train[train.ind, ]
test.set <- joined_train[-train.ind, ]

######## 1. SVM Linear and parameter tuning via caret ########

library(doMC)
registerDoMC(cores = 3)
caret.ctrl <- trainControl(method = "none",allowParallel = T, search = "random",
                           preProcOptions = "medianImpute")
svm.lin.model <- caret::train(form = stars ~. , data = train.set,
                              method = "svmRadial", verbose = T,
                              trControl = caret.ctrl)

svm.preds <- predict(svm.lin.model, newdata = joined_test)

svm.lin.mse <- mean((test.set$stars - svm.preds)^2)

save(list = c("svm.lin.model", "svm.lin.mse", "svm.preds") , 
     file = "data/svm.lin.model.RData")


