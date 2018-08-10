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

'use strict'
const {Initializer, api} = require('actionhero')

const Solc = require('../lib/solc');

module.exports = class SolcInitializer extends Initializer {
  constructor () {
    super()
    this.name = 'solc'
    this.loadPriority = 2000
    this.startPriority = 2000
    this.stopPriority = 2000
  }

  async initialize () {
    const solcLib = new Solc({
      api,
      config: api.config.eth,
      log: api.log
    });
    await solcLib.ensureCompiled();
    api['solc'] = {
      getContracts: solcLib.getContracts,
    }
  }

  async start () {}
  async stop () {}
}
