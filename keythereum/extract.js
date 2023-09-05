const keythereum = require("keythereum");

// path to where account it 
var datadir = "<path to keystore>";
var address= "<address including 0x at the start>";
const password = "<password>";

var keyObject = keythereum.importFromFile(address, datadir);
var privateKey = keythereum.recover(password, keyObject);

console.log(privateKey.toString('hex'));