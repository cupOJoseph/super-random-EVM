const HDWalletProvider = require('truffle-hdwallet-provider');
// const infuraKey = "fj4jll3k.....";
//
const fs = require('fs');
const pk = "3A4233398879F72F0413FCF6B469D4367D52F3FBC01A2C3A5F902AE5C9416877"; //public 0x284979df920482b1ED26147e46846c4B76f0B15B

module.exports = {
  networks: {
    local: {
      host: 'localhost',
      port: 9545,
      gas: 5000000,
      gasPrice: 5e9,
      network_id: '*',
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(pk, "https://rinkeby.infura.io/v3/abdaccf7ac5b4f9a868c8b01929407a3")
      },
      network_id: 4,
      from: "0x284979df920482b1ED26147e46846c4B76f0B15B",
      gas: 3000000,
      gasPrice: 100000000000
    }
  }
}
