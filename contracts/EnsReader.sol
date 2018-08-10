/*
  Copyright (C) 2018-present evan GmbH. 
  
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Affero General Public License, version 3, 
  as published by the Free Software Foundation. 
  
  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Affero General Public License for more details. 
  
  You should have received a copy of the GNU Affero General Public License along with this program.
  If not, see http://www.gnu.org/licenses/ or write to the
  
  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA, 02110-1301 USA,
  
  or download the license from the following URL: https://evan.network/license/ 
  
  You can be released from the requirements of the GNU Affero General Public License
  by purchasing a commercial license.
  Buying such a license is mandatory as soon as you use this software or parts of it
  on other blockchains than evan.network. 
  
  For more information, please contact evan GmbH at this address: https://evan.network/license/ 
*/

pragma solidity ^0.4.0;

import "./AbstractENS.sol";
import "./AbstractPublicResolver.sol";


contract EnsReader {
  // AbstractENS ens = AbstractENS($ENS_ADDRESS);
  AbstractENS ens = AbstractENS(0x937bbC1d3874961CA38726E9cD07317ba81eD2e1);
  // bytes32 rootDomain = $NAMEHASH_ROOT_DOMAIN;
  bytes32 rootDomain = 0x01713a3bd6dccc828bbc37b3f42f3bc5555b16438783fabea9faf8c2243a0370;

  function getAddr(bytes32 node) constant internal returns (address) {
    return AbstractPublicResolver(ens.resolver(sha3(rootDomain, node))).addr(sha3(rootDomain, node));
  }

  function setEns(address ensAddress) internal {
    ens = AbstractENS(ensAddress);
  }
}
