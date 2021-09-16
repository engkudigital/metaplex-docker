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

keypair=$2
start_date=$3
keypair_dir=$(dirname ${keypair})
keypair_base=$(basename ${keypair})
mkdir -p "${keypair_dir}"

if [ ! -z "${solana_key}" ] ; then
  echo "${solana_key}" > ${keypair}
else
  echo "solana_key envar is empty"
  exit 1
fi

if [ ! -r "${keypair}" ] ; then
  echo "Can't find file '${keypair}'"
  exit 1
fi


echo "solana config before:"
solana config get
echo "---------------------------------"
echo ""
echo "setting solana defaults:"
solana config set --keypair ${keypair} --url "https://api.${network}.solana.com"
echo "---------------------------------"
echo ""
echo "solana config after:"
solana config get
echo "---------------------------------"
echo ""

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

cp .cache/${network}-temp logs/cache-${network}-temp.log
cat .cache/${network}-temp | jq '.items' > logs/items.log

cat > logs/envfile <<- EOM
REACT_APP_CANDY_MACHINE_ID=$(cat logs/create_candy_machine.log | sed -e 's/create_candy_machine Done: //')
REACT_APP_CANDY_START_DATE=$(cat logs/set_start_date.log | sed -e 's/set_start_date Done //' | sed -e 's/ .*//')
REACT_APP_CANDY_MACHINE_CONFIG=$(cat .cache/${network}-temp | jq '.program.config')
REACT_APP_SOLANA_NETWORK=${network}
REACT_APP_SOLANA_RPC_HOST="https://explorer-api.${network}.solana.com"
REACT_APP_TREASURY_ADDRESS=$(solana address --keypair ${keypair})
EOM

echo -e "\n\n\n"

for filename in logs/* ; do
  echo ""
  echo "--------------------------"
  echo "--- START FILE : ${filename}"
  echo "--------------------------"
  echo ""
  cat "${filename}"
  echo ""
  echo "--------------------------"
  echo "--- END FILE : ${filename}"
  echo "--------------------------"
  echo ""
done

