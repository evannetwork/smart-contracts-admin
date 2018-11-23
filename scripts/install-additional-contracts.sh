#!/bin/sh

# oraclize base class
rm -rf node_modules/ethereum-api
git clone https://github.com/oraclize/ethereum-api.git -b solc_0.4.25-compatibility-patch node_modules/ethereum-api

# solidity-stringutils 
rm -rf node_modules/solidity-stringutils
git clone https://github.com/Arachnid/solidity-stringutils.git node_modules/solidity-stringutils
cd node_modules/solidity-stringutils
# no releases, tags or branches to address for latest stable, so use commit from 2018-07-25T12:49:44Z
git checkout 3c63f18245645ba600cae2191deba7221512f753
cd ..
