const KarmaCoinCrowdsale = artifacts.require('./KarmaCoinCrowdsale.sol');
const KarmaCoin = artifacts.require('./KarmaCoin.sol');
const GyanCoin = artifacts.require('./GyanCoin.sol');
const CollectionContract = artifacts.require('./CollectionContract.sol');
const ScholarshipContract = artifacts.require('./ScholarshipContract.sol');
const QuestionContract = artifacts.require('./QuestionContract.sol');
const RBACs = artifacts.require('./ownership/rbac/RBAC.sol');
const roles = artifacts.require('./ownership/rbac/roles.sol');
const PbOwnable = artifacts.require('./ownership/PbOwnable.sol');


module.exports = function(deployer, network, accounts) {
	const openingTime = web3.eth.getBlock('latest').timestamp + 1; // two secs in the future
	const closingTime = openingTime + 86400 * 365; // 365 days
	const rate = new web3.utils.BN(5000); // 5000 Karma tokens for every ether
	const wallet = accounts[1];
	const globalScholarshipFundAddress = accounts[2];
	const _cap = 1000000000; // 1 Billion
	const globalScholarshipFundAmount = 100000000; // 100 Mil
	const foundersPool = '0xada2dd467c50535a4a3dc4ace5b92dcedc179fbc';
	const advisoryPool = '0x81cd9f0f55f90f58b8ec25e577d12f4392b34f0a';   // PRODUCTION
	// const advisoryPool = '0xfBF2284fa5ceB75Dad3ac8703cE8e90b4E4D5dd3';      // DEVELOPMENT
	const communityPool = '0xcbcaccb1e9b4a3d9c02402ac090e4be1c936780f';


	return deployer
			.then(() => {
				return deployer.deploy(
						KarmaCoin,
						_cap,
						globalScholarshipFundAddress,
						globalScholarshipFundAmount,
						foundersPool,
						advisoryPool,
						communityPool
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
						GyanCoin.address,
						ScholarshipContract.address
				);
			});
};
