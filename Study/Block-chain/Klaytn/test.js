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

testFunction()
