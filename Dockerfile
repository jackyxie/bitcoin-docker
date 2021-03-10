#docker official images to build deps
FROM buildpack-deps:buster-curl
LABEL author="jackyxie"

ENV BTC_VERSION 0.21.0
ENV BTC_SITE_PATH https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}
ENV BTC_SCRIPT_FILENAME bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BTC_RELEASE_KEY 01EA5486DE18A882D4C2684590C8019E36C2E964

RUN wget $BTC_SITE_PATH/$BTC_SCRIPT_FILENAME \
	&& wget $BTC_SITE_PATH/SHA256SUMS.asc \
	&& wget https://bitcoin.org/laanwj-releases.asc \
	&& gpg --import laanwj-releases.asc \
	&& gpg --fingerprint $BTC_RELEASE_KEY \
	&& gpg --verify SHA256SUMS.asc \
	&& grep -o "$(sha256sum $BTC_SCRIPT_FILENAME)" SHA256SUMS.asc \
	&& tar -xzvf $BTC_SCRIPT_FILENAME \
	&& cd bitcoin-*/bin \
	&& rm -rf bitcoin-qt test_bitcoin \
	&& mv * /usr/local/bin 
	

FROM debian:stable-slim
COPY --from=0 /usr/local/bin/* /usr/local/bin/
ENTRYPOINT ["bitcoind"]
CMD ["-printtoconsole", "-disablewallet"]
EXPOSE 8333 8332
VOLUME /root/.bitcoin
