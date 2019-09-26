#!/bin/sh

#  Copyright (C) 2018-present evan GmbH.
#
#  This program is free software: you can redistribute it and/or modify it
#  under the terms of the GNU Affero General Public License, version 3,
#  as published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  See the GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program. If not, see http://www.gnu.org/licenses/ or
#  write to the Free Software Foundation, Inc., 51 Franklin Street,
#  Fifth Floor, Boston, MA, 02110-1301 USA, or download the license from
#  the following URL: https://evan.network/license/

# oraclize base class
rm -rf node_modules/ethereum-api
git clone --quiet https://github.com/oraclize/ethereum-api.git -b solc_0.4.25-compatibility-patch node_modules/ethereum-api

# solidity-stringutils 
rm -rf node_modules/solidity-stringutils
git clone --quiet https://github.com/Arachnid/solidity-stringutils.git node_modules/solidity-stringutils
cd node_modules/solidity-stringutils
# no releases, tags or branches to address for latest stable, so use commit from 2018-07-25T12:49:44Z
git checkout --quiet 3c63f18245645ba600cae2191deba7221512f753
cd ..
