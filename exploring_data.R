library(dplyr)
library(data.table)

setwd("~/documents/instacart")

dt_aisles <- read.table('aisles.csv', header = TRUE, sep = ",") 
dt_departments <- read.table('departments.csv', header = TRUE, sep = ",")
products <- fread('products.csv')
dt_orders <- read.table('orders.csv', header = TRUE, sep = ",") 
dt_priors <- read.table('order_products__prior.csv', header = TRUE, sep = ",")
dt_train <- read.table('order_products__train.csv', header = TRUE, sep = ",")
#dt_submission <- read.table('sample_submission.csv', header = TRUE, sep = ",")

#Create a list of unique products related to each user_id prior orders 

gc()

dt_test <- dt_orders %>%
  filter(eval_set == "test") %>%
  select(order_id, user_id) %>%
  arrange(order_id)

dt_t_product <- dt_orders %>%
  inner_join(dt_priors, by = "order_id") %>%
  select(user_id, product_id)

dt_t_product <- unique(dt_t_product[,])

dt_test <- dt_test %>%
  inner_join(dt_t_product, by = "user_id")

dt_test <- inner_join(dt_orders, dt_test, by = "order_id")
dt_test <- inner_join(products, dt_test, by = "product_id")

#Minor changes to dt_test table
names(dt_test)[6] <- c("user_id")
dt_test <- dt_test[,-12]

dt_test$reordered <- NA

dt_test <- arrange(dt_test, order_id)

dt_test$product_id <- as.factor(dt_test$product_id)
dt_test$aisle_id <- as.factor(dt_test$aisle_id)
dt_test$department_id <- as.factor(dt_test$department_id)
dt_test$product_id <- as.factor(dt_test$product_id)
dt_test$order_id <- as.factor(dt_test$order_id)
dt_test$user_id <- as.factor(dt_test$user_id)
dt_test$order_dow <- as.factor(dt_test$order_dow)
dt_test$order_number <- as.numeric(dt_test$order_number)
dt_test$order_hour_of_day <- as.numeric(dt_test$order_hour_of_day)

#add more information to prior and train

gc()

dt_pt <- rbind(dt_priors, dt_train)

dt_pt <- inner_join(dt_orders, dt_pt, by = "order_id")
dt_pt <- inner_join(products, dt_pt, by = "product_id")

dt_pt <- dt_pt[,-12]

dt_pt$product_id <- as.factor(dt_pt$product_id)
dt_pt$aisle_id <- as.factor(dt_pt$aisle_id)
dt_pt$department_id <- as.factor(dt_pt$department_id)
dt_pt$product_id <- as.factor(dt_pt$product_id)
dt_pt$order_id <- as.factor(dt_pt$order_id)
dt_pt$user_id <- as.factor(dt_pt$user_id)
dt_pt$order_dow <- as.factor(dt_pt$order_dow)
dt_pt$order_number <- as.numeric(dt_pt$order_number)
dt_pt$order_hour_of_day <- as.numeric(dt_pt$order_hour_of_day)

rm(dt_aisles, dt_departments, dt_t_product, dt_orders, dt_priors, dt_train, products)


#create the train data from the training data
gc()

train_train <- dt_pt %>%
  filter(eval_set == "prior")

#Not enough memory on computer (8gb). Save file, rest Rstudio to contiune on.
#save(dt_test, train_train, dt_pt, file = "pre_complete_data.Rdata")

train_train <- train_train %>%
  filter(!is.na(days_since_prior_order)) %>%
  arrange(order_id)

#get test data from training data
train_test <- dt_pt %>%
  filter(eval_set == "train")

#Not enough memory on computer (8gb). Save file, reset rstudio to contiune on.
#save(dt_test, train_test, train_train, file = "pre_complete_data.Rdata")

#remove product_name
dt_test <- dt_test[,-2]
train_test <- train_test[,-2]
train_train <- train_train[,-2]

#change reordered variable into factor.
train_test$reordered <- as.factor(train_test$reordered)
train_train$reordered <- as.factor(train_train$reordered)

gc()

#save Rdata file to continue on with Rstudio
save(dt_test, train_test, train_train, file = "modelingdata.Rdata")



#write file for other program
write.csv(dt_test, file = "test.csv", row.names = FALSE)
write.csv(train_test, file = "train_test.csv", row.names = FALSE)
write.csv(train_train, file = "train_train.csv", row.names = FALSE)

