#!/bin/bash

# fasting blood glucose levels
if [ ! -e 'P_GLU.XPT' ]; then
  wget https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_GLU.XPT
fi

# demographics: age, gender
if [ ! -e 'P_DEMO.XPT' ]; then
  wget https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_DEMO.XPT
fi

# bmi
if [ ! -e 'P_BMX.XPT' ]; then
  wget https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_BMX.XPT
fi 

# alcohol use
if [ ! -e 'P_ALQ.XPT' ]; then
  wget https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_ALQ.XPT
fi

# physical activty
if [ ! -e 'P_PAQ.XPT' ]; then
  wget https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_PAQ.XPT
fi

# diet
if [ ! -e 'P_DBQ.XPT' ]; then
  wget https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_DBQ.XPT
fi