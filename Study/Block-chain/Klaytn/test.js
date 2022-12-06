// 1. npm 설치
// 2. caver-js 설치
// get balance - https://imeom.tistory.com/148

const Caver = require('caver-js')
const caver = new Caver('https://public-node-api.klaytnapi.com/v1/cypress')

async function testFunction() {
  //caver.rpc.klay.getBlockByHash('0x44aa4b8eefa771b6a13d333313cf8846e0ded00701f80bd3510b1ec3ee29e983').then(console.log)
  //caver.rpc.klay.getBlockByNumber(108321035).then(console.log)
  caver.rpc.klay.getBalance('0x06B0fDFb7707c51Bc700a761371C3bEf8338D101').then((response) => {
      const balance = caver.utils.convertFromPeb(caver.utils.hexToNumberString(response));
      console.log(`Balance : ${balance}`);
      return balance;
  })
}

async function testFunction2() {
  caver.rpc.klay.getLogs({
    fromBlock: 108406066,
    toBlock: "latest", 
    address: "0x1f2d6282d74ef26eb6c7e28b9e7048c1b42ebda5" // pKLAY contract
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
      const amount = caver.utils.convertFromPeb(result.amount);
      nftName.then((nft) => console.log(`NFT Name: ${nft}`))
      //console.log(`NFT Name: ${nftName}`);
      console.log(`TokenID: #${result.TokenID}`);
      console.log(`Price: ${amount} klay`);
    });
  })
}

//testFunction()
testFunction2()
