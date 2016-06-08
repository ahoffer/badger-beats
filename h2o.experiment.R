# Given an h2o learning function and realted parameters,
# evaluate its performance on the sonar data set

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
