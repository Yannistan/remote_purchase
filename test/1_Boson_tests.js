/* eslint-disable no-unused-expressions */
const { contract, accounts } = require('@openzeppelin/test-environment');
const { BN, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');


const Boson = contract.fromArtifact('Boson');

describe('Boson', function () {
  this.timeout(0);
  const TITLE = 'Tea';
  const PRICE = new BN('200000000000000000');
  const AMOUNT = new BN('1000000000000000000');
  const ADDR = '0x44F31c324702C418d3486174d2A200Df1b345376';
  const ID = new BN(1);
  const [owner, dev, buyer1, buyer2, seller1, seller2] = accounts;

//  before(async function () {
//    this.erc1820 = await singletons.ERC1820Registry(registryFunder);
//  });
context('registration of a buyer and a seller and check of offers and orders', function () {

  beforeEach(async function () {
    this.app = await Boson.new(owner, ADDR, { from: seller1 });
    await this.app.register('0', { from: seller1 });
    await this.app.register('1', { from: buyer1 });
  });

  it('transfers ownership from msg.sender to owner', async function () {
    expect(await this.app.owner()).to.equal(owner);
  });

  it('reverts if getEscrow is not called by the owner', async function () {
    await expectRevert(
      this.app.getEscrow({ from: dev }),
      'Ownable: caller is not the owner',
    );
  });

  it('get seller data', async function () {
    const result1 = await this.app.getParty(seller1, { from: seller1 });
    console.log(result1);
    expect(result1[0]).to.be.a.bignumber.equal(new BN(1));
    expect(result1[1]).to.be.a.bignumber.equal(new BN(1));
  });
 
  it('add credit and verify change in structure Party', async function () {
    await this.app.credit(AMOUNT, { from: buyer1 });
    const result4 = await this.app.getParty(buyer1);
    console.log(result4);
    expect(result4[2]).to.be.a.bignumber.equal(AMOUNT);
  });

  it('add and get offer data', async function () {
    await this.app.offer(TITLE, PRICE, { from: seller1 });
    const result2 = await this.app.getOffer(TITLE);
    console.log(result2);
    expect(result2[0]).to.be.a.bignumber.equal(ID);
    expect(result2[1] == TITLE).to.be.true;
    expect(result2[2]).to.be.a.bignumber.equal(PRICE);
  
  });

  it('add and get order data', async function () {
    await this.app.order(TITLE, { from: buyer1 });
    const result3 = await this.app.getOrder(TITLE);
    console.log(result3);
    expect(result3[0]).to.be.a.bignumber.equal(ID);
  
  });

});

context('check purchase of an order', function () {

  beforeEach(async function () {
    this.app = await Boson.new(owner, ADDR, { from: seller1 });
    await this.app.register('0', { from: seller1 });
    await this.app.register('1', { from: buyer1 });
    await this.app.credit(AMOUNT, { from: buyer1 });
    await this.app.offer(TITLE, PRICE, { from: seller1 });
    await this.app.order(TITLE, { from: buyer1 });
  });

  it('completes purchase', async function () {
    await this.app.check_purchase(TITLE, '0', { from: buyer1 });
    const result4 = await this.app.getOrder(TITLE);
    expect(result4[2] == true).to.be.true;
  });

  it('complains about purchase', async function () {
    await this.app.check_purchase(TITLE, '1', { from: buyer1 });
    const result4 = await this.app.getOrder(TITLE);
    expect(result4[3] == true).to.be.true;
  });

  it('does not complain when does not receive order', async function () {
    await this.app.check_purchase(TITLE, '2', { from: buyer1 });
    const result4 = await this.app.getOrder(TITLE);
    expect(result4[2] == false).to.be.true;
    expect(result4[3] == false).to.be.true;
  });

  it('reverts when function argument is different from 0, 1 or 2', async function () {
    await expectRevert(
      this.app.check_purchase(TITLE, '5', { from: buyer1 }),
      'Boson: Invalid option',
    );
  });

  });
  context('reverts in double registration of a seller', function () {
    beforeEach(async function () {
      this.app = await Boson.new(owner, ADDR, { from: seller1 });
      await this.app.register('0', { from: seller2 });
    });
  it('reverts if the seller is already registered', async function () {
    
    await expectRevert(
      this.app.register('0', { from: seller1 }),
      'Boson: seller2 is already registered',
    );
  });

 });

});

