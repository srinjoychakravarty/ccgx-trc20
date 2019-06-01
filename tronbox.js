module.exports = {
  networks: {
    mainnet: {
      privateKey: '',
      fullNode: "https://api.trongrid.io",
      solidityNode: "https://api.trongrid.io",
      eventServer: "https://api.trongrid.io",
      network_id: "*"
      }
    },
    compilers: {
      solc: {
        version: "0.5.9"  // ex:  "0.4.20". (Default: Truffle's installed solc)
   }
}
  }
