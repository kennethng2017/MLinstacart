
# coding: utf-8

# In[1]:

import pandas as pd
import random
import gc

train_test = pd.read_csv("train_test.csv")
train_train = pd.read_csv("train_train.csv")


# In[3]:

import random

unique_users = train_test.user_id.unique()

sel_user_ids = [unique_users[i] for i in sorted(random.sample(range(len(unique_users)), 10000)) ]
train = train_train[train_train.user_id.isin(sel_user_ids)]


# In[4]:

train.head()


# In[5]:

train = train.drop('eval_set', axis=1)


# In[6]:

x_train = train.drop("reordered", axis = 1)


# In[7]:

y_train = train["reordered"]


# In[9]:

from sklearn import cross_validation
from sklearn.ensemble import RandomForestClassifier


# In[10]:

clf = RandomForestClassifier(n_estimators=10, min_weight_fraction_leaf=0.1)
scores = cross_validation.cross_val_score(clf, x_train, y_train, cv=3)
scores


# In[ ]:



