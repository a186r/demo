const config = require('../truffle.js');

// 合约
const demoStorage = artifacts.require('../contract/DemoStorage.sol');
const demoUpgrade = artifacts.require('../contract/DemoUpgrade.sol');
const testContract = artifacts.require('../contract/TestContract.sol');
const test1Contract = artifacts.require('../contract/Test1Contract.sol');
// const test3Contract = artifacts.require('../contract/Test3Contract.sol');
const validatorSet = artifacts.require('../contract/ValidatorSet.sol');

// 接口
const demoStorageInterface = artifacts.require('../interface/DemoStorageInterface.sol');

const accounts = web3.eth.accounts;

module.exports = async (deployer, network) => {
    return deployer
        .deploy(demoStorage)
        .then(() => {
            return deployer.deploy([
                [testContract, demoStorage.address],
                [test1Contract, demoStorage.address],
                [demoUpgrade, demoStorage.address],
                // [test3Contract, demoStorage.address],
                [validatorSet, demoStorage.address]
            ]);
        })

        // 部署之后
        .then(async () => {
            let demoStorageInstance = await demoStorage.deployed();

            console.log('\n');

            console.log('\x1b[33m%s\x1b[0m:', 'Set Storage Address');
            console.log(demoStorage.address);

            //TestContract地址设置
            await demoStorageInstance.setAddress(
                config.web3.utils.soliditySha3('contract.address', testContract.address),
                testContract.address
            );
            await demoStorageInstance.setAddress(
                config.web3.utils.soliditySha3('contract.name', 'testContract'),
                testContract.address
            );
            console.log('\x1b[33m%s\x1b[0m:', 'Set TestContract Address');
            console.log(testContract.address);

            // Test1Contract地址设置
            await demoStorageInstance.setAddress(
                config.web3.utils.soliditySha3('contract.address', test1Contract.address),
                test1Contract.address
            );
            await demoStorageInstance.setAddress(
                config.web3.utils.soliditySha3('contract.name', 'test1Contract'),
                test1Contract.address
            );
            console.log('\x1b[33m%s\x1b[0m:', 'Set test1Contract Address');
            console.log(test1Contract.address);

            // DemoUpgrade地址设置
            await demoStorageInstance.setAddress(
                config.web3.utils.soliditySha3('contract.address', demoUpgrade.address),
                demoUpgrade.address
            );
            await demoStorageInstance.setAddress(
                config.web3.utils.soliditySha3('contract.name', 'demoUpgrade'),
                demoUpgrade.address
            );
            console.log('\x1b[33m%s\x1b[0m:', 'Set demoUpgrade Address');
            console.log(demoUpgrade.address);

            /*** Permissions *********/

            // Disable direct access to storage now
            await demoStorageInstance.setBool(
                config.web3.utils.soliditySha3('contract.storage.initialised'),
                true
            );

            // test3Contract地址设置
            // await demoStorageInstance.setAddress(
            //     config.web3.utils.soliditySha3('contract.address', test3Contract.address),
            //     test3Contract.address
            // );
            // await demoStorageInstance.setAddress(
            //     config.web3.utils.soliditySha3('contract.name', 'test3Contract'),
            //     test3Contract.address
            // );
            // console.log('\x1b[33m%s\x1b[0m:', 'Set test3Contract Address');
            // console.log(test3Contract.address);

            // ValidatorSet地址设置
            await demoStorageInstance.setAddress(
                config.web3.utils.soliditySha3('contract.address', validatorSet.address),
                validatorSet.address
            )
            await demoStorageInstance.setAddress(
                config.web3.utils.soliditySha3('contract.name', 'validatorSet'),
                validatorSet.address
            )
            console.log('\x1b[33m%s\x1b[0m:', 'Set validatorSet Address');
            console.log(validatorSet.address);

        })
}