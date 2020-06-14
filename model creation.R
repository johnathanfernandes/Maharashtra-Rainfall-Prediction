library(sparklyr) #Import sparklyr package to integrte Spark and R
sc <-
  spark_connect(master = 'local') #Connect to a local spark instance

test_tbl <-
  spark_read_csv(sc, "test", "C:/Users/user/Documents/VIT/Sem 6/EDI/test.csv") #Read the testing dataset directly into a Spark DataFrame
train_tbl <-
  spark_read_csv(sc,
                 "train",
                 "C:/Users/user/Documents/VIT/Sem 6/EDI/train.csv") #Read the testing dataset directly into a Spark DataFrame
actual <-
  read.csv("C:/Users/user/Documents/VIT/Sem 6/EDI/res.csv") #Read the validation dataset

#Model Generation, random forest using 10 trees
fit <- train_tbl %>%
  ml_random_forest_regressor(
    response = "Precipitation",
    features = c(
      "Latitude",
      "Longitude",
      "Max_Temperature",
      "Min_Temperature",
      "Wind",
      "Relative_Humidity",
      "Solar"
    ),
    num_trees = 10
  )

pred <-
  ml_predict(fit, test_tbl) %>% collect  #Generation predioctions on testing set

eval_tbl <-
  as.data.frame(cbind(pred$prediction, actual$Actual.Precipitation)) #Create evaluation DataFrame using validation dataset and predictions

eval <-
  copy_to(sc, eval_tbl, overwrite = TRUE) #Copy validation DataFrame to Spark DataFrame

#Evaluate performance of model
eval <- ml_regression_evaluator(
  eval,
  label_col = 'V2',
  prediction_col = 'V1',
  metric_name = 'rmse',
  uid = 'linear regression'
)
print(eval)
ml_save(fit, "C:/Users/user/Documents/VIT/Sem 6/EDI/MODEL") #Export model for ease of use in GUI
