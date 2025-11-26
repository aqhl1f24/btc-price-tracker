set -e
set -u
set -o pipefail

MYSQL="/opt/lampp/bin/mysql -u root"
URL="https://coinmarketcap.com/currencies/bitcoin/"
DB="btc_price_tracker_db"

timestamp=$(date '+%F %T')
echo "$timestamp, Getting price..."

curl -s $URL -o "temp.html" 

price=$(grep -oE 'data-test="text-cdp-price-display">\$[0-9,]+(\.[0-9]+)?' "temp.html" | sed -E 's/.*data-test="text-cdp-price-display">//; s/[$,]//g')
echo "Price current: $price"

pricelow=$(grep -oE 'eQBACe label">Low</div><span>\$[0-9,]+(\.[0-9]+)?' "temp.html" | sed -E 's#.QBACe label">Low</div><span>##; s/[$,]//g')
echo "Price 24h low: $pricelow"

pricehigh=$(grep -oE 'eQBACe label">High</div><span>\$[0-9,]+(\.[0-9]+)?' temp.html | sed -E 's#.QBACe label">High</div><span>##; s/[$,]//g')
echo "Price 24h high: $pricehigh"
