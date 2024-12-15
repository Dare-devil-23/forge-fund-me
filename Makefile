-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(ALCHEMY_RPC_URL) --account sepoliaPrivateKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv