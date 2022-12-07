// 1. npm 설치
// 2. caver-js 설치
// get balance - https://imeom.tistory.com/148

const Caver = require('caver-js')
const caver = new Caver('https://public-node-api.klaytnapi.com/v1/cypress')

async function testFunction() {
  // Set Address
  const tokenAddress = "0x1f2d6282d74ef26eb6c7e28b9e7048c1b42ebda5"; // pKLAY contract
  
  // Get Recent Block Number
  caver.klay.getBlockNumber().then(console.log);
  
  // Get PalaSquare Transcation Information
  caver.rpc.klay.getLogs({
    fromBlock: 108426270,
    toBlock: "latest", 
    address: tokenAddress
  }).then((response1) => {
    const hash = response1[0].transactionHash;
    
    caver.rpc.klay.getTransactionByHash(hash).then((response2) => {
      //const amount = caver.utils.convertFromPeb(caver.utils.hexToNumberString(response2.value));
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
      const nftName = nftInstance.name();
      const nftURI = nftInstance.tokenURI(result.TokenID);
      const amount = caver.utils.convertFromPeb(result.amount);
      
      nftName.then((nft) => console.log(`NFT Name: ${nft}`));
      nftURI.then((uri) => console.log(`TokenURI: ${uri}`));
      console.log(`TokenID: #${result.TokenID}`);
      console.log(`Price: ${amount} klay`);
    });
  })
}

testFunction()
