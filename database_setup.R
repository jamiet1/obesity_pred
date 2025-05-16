library(DBI)
library(RSQLite)

# Connect and create database
con <- dbConnect(RSQLite::SQLite(), "obesity_database.sqlite")

train_raw <- read.csv("ObesityTrain2.csv")
test_raw <- read.csv("ObesityTestNoY2.csv")

dbWriteTable(con, "ObesityTrainRaw", train_raw, overwrite = TRUE)
dbWriteTable(con, "ObesityTestRaw", test_raw, overwrite = TRUE)

# Clean and impute missing values for selected columns
sql_clean_train <- "
CREATE TABLE ObesityTrainClean AS
SELECT *,
  COALESCE(Age, (SELECT AVG(Age) FROM ObesityTrainRaw)) AS Age_clean,
  COALESCE(Height, (SELECT AVG(Height) FROM ObesityTrainRaw)) AS Height_clean,
  COALESCE(Gender, (SELECT Gender FROM ObesityTrainRaw GROUP BY Gender ORDER BY COUNT(*) DESC LIMIT 1)) AS Gender_clean,
  COALESCE(FAVC, (SELECT FAVC FROM ObesityTrainRaw GROUP BY FAVC ORDER BY COUNT(*) DESC LIMIT 1)) AS FAVC_clean,
  COALESCE(FCVC, (SELECT AVG(FCVC) FROM ObesityTrainRaw)) AS FCVC_clean,
  COALESCE(NCP, (SELECT AVG(NCP) FROM ObesityTrainRaw)) AS NCP_clean,
  COALESCE(CH2O, (SELECT AVG(CH2O) FROM ObesityTrainRaw)) AS CH2O_clean,
  COALESCE(FAF, (SELECT AVG(FAF) FROM ObesityTrainRaw)) AS FAF_clean,
  COALESCE(TUE, (SELECT AVG(TUE) FROM ObesityTrainRaw)) AS TUE_clean
FROM ObesityTrainRaw;
"
dbExecute(con, sql_clean_train)

sql_clean_test <- "
CREATE TABLE ObesityTestClean AS
SELECT *,
  COALESCE(Age, (SELECT AVG(Age) FROM ObesityTestRaw)) AS Age_clean,
  COALESCE(Height, (SELECT AVG(Height) FROM ObesityTestRaw)) AS Height_clean,
  COALESCE(Gender, (SELECT Gender FROM ObesityTestRaw GROUP BY Gender ORDER BY COUNT(*) DESC LIMIT 1)) AS Gender_clean,
  COALESCE(FAVC, (SELECT FAVC FROM ObesityTestRaw GROUP BY FAVC ORDER BY COUNT(*) DESC LIMIT 1)) AS FAVC_clean,
  COALESCE(FCVC, (SELECT AVG(FCVC) FROM ObesityTestRaw)) AS FCVC_clean,
  COALESCE(NCP, (SELECT AVG(NCP) FROM ObesityTestRaw)) AS NCP_clean,
  COALESCE(CH2O, (SELECT AVG(CH2O) FROM ObesityTestRaw)) AS CH2O_clean,
  COALESCE(FAF, (SELECT AVG(FAF) FROM ObesityTestRaw)) AS FAF_clean,
  COALESCE(TUE, (SELECT AVG(TUE) FROM ObesityTestRaw)) AS TUE_clean
FROM ObesityTestRaw;
"
dbExecute(con, sql_clean_test)

print(dbListTables(con))
dbDisconnect(con)

