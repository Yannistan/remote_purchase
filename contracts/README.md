**Presentation**
The solidity file boson_test.sol contains the smart contract Boson which describes a simplified version of the Boson Protocol exchange mechanism, by the aid of an escrow arrangement. In other words, the contract allows for a safe remote purchase system. The contract is deployed in Ganache testnet. The owner and escrow addresses are passed as an argument in the constructor. In order that the person that deployes the contract is not necessarily the contract's owner, the contract inherits from an Ownable.sol contract from the OpenZeppelin libraries and makes use of the transferownership function of the latter contract. 
With the exception of the escrow's address, every other user has to register as either a Seller or a Buyer. If a user has already registered, he is not allowed to re-register with the same Partie state. We assume that the registration of each user has a period of 1 year after which the user needs to renew it. If a person is registered as a seller/Buyer, he is also allowed to register as a buyer/seller but retains his id. 
A seller can credit his account balance via the use of the credit() function. Offers are   
A seller has the option to propose an Offer via the order() function. A buyer performes an order via the order() function and transfers the amount corresponding to the product's price to the escrow account. The latter can only be viewed by the owner. No order can be performed if the buyer does not possess the necessary funds in his account. 



The contract inherits from the Open Zeppelin contract Ownable already tested contracts.
Unit tests are performed by the aid of Mocha test framework, Chai assertion library and Open Zeppelin's Test Environment and Test Helpers.
The contract is deployed via Truffle in Ganache Testnet.
Comments are implemented using NatSpec format.

***Installations***
Install dependencies:
% yarn install



