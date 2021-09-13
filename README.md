# metaplex-docker

### How to use

I highly recommend trying with `devnet` and going through the [scripts/run_upload.sh](scripts/upload.sh) and  [scripts/upload.sh](scripts/upload.sh) to understand this flow better.

1. Edit the content of [assets_template_sample](assets_template_sample).
2. Go over [Validating your project assets](https://hackmd.io/@levicook/HJcDneEWF#Validating-your-project-assets) and make sure your `JSON` is filled as expected.
3. Currently this flow will look for `__creators__` inside the `JSON` and replace it with your `solana address` during the `upload` process.
4. Run `./scripts/run_upload.sh <cluster-name> <date>` , for example `./scripts/run_upload.sh  devnet 2021-01-01` and it will go through the entire flow in the [Metaplex Candy Machine Tutorial](https://hackmd.io/@levicook/HJcDneEWF).
5. Check the contents of `output/output.log` , you'll see the contents of the `.env` file you need to create your [candy-machine-mint](https://github.com/exiled-apes/candy-machine-mint) , will look like the sample below:

```
--------------------------
--- START FILE : logs/envfile
--------------------------

REACT_APP_CANDY_MACHINE_ID=<uuid>
REACT_APP_CANDY_START_DATE=<timestamp>
REACT_APP_CANDY_MACHINE_CONFIG=<uuid>
REACT_APP_SOLANA_NETWORK=<network>
REACT_APP_SOLANA_RPC_HOST=<url>
REACT_APP_TREASURY_ADDRESS=<uuid>

--------------------------
--- END FILE : logs/envfile
--------------------------
```

---

### File Structure
* [scripts/run_upload.sh](scripts/upload.sh) - Wrapper helper, main script to use.
* [scripts/upload.sh](scripts/upload.sh) - Main script that follows [Metaplex Candy Machine Tutorial](https://hackmd.io/@levicook/HJcDneEWF).
* [Dockerfile](Dockerfile) - `Dockerfile` used for the image, can also use [metaplex-docker image](https://hub.docker.com/repository/docker/ohaddahan/metaplex-docker).
* [assets_template_sample](assets_template_sample) - Sample of `JSON` / `PNG` files.
* **Auxilary scripts:**
  * [scripts/build.sh](scripts/build.sh) - Rebuilding the `Docker` image.
  * [scripts/attach.sh](scripts/attach.sh) - Attaching into a container `Docker`.
  * [scripts/run.sh](scripts/run.sh) - Launch `Docker` container and make it wait.
  * [scripts/run_and_attach.sh](scripts/run_and_attach.sh) - Launch `Docker` container and attach to it.
  * [scripts/stop.sh](scripts/stop.sh) - Stop `Docker` container.

---

### Docker Hub
[metaplex-docker image](https://hub.docker.com/repository/docker/ohaddahan/metaplex-docker)

---

### References

* [Metaplex Candy Machine - An awesome tutorial](https://hackmd.io/@levicook/HJcDneEWF)
* [candy-machine-mint - Boilerplate UI](https://github.com/exiled-apes/candy-machine-mint)
* [metaplex - Metaplex infrastructure](https://github.com/metaplex-foundation/metaplex)
* [solana-cli-tools](https://docs.solana.com/cli/install-solana-cli-tools)
* [Solana NFT Metadata Standard - Solana NFT JSON samples and information](https://docs.metaplex.com/nft-standard)
