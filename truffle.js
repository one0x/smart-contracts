module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
	networks: {
		development: {
			host: "127.0.0.1",
			port: 7545,
			network_id: "*" // Match any network id
		},
		testnet: {
			host: "127.0.0.1",
			port: 8545,
			network_id: "2",
			from: '0x742ba4f0cd93b3b7876a54ef10838973ebadcf49',
			gas: 4500000
		}
	}
};
