const KarmaCoinCrowdsale = artifacts.require('./KarmaCoinCrowdsale.sol');
const KarmaCoin = artifacts.require('./KarmaCoin.sol');
const GyanCoin = artifacts.require('./GyanCoin.sol');
const CollectionContract = artifacts.require('./CollectionContract.sol');
const ScholarshipContract = artifacts.require('./ScholarshipContract.sol');
const QuestionContract = artifacts.require('./QuestionContract.sol');

module.exports = function(deployer, network, accounts) {
	const openingTime = web3.eth.getBlock('latest').timestamp + 1; // two secs in the future
	const closingTime = openingTime + 86400 * 20; // 20 days
	const rate = new web3.BigNumber(4000); // 4000 Karma tokens for every ether
	const wallet = accounts[1];
	const globalScholarshipFundAddress = accounts[2];
	const _cap = 1000000000; // 1 Billion
	const globalScholarshipFundAmount = 100000000; // 100 Mil
	const foundersPool = accounts[3];
	const advisoryPool = accounts[4];
	
	return deployer
			.then(() => {
				return deployer.deploy(
						KarmaCoin,
						_cap,
						globalScholarshipFundAddress,
						globalScholarshipFundAmount,
						foundersPool,
						advisoryPool
				);
			})
			.then(() => {
				return deployer.deploy(
						GyanCoin,
						KarmaCoin.address
				);
			})
			.then(() => {
				return deployer.deploy(
						ScholarshipContract,
						KarmaCoin.address
				);
			})
			.then(() => {
				return deployer.deploy(
						QuestionContract,
						GyanCoin.address,
						KarmaCoin.address,
						ScholarshipContract.address
				);
			})
			/*.then(() => {
				return deployer.deploy(
						KarmaCoinCrowdsale,
						openingTime,
						closingTime,
						rate,
						wallet,
						KarmaCoin.address
				);
			})*/
			.then(() => {
				return deployer.deploy(
						CollectionContract,
						KarmaCoin.address,
						GyanCoin.address,
						ScholarshipContract.address
				);
			});
};