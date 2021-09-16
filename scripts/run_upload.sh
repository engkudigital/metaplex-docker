#!/bin/bash
uid=999
gid=999

keypair=$(solana config get | grep 'Keypair Path:'| sed -e 's/^.*Keypair Path: //' | sed -e 's/ $//')

if [ ! -f "${keypair}" ] ; then
  echo "Didnt find keypair '${keypair}'"
  exit 1
fi
keypair_dir=$(dirname ${keypair})
keypair_base=$(basename ${keypair})

if [ "$#" -ne 2 ] ; then
  echo "Please provide 2 arguments : Solana cluster (devnet/testnet/mainnet) and start date"
  exit 1
fi

case $1 in
  devnet|testnet|mainnet)
    network=$1;;
  *)
    echo "Supplied network isn't devnet/testnet/mainnet , please fix and retry" && exit 1 ;;
esac

start_date=$2

mkdir -p outputs
docker run \
  --network host \
  -e solana_key="$(cat ${keypair})" \
  -v ${PWD}/scripts:/user/workdir/scripts \
  -v ${PWD}/assets_template_sample:/user/workdir/assets_template_sample \
  --workdir /user/workdir \
  --user "${uid}:${gid}" \
  metaplex-docker:latest \
  /user/workdir/scripts/upload.sh ${network} /user/workdir/keypair_dir/${keypair_base} ${start_date} |tee outputs/output.log

