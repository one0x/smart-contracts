const KarmaCoinCrowdsale = artifacts.require('./KarmaCoinCrowdsale.sol');
const KarmaCoin = artifacts.require('./KarmaCoin.sol');
const GyanCoin = artifacts.require('./GyanCoin.sol');
const CollectionContract = artifacts.require('./CollectionContract.sol');

module.exports = function(deployer, network, accounts) {
	const openingTime = web3.eth.getBlock('latest').timestamp + 1; // two secs in the future
	const closingTime = openingTime + 86400 * 20; // 20 days
	const rate = new web3.BigNumber(1);
	const wallet = accounts[1];
	const globalScholarshipFundAddress = accounts[2];
	const _cap = 100000000;
	const globalScholarshipFundAmount = 10000000;
	
	return deployer
			.then(() => {
				return deployer.deploy(
						KarmaCoin,
						_cap,
						globalScholarshipFundAddress,
						globalScholarshipFundAmount
				);
			})
			.then(() => {
				return deployer.deploy(
						GyanCoin
				);
			})
			.then(() => {
				return deployer.deploy(
						KarmaCoinCrowdsale,
						openingTime,
						closingTime,
						rate,
						wallet,
						KarmaCoin.address
				);
			})
			.then(() => {
				return deployer.deploy(
						CollectionContract,
						KarmaCoin.address,
						GyanCoin.address
				);
			});
};