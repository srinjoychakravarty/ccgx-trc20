const port = process.env.HOST_PORT || 9090

module.exports = {
  networks: {
    mainnet: {
      // Don't put your private key here:
      privateKey: process.env.PRIVATE_KEY_MAINNET,
      /*Create a .env file (it must be gitignored) containing something like
  export PRIVATE_KEY_MAINNET=4E7FECCB71207B867C495B51A9758B104B1D4422088A87F4978BE64636656243
Then, run the migration with: source .env && tronbox migrate --network mainnet */
      userFeePercentage: 100,
      feeLimit: 1e8,
      fullHost: "https://api.trongrid.io",
      network_id: "1"
    },
    shasta: {
      privateKey: process.env.PRIVATE_KEY_SHASTA,
      userFeePercentage: 50,
      feeLimit: 1e8,
      fullHost: "https://api.shasta.trongrid.io",
      network_id: "2"
    },
    development: {
      // For trontools/quickstart docker image
      //from: 'some address',
      privateKey: 'da146374a75310b9666e834ee4ad0866d6f4035967bfc76217c5a495fff9f0d0',
      //consume_user_resource_percent: 30,
      userFeePercentage: 100,
      //feeLimit: 1e8,
      fullHost: 'http://127.0.0.1:' + port,
      //fullNode: "https://api.trongrid.io",
      //solidityNode: "https://api.trongrid.io",
      //eventServer:  "it is optional",
      network_id: "9"
    }/*,
    production: {
        from: 'some other address',
        privateKey: 'some other private key',
        consume_user_resource_percent: 30,
        fee_limit: 100000000,
        fullNode: "https://api.trongrid.io",
        solidityNode: "https://api.trongrid.io",
        eventServer:  "it is optional",
        network_id: "*" // Match any network id
    }*/
  }
}
