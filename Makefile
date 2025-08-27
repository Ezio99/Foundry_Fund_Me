-include .env

build:; forge build


# ether scan api key for verification
deploy-sepolia:; forge script script/DeployFundMe.s.sol --rpc-url $(ALCHEMY_SEPOLIA_RPC_URL)  --account MetaMask --sender $(METAMASK_ACCOUNT) --password $(LOCAL_PASSWORD)  --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

verify-contract-sepolia:; forge verify-contract 0xb5662cd9B72E7CE3d0D1632780403C4A80127017 src/FundMe.sol:FundMe --rpc-url $(ALCHEMY_SEPOLIA_RPC_URL) --etherscan-api-key $(ETHERSCAN_API_KEY) 


# Working local deploy script
deploy-local:; forge script script/DeployFundMe.s.sol --rpc-url $(LOCAL_RPC_URL)  --account defaultKey --sender $(DEFAULT_ACCOUNT) --password $(LOCAL_PASSWORD)  --broadcast 