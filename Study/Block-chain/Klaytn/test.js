// 1. npm 설치
// 2. caver-js 설치
// get balance - https://imeom.tistory.com/148
// https://www.klaytnapi.com/ko/resource/openapi/node/reference/overview/#section/Introduction

const Caver = require('caver-js')
const caver = new Caver('https://public-node-api.klaytnapi.com/v1/cypress')

async function testFunction() {
  // Set Address
  const tokenAddress = "0x1f2d6282d74ef26eb6c7e28b9e7048c1b42ebda5"; // pKLAY contract
  
  // Get Recent Block Number
  const test = await caver.klay.getBlockNumber(); // promise problem - https://dadidadi.tistory.com/m/42
  console.log(test);
  
  // Get PalaSquare Transcation Information
  caver.rpc.klay.getLogs({
    fromBlock: 108939177,
    toBlock: "latest",
    address: tokenAddress
  }).then((response1) => {
    // Get non-duplicate Transaction Hash
    const transactionHash = new Set();

    for (let i = 0; i < response1.length; i++) {
      transactionHash.add(response1[i].transactionHash);
    }

    const hash = Array.from(transactionHash);
    
    for (let i = 0; i < hash.length; i++) {
      caver.rpc.klay.getTransactionByHash(hash[i]).then(async (response2) => {
        if (response2.input.substr(0, 10) == '0xa59ac6dd') {
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
          }, response2.input);
          
          const nftInstance = new caver.klay.KIP17(result.NFT);
          const nftName = await nftInstance.name();
          const nftURI = await nftInstance.tokenURI(result.TokenID);
          const amount = caver.utils.convertFromPeb(result.amount);
          
          console.log(`NFT Name: ${nftName}`);
          console.log(`TokenID: #${result.TokenID}`);
          console.log(`Price: ${amount} klay`);
          console.log(`TokenURI: ${nftURI}`);
        }
      });
    }
  })
}

testFunction()
