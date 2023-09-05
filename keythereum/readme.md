# Keythereum Extraction Utility

This utility leverages the [keythereum](https://github.com/ethereumjs/keythereum) library to extract private keys from Ethereum keystore files.


## Prerequisites

- [Node.js](https://nodejs.org/) 
- Basic knowledge of Ethereum keystore and Node.js

## Quick Start

1. **Clone the Repository**

```bash
git clone https://github.com/ethereumjs/keythereum.git
cd keythereum
```

2. **Install Dependencies**

Install the required NPM packages:

```bash
npm install
```

3. **Configure the Extraction Script**

Open `accounts/extract_private.js` and fill in the required Ethereum information.

4. **Extract Private Key**

Navigate to the `accounts` directory and run:

```bash
node extract_private.js
```

After executing the script, you'll see the private key displayed in the terminal.
