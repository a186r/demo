const config = require('../truffle.js');
const test2Contract = artifacts.require('../contract/Test2Contract.sol');
module.exports = async (deployer, network) => {

    return deployer
        .deploy(test2Contract, "0x345ca3e014aaf5dca488057592ee47305d9b3e10")
        .then(async () => {


            console.log('\x1b[33m%s\x1b[0m:', 'Set test2Contract Address');
            console.log(test2Contract.address);

        })
}