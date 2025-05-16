library(DBI)
library(RSQLite)
library(dplyr)
library(caret)
library(randomForest)

con <- dbConnect(RSQLite::SQLite(), "obesity_database.sqlite")

# Import cleaned data
train_data <- dbGetQuery(con, "SELECT * FROM ObesityTrainClean")
test_data <- dbGetQuery(con, "SELECT * FROM ObesityTestClean")
dbDisconnect(con)

train_data <- train_data %>%
  mutate(across(where(is.character), as.factor)) %>%
  select(Age_clean, Height_clean, Gender_clean, FAVC_clean,
         FCVC_clean, NCP_clean, CH2O_clean, FAF_clean, TUE_clean, ObStatus)

test_data <- test_data %>%
  mutate(across(where(is.character), as.factor)) %>%
  select(Age_clean, Height_clean, Gender_clean, FAVC_clean,
         FCVC_clean, NCP_clean, CH2O_clean, FAF_clean, TUE_clean)

# Train Random Forest model
set.seed(42)
rf_model <- train(ObStatus ~ ., data = train_data, method = "rf",
                  trControl = trainControl("cv", number = 5), ntree = 500)

pred_train <- predict(rf_model, train_data)
conf_matrix <- confusionMatrix(pred_train, train_data$ObStatus)
print(conf_matrix)

test_preds <- predict(rf_model, test_data)
print("Sample predictions on test data:")
print(head(test_preds))

