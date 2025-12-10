# btc-price-tracker
real time bitcoin price tracking
the prices are collected by running my scrapping file 24/7 using crontab 
0 * * * */media/sf_VM_shared/CW_1/btc-price-tracker/btc_price_scrap.sh >> /media/sf_VM_shared/CW_1/btc-price-tracker/cron.log 2>&1
The output of my scrapping file is save to cron.log to check for errors
