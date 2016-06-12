# install.packages(c("RCurl", "bitops", "rjson", "statmod", "tools"))
# install.packages("/Users/aaronhoffer/Downloads/h2o-3.8.2.8/R/h2o_3.8.2.8.tar.gz", repos = NULL, type = "source")
# install.packages("ROCR")
# library(devtools)
# install_github("vqv/ggbiplot")

# MAKE RESULTS REPEATABLE
seed = 0
set.seed(seed)

# LIBRARIES
library(ggbiplot)
library(tools)
library(RCurl)
library(bitops)
library(rjson)
library(statmod)
library(caret)
library(h2o)
library(caret)
library(AppliedPredictiveModeling)
source("h2o.experiment.R")
# INITIALIZE H2O
h2o <- h2o.init(nthreads = -1)

# -------------------------------------------------------
# LOAD SONAR DATA AND CREATE TRAINING AND TEST SETS
# -------------------------------------------------------
sonar.hex = h2o.importFile("sonar.csv")
sonar.df = as.data.frame(sonar.hex)
sonar.features = sonar.df[, 1:60]
names(sonar.df)[61] = "Class"

sonar.split = h2o.splitFrame(data = sonar.hex,
                             ratios = 0.8,
                             seed = seed)
sonar.train = sonar.split[[1]]
sonar.test = sonar.split[[2]]
sonar.train.df = as.data.frame(sonar.train)
sonar.test.df = as.data.frame(sonar.test)


# -------------------------------------------------------
# TRELLIS PLOT
# -------------------------------------------------------
transparentTheme(trans = 0.5)
featurePlot(
  x = sonar.features,
  y = sonar.df$Class,
  plot = "pairs",
  pscales = FALSE,
  cex = 0.05,
  auto.key = list(columns = 2)
)


# -------------------------------------------------------
# PRINCIPAL COMPONENT ANALYSIS OF DATA SET
# -------------------------------------------------------
sonar.princomp = prcomp(sonar.features,
                        center = TRUE,
                        scale = TRUE,
                        retx = TRUE)


# -------------------------------------------------------
# PCA TRELLIS PLOT
# -------------------------------------------------------
transparentTheme(trans = 0.3)
featurePlot(
  x = sonar.princomp$x[, 1:3],
  y = sonar.df$Class,
  plot = "pairs",
  pscales = FALSE,
  auto.key = list(columns = 2)
)


# -------------------------------------------------------
# PLOT FIRST AND SECOND PRINCIPLE COMPONENTS
# -------------------------------------------------------
g <- ggbiplot(
  sonar.princomp,
  obs.scale = 0,
  var.scale = 0,
  groups = sonar.df$Class,
  var.axes = FALSE,
  ellipse = TRUE
)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal',
               legend.position = 'top')
print(g)


# -------------------------------------------------------
# MACHINE LEARNING EXPERIMENTS
# -------------------------------------------------------
h2o.experiment(h2o.gbm)
h2o.experiment(h2o.glm, list(family = "binomial"))
h2o.experiment(h2o.randomForest)
h2o.experiment(h2o.deeplearning)


# PCA EXPERIMENTS
# -------------------------------------------------------
# Perform principle componennt analysis.
# Save the first seven principle components.
class.ind = 7
feature.ind = 1:(class.ind -1)

# Normalize the data before performing the SVD
pca = h2o.prcomp(
  sonar.hex[,1:60],
  k=class.ind,
  transform = "NORMALIZE",
  seed = seed
)
summary(pca)

# Create test and training results from the principle components
sonar.pca = h2o.predict(pca, sonar.hex)
sonar.pca.split = h2o.splitFrame(
 data = h2o.cbind(sonar.pca, sonar.hex[,61]),
 ratios = 0.8,
 seed=seed)
sonar.pca.train = sonar.pca.split[[1]]
sonar.pca.test = sonar.pca.split[[2]]

# Try GLM on the rotated test set.
# It performs awesome with the first seven principle components.
# Performance # gets worse with more or fewer components.
# max min_per_class_accuracy   0.93%
# max mean_per_class_accuracy  0.94%
fit = h2o.glm(
  x =feature.ind,
  y = class.ind,
  training_frame = sonar.pca.train,
  family = "binomial")
predictions = h2o.predict(fit, sonar.pca.test[,feature.ind])
perf = h2o.performance(fit, sonar.pca.test)
plot(perf)
perf

