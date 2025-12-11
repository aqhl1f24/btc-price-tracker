#!/bin/bash
set -e

MYSQL="sudo /usr/bin/mysql"
DB="btc_price_tracker_db"

echo "Plotting graph..."

#Export only 5pm btc prices
CSV_5PM="./btc_price_5pm.csv"
$MYSQL -D $DB -B -e "
SELECT DATE(timestamp) AS day, price, low_24h, high_24h
FROM BTC_PRICES
WHERE TIME(timestamp) = '17:00:01'
ORDER BY day;
" | sed 's/\t/,/g' > "$CSV_5PM"

#Export btc prices high and low for each day
CSV_WEEK="./btc_week.csv"
$MYSQL -D $DB -B -e "
SELECT DATE(timestamp) AS day, MAX(price) AS price, MAX(low_24h) AS low_24h, MAX(high_24h) AS high_24h
FROM BTC_PRICES
GROUP BY day
ORDER BY day;
" | sed 's/\t/,/g' > "$CSV_WEEK"

#calculate price change rate
awk -F',' '
NR==1 {print $0",change_rate"; next}
{
    if (NR==2) {print $0",0"; prev=$2; next}
    rate = ($2 - prev) / prev * 100
    print $0","rate
    prev=$2
}' "$CSV_5PM" > btc_change_rate.csv

#gnuplot
plot_graph() {
    #arguments
    CSV="$1"
    PNG="$2"
    TITLE="$3"
    YLABEL="$4"
    COL="$5"

    gnuplot << EOF
set terminal png size 900,400
set output "$PNG"
unset key
set datafile separator ","
set xdata time
set timefmt "%Y-%m-%d"
set format x "%d-%b"
set xlabel "Date"
set ylabel "$YLABEL"
set title "$TITLE"
set grid

plot "$CSV" using 1:$COL with linespoints lw 2
EOF
}

#graph 1 btc price at 5pm in a week
plot_graph "$CSV_5PM" "1_btc_price_5pm.png" "BTC Price at 5PM Over a Week" "Price (USD)" 2

#graph 2 btc price change rate in a week
plot_graph "btc_change_rate.csv" "2_price_change_rate_5pm.png" "BTC Price Change Rate at 5PM (%)" "Percentage (%)" 5

#graph 3 btc 24 high
plot_graph "$CSV_WEEK" "3_24h_high_week.png" "BTC 24h High Over a Week" "High (USD)" 4

#graph 4 btc 24h low
plot_graph "$CSV_WEEK" "4_24h_low_week.png" "BTC 24h Low Over a Week" "Low (USD)" 3

echo "Done"

