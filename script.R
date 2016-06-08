# install.packages(c("RCurl", "bitops", "rjson", "statmod", "tools"))
# install.packages("/Users/aaronhoffer/Downloads/h2o-3.8.2.8/R/h2o_3.8.2.8.tar.gz", repos = NULL, type = "source")
# install.packages("ROCR")

# MAKE RESULTS REPEATABLE
seed=0
set.seed(seed)

# LIBRARIES
library(tools)
library(RCurl)
library(bitops)
library(rjson)
library(statmod)
library(caret)
library(h2o)
source("h2o.experiment.R")

# INITIALIZE H2O
h2o <- h2o.init(nthreads = -1)
h2o.clusterInfo()


# LOAD SONAR DATA AND CREATE TRAINING AND TEST SETS
sonar.hex = h2o.importFile("sonar.csv")
sonar.split = h2o.splitFrame(data = sonar.hex,
                             ratios = 0.8,
                             seed = seed)
sonar.train = sonar.split[[1]]
sonar.test = sonar.split[[2]]
sonar.train.df = as.data.frame(sonar.train)
sonar.test.df = as.data.frame(sonar.test)

# CONDUCT EXPERIMENTS
h2o.experiment(h2o.gbm)
h2o.experiment(h2o.glm, list(family = "binomial"))
h2o.experiment(h2o.randomForest)
h2o.experiment(h2o.deeplearning)

p=h2o.experiment(h2o.gbm)
rv=plot(p, type="roc", col="blue",  typ="b",)
