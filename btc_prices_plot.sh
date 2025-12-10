#!/bin/bash
set -e

MYSQL="sudo /usr/bin/mysql"
DB="btc_price_tracker_db"
CSVFILE="./btc_5pm_price.csv"
PLOTFILE="./btc_5pm_price.png"

echo "Plotting graph..."

# Export only 5pm btc price
$MYSQL -D $DB -B -e "
SELECT DATE(timestamp) AS day, price
FROM BTC_PRICES
WHERE TIME(timestamp) = '17:00:01'
ORDER BY timestamp;
" | sed 's/\t/,/g' > "$CSVFILE"

#gnuploy
gnuplot << EOF
set terminal png size 800,400
set output "$PLOTFILE"
unset key
set datafile separator ","
set xdata time
set timefmt "%Y-%m-%d"
set format x "%d-%b"
set xlabel "Date"
set ylabel "Bitcoin Price (USD)"
set title "Bitcoin Price at 5 PM Each Day"
set grid

plot "$CSVFILE" using 1:2 with linespoints lw 2
EOF
echo "Done"

