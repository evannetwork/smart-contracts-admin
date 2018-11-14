/*
  Copyright (C) 2018-present evan GmbH.

  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Affero General Public License, version 3,
  as published by the Free Software Foundation.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program. If not, see http://www.gnu.org/licenses/ or
  write to the Free Software Foundation, Inc., 51 Franklin Street,
  Fifth Floor, Boston, MA, 02110-1301 USA, or download the license from
  the following URL: https://evan.network/license/

  You can be released from the requirements of the GNU Affero General Public
  License by purchasing a commercial license.
  Buying such a license is mandatory as soon as you use this software or parts
  of it on other blockchains than evan.network.

  For more information, please contact evan GmbH at this address:
  https://evan.network/license/
*/

import 'mocha';
import chaiAsPromised = require('chai-as-promised');
import IpfsApi = require('ipfs-api');
import Web3 = require('web3');
import { DfsInterface } from '@evan.network/dbcp';
import { getContractPaths } from '../index';
import {
  createDefaultRuntime,
  Ipfs,
  Runtime,
} from '@evan.network/api-blockchain-core';
import {
  expect,
  use,
} from 'chai';

import { accounts, accountMap } from './test/accounts';

const providers = {
  evanTestcore: () => new Web3.providers.WebsocketProvider('wss://testcore.evan.network/ws'),
  kovan: () => new Web3.providers.HttpProvider('http://localhost:8555'),
};

let  currentProvider;
// currentProvider = 'evanTestcore';
currentProvider = 'kovan';


use(chaiAsPromised);

describe('TicketVendor contract', function() {
  const bytes32Zero = '0x'.padEnd(66, '0');
  let dfs;
  let runtimes = {};
  let ticketVendor;
  let web3;

  before(async () => {
    web3 = new Web3(providers[currentProvider]());
    dfs = new Ipfs(
      { remoteNode: new IpfsApi({ host: 'ipfs.evan.network', port: '443', protocol: 'https' }) });
    const sha3 = web3.utils.soliditySha3;
    const sha9 = (address) => sha3(sha3(address), sha3(address));
    const additionalContractsPaths = getContractPaths();
    runtimes[accounts[0]] = await createDefaultRuntime(web3, dfs, {
      accountMap: { [accounts[0]]: accountMap[accounts[0]], },
      additionalContractsPaths,
    });
    runtimes[accounts[1]] = await createDefaultRuntime(web3, dfs, {
      accountMap: { [accounts[1]]: accountMap[accounts[1]], },
      additionalContractsPaths,
    });
  });

  after(async () => {
    web3.currentProvider.connection.close ? web3.currentProvider.connection.close() : null;
    await dfs.stop();
  });

  it('can be created', async () => {
    ticketVendor = await runtimes[accounts[0]].executor.createContract(
      'TicketVendor', [], { from: accounts[0], gas: 3000000 });
    console.log(ticketVendor.options.address);
    process.exit();
  });

  it('does not allow to issue new tickets, when price hasn\'t been updated', async () => {
    const newTicketPromise = runtimes[accounts[0]].executor.executeContractTransaction(
      ticketVendor, 'requestTicket', { from: accounts[0] }, '1000000000000000000');
    await expect(newTicketPromise).to.be.rejected;
  });

  it('allows to insert prices for debugging (this should not work, when rolling out to mainnet)', async () => {
    let { eveWeiPerEther } = await runtimes[accounts[0]].executor.executeContractCall(
      ticketVendor, 'getCurrentPrice');
    expect(eveWeiPerEther).to.eq('0');
    const updatePromise = runtimes[accounts[0]].executor.executeContractTransaction(
      ticketVendor, '__callback', { from: accounts[0] }, bytes32Zero, '123.456789000');
    if (currentProvider === 'evanTestcore') {
      await updatePromise;
      eveWeiPerEther = (await runtimes[accounts[0]].executor.executeContractCall(
        ticketVendor, 'getCurrentPrice')).eveWeiPerEther;
      expect(eveWeiPerEther).to.eq('123456789000000000000');
    } else if (currentProvider === 'kovan') {
      await expect(updatePromise).to.be.rejected;
    } else {
      // ignore undefined networks
      expect(['evanTestcore', 'kovan']).to.include(currentProvider);
    }
  });

  it('allows to update prices via oraclize (only works on kovan (for now))', async () => {
    let { eveWeiPerEther } = await runtimes[accounts[0]].executor.executeContractCall(
      ticketVendor, 'getCurrentPrice');
    expect(eveWeiPerEther).to.eq('0');
    const newPrice = await runtimes[accounts[0]].executor.executeContractTransaction(
      ticketVendor,
      'updatePrice',
      {
        from: accounts[0],
        event: { target: 'TicketVendorInterface', eventName: 'PriceUpdated', },
        getEventResult: (_, args) => args.newPrice,
        value: '1'.padEnd(17, '0'), // --> 0.01 ETH (~ aka 1 with 16 zeroes --> 1 * 10^16)
      },
    );
    console.dir(newPrice);
    expect(newPrice).not.to.eq('0');
  });

  it('allows issuing new tickets, when price has been updated', async () => {
    const sampleValue = '1000000000000012345';
    const newTicket = await runtimes[accounts[0]].executor.executeContractTransaction(
      ticketVendor,
      'requestTicket',
      {
        from: accounts[0],
        event: { target: 'TicketVendorInterface', eventName: 'TicketCreated', },
        getEventResult: (_, args) => args.ticketId,
      },
      sampleValue,
    );
    const { owner, price, issued, value } = await runtimes[accounts[0]].executor.executeContractCall(
      ticketVendor, 'getTicketInfo', newTicket);
    expect(owner).to.eq(accounts[0]);
    expect(value).to.eq(sampleValue);
  });
});
