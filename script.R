# install.packages(c("RCurl", "bitops", "rjson", "statmod", "tools"))
# install.packages("/Users/aaronhoffer/Downloads/h2o-3.8.2.8/R/h2o_3.8.2.8.tar.gz", repos = NULL, type = "source")
# install.packages("ROCR")
library(tools)
library(RCurl)
library(bitops)
library(rjson)
library(statmod)
library(caret)
library(h2o)
h2o <- h2o.init(nthreads = -1)
h2o.clusterInfo()

sonar.hex = h2o.importFile("sonar.csv")
sonar.split = h2o.splitFrame(data = sonar.hex,
                             ratios = 0.6,
                             seed = 0)
sonar.train = sonar.split[[1]]
sonar.test = sonar.split[[2]]
sonar.train.df = as.data.frame(sonar.train)
sonar.test.df = as.data.frame(sonar.test)

h2o.experiment = function(h2o.learner, parameters) {
  base.parameters = list(x = 1:60,
                         y = 61,
                         training_frame = sonar.train)
  final.parameters = if (missing(parameters))
    base.parameters
  else
    c(base.parameters, parameters)
  fit = do.call(h2o.learner, final.parameters)

  predictions = h2o.predict(fit, sonar.test)
  p =  h2o.performance(fit, sonar.test)
  plot(p)
  print(p)
}

h2o.experiment(h2o.gbm)
h2o.experiment(h2o.glm, list(family = "binomial"))
h2o.experiment(h2o.randomForest)
h2o.experiment(h2o.deeplearning)
