// get balance - https://imeom.tistory.com/148
// https://www.klaytnapi.com/ko/resource/openapi/node/reference/overview/#section/Introduction

const Caver = require('caver-js');
const accessKeyId = "";
const secretAccessKey = "";

const option = {
  headers: [
    {name: 'Authorization', value: 'Basic ' + Buffer.from(accessKeyId + ':' + secretAccessKey).toString('base64')},
    {name: 'x-chain-id', value: '8217'},
  ]
};

const caver = new Caver(new Caver.providers.HttpProvider("https://node-api.klaytnapi.com/v1/klaytn", option));

async function testFunction() {
  // Set Address
  const tokenAddress = "0x1f2d6282d74ef26eb6c7e28b9e7048c1b42ebda5"; // pKLAY contract
  
  // Get Recent Block Number
  const test = await caver.klay.getBlockNumber(); // promise problem - https://dadidadi.tistory.com/m/42
  console.log(test);

  // Get PalaSquare Transcation Information
  const pklayTxInfo = await caver.rpc.klay.getLogs({
    fromBlock: 109608074,
    toBlock: 109608074, //"latest"
    address: tokenAddress
  });

  // Get non-duplicate Transaction Hash
  const txHash = new Set();

  for (let i = 0; i < pklayTxInfo.length; i++) {
    txHash.add(pklayTxInfo[i].transactionHash);
  }

  const hash = Array.from(txHash);

  // Get NFT Information from Transaction Hash
  for (let i = 0; i < hash.length; i++) {
    const tx = await caver.rpc.klay.getTransactionByHash(hash[i]);
    
    if (tx.input.substr(0, 10) == '0xa59ac6dd') { // 'buy' MethodSig
      const result = caver.abi.decodeFunctionCall({
        name: 'buy',
        type: 'function',
        inputs: [{
          type: 'address',
          name: 'NFT'
        },{
          type: 'uint256',
          name: 'TokenID'
        },{
          type: 'uint256',
          name: 'amount'
        }]
      }, tx.input);

      const tmpNftInstance = new caver.klay.KIP17(result.NFT);
      const nftName = await tmpNftInstance.name();
      const nftURI = await tmpNftInstance.tokenURI(result.TokenID);
      const amount = caver.utils.convertFromPeb(result.amount);
      const blockNb = caver.utils.hexToNumber(tx.blockNumber);
      const tmpDate = await caver.klay.getBlock(blockNb);
      const date = new Date(caver.utils.hexToNumber(tmpDate.timestamp)*1000);
          
      console.log(`NFT Name: ${nftName}`);
      console.log(`TokenID: #${result.TokenID}`);
      console.log(`Price: ${amount} klay`);
      console.log(`TokenURI: ${nftURI}`);
      console.log(`Block Number: ${blockNb}`);
      console.log(`Timestamp: ${date}`);

      const tmpArr = [nftName, result.TokenID, amount, nftURI, blockNb, date];
      console.log(tmpArr);
    }
  }
}

testFunction()
