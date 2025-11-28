set -e
set -u
set -o pipefail

MYSQL="/opt/lampp/bin/mysql -u root"
URL="https://coinmarketcap.com/currencies/bitcoin/"
DB="btc_price_tracker_db"

timestamp=$(date '+%F %T')
echo "$timestamp, Getting price..."

curl -s $URL -o "temp.html" 

#get price
price=$(grep -oE 'data-test="text-cdp-price-display">\$[0-9,]+(\.[0-9]+)?' "temp.html" | sed -E 's/.*data-test="text-cdp-price-display">//; s/[$,]//g')
echo "Price current: $price"

pricelow=$(grep -oE 'eQBACe label">Low</div><span>\$[0-9,]+(\.[0-9]+)?' "temp.html" | sed -E 's#.QBACe label">Low</div><span>##; s/[$,]//g')
echo "Price 24h low: $pricelow"

pricehigh=$(grep -oE 'eQBACe label">High</div><span>\$[0-9,]+(\.[0-9]+)?' temp.html | sed -E 's#.QBACe label">High</div><span>##; s/[$,]//g')
echo "Price 24h high: $pricehigh"

check if bitcoin price can be extracted to avoid null
if [[ -z "$price" || -z "$pricelow" || -z "$pricehigh" ]]; then
	echo "$timestamp Error: Failed to get Bitcoin price."
	rm temp.html
	exit 1
fi

#Create database
$MYSQL -e "CREATE DATABASE IF NOT EXISTS $DB;"

$MYSQL $DB -e"
CREATE TABLE IF NOT EXISTS BTC_PRICES(
	price_id int auto_increment primary key,
	timestamp datetime not null,
	price decimal(10, 2),
	low_24h decimal(10, 2),
	high_24h decimal(10, 2)
);"

#insert values into database
insert_query="
INSERT INTO BTC_PRICES(timestamp, prie, low_24h, high_24h)
VALUES ("$timestamp", "$price", "$pricelow", $pricehigh");"

$MYSQL $DB -e "$insert_query"
