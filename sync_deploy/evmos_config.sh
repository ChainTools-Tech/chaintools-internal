evmosd config chain-id evmos_9001-2 --home $EVMOS_HOME

# seeds and peers
seeds="9aa8a73ea9364aa3cf7806d4dd25b6aed88d8152@evmos.seed.mzonder.com:10156"
sed -i "s/^seeds *=.*/seeds = \"$seeds\"/" $EVMOS_HOME/config/config.toml

peers=""
sed -i "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $EVMOS_HOME/config/config.toml

# indexing off
indexer="null"
sed -i "s/^indexer *=.*/indexer = \"$indexer\"/" $EVMOS_HOME/config/config.toml

# min-gas
min_gas_price="250000000aevmos"
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"$min_gas_price\"/" $EVMOS_HOME/config/app.toml

# prunning
pruning="custom"
pruning_keep_recent="100000"
pruning_keep_every="0"
pruning_interval="10"

sed -i "s/^pruning *=.*/pruning = \"$pruning\"/" $EVMOS_HOME/config/app.toml
sed -i "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $EVMOS_HOME/config/app.toml
sed -i "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $EVMOS_HOME/config/app.toml
sed -i "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $EVMOS_HOME/config/app.toml

# enable snapshots
sed -i 's/snapshot-interval *=.*/snapshot-interval = 5000/' $EVMOS_HOME/config/app.toml

