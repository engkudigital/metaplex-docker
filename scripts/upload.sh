#!/bin/bash

if [ "$#" -ne 3 ] ; then
  echo "Please provide 2 arguments : Solana cluster (devnet/testnet/mainnet) , keypair path and start date"
  exit 1
fi

case $1 in
  devnet|testnet|mainnet)
    network=$1;;
  *)
    echo "Supplied network isn't devnet/testnet/mainnet , please fix and retry" && exit 1 ;;
esac

if [ ! -f "$2" ] ; then
  echo "Can't find file $2"
  exit 1
else 
  keypair=$2
fi

start_date=$3

echo "solana config before:"
solana config get

solana config set --keypair ${keypair}
solana config set --url "https://api.${network}.solana.com"

echo "solana config after:"
solana config get

if [ "devnet" = "${network}" ] ; then
  echo "devnet detected, requesting airdrop"
  solana airdrop 10 --keypair ${keypair}
fi


solana_creator_address=$(solana address)
mkdir -p old.logs
if [ -d logs ] ; then
  mv logs/* old.logs/
  mv .cache old.logs/
  rm -fr logs
fi
mkdir -p logs
cp -fr assets_template_sample assets
sed -i -e "s/__creators__/${solana_creator_address}/" assets/*.json
if ! metaplex upload ./assets --env ${network} --keypair ${keypair} | tee logs/upload.log ; then
  echo "metaplex upload failed"
  exit 1
fi

if ! metaplex verify --env ${network} --keypair ${keypair} | tee logs/verify.log ; then
  "metaplex verify failed"
  exit 1
fi

if ! metaplex create_candy_machine --env ${network} --keypair ${keypair} | tee logs/create_candy_machine.log ; then
  echo "metaplex create_candy_machine failed"
  exit 1
fi

if ! metaplex set_start_date --env ${network} --keypair ${keypair} --date ${start_date}  | tee logs/set_start_date.log ; then
  echo "metaplex set_start_date failed"
  exit 1
fi
cat .cache/${network}-temp | jq '.items' > logs/items.log

cat > envfile <<- EOM
REACT_APP_CANDY_MACHINE_ID=$(cat logs/create_candy_machine.log | sed -e 's/create_candy_machine Done: //')
REACT_APP_CANDY_START_DATE=$(cat logs/set_start_date.log | sed -e 's/set_start_date Done //' | sed -e 's/ .*//')
REACT_APP_CANDY_MACHINE_CONFIG=$(cat .cache/${network}-temp | jq '.program.config')
REACT_APP_SOLANA_NETWORK=${network}
REACT_APP_SOLANA_RPC_HOST="https://explorer-api.${network}.solana.com"
REACT_APP_TREASURY_ADDRESS=$(solana address --keypair ${keypair})
EOM

exit 0

