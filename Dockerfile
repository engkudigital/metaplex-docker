FROM rust:buster
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update
RUN apt install nodejs yarn -y
RUN mkdir -p /root/.local/share/solana
RUN sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
ENV PATH="/root/.local/share/solana/install/active_release/bin/:$PATH"
RUN solana-install update
RUN git clone https://github.com/metaplex-foundation/metaplex.git ~/metaplex-foundation/metaplex
RUN cd ~/metaplex-foundation/metaplex/js/packages/cli && yarn install
RUN cd ~/metaplex-foundation/metaplex/js/packages/cli && yarn build
RUN cd ~/metaplex-foundation/metaplex/js/packages/cli && sed -i.backup -e 's/--no-bytecode//' package.json 
RUN cd ~/metaplex-foundation/metaplex/js/packages/cli && yarn run package:linux
ENV PATH="/root/metaplex-foundation/metaplex/js/packages/cli/bin/linux/:$PATH"
RUN solana config set --url https://api.devnet.solana.com

