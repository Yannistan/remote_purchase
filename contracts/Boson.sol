// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/access/Ownable.sol";

//contract address : 
/**
* @title A blockchain simplified version of Boson protocol's trading platform
* 
* @notice Each user needs first to register as a Buyer or as a Seller. The contract allows for an owner transfership
* Each buyer/seller is registered for 1 year. Registration can be extended after this period.
* Sellers are engaged to fulfill orders for items, otherwise the buyer has the right to get refunded from the escrow back to his account 

* 
@dev All function calls are currently implemented without side effects
*/
contract Boson is Ownable {
    
    // Variables of state
    
     /// @dev mapping from an address to an account balance
    mapping (address => uint) private balances;
   /// @dev address of the escrow account where buyers send prepayments
    address payable addrescrow;

    
     /// @dev struct Buyer
    struct Partie{
         uint id; 
         uint state; // 1 if seller, 2 if buyer 
         uint256 credit; // amount of money in ethers to be deposited to the user's account 
         uint delayRegistration; // until when the buyer is registered 
    }
    
   /// @dev struct Offer
    struct Offer{
        uint idoffer; // id of the offer
        string title; // title of the offer
        uint price; // order price in ethers
        address payable addrseller; // address of the offer's seller;
    }
    
    /// @dev struct Order
    struct Order{
        uint idorder;
        address payable addrseller;
        bool completed; // mapping to check that a buyer has completed the order
        bool complained; // mapping to check if a buyer has complained about an order
    }
    
    
    /// @dev mapping from an address to a Partie
    mapping (address => Partie) parties;
    
    /// @dev mapping from an order's title to an Order
    mapping (string => Order) orders;
    
     /// @dev counter of Partie
    uint private counterPartie;
    
    /// @dev counter of Offers
    uint private counterOffer;
    
    /// @dev counter of Orders
    uint private counterOrder;
    
    /// @dev mapping from an offer's title to an Offer
    mapping (string => Offer) public offers;
    
    
     /// @dev user's options: Buyer, Seller  using enum type
    enum Person {Seller, Buyer} // variables of type Person holding values: 0 -> Person.Seller, 1 -> Person.Buyer 
    
    
     /// @dev a buyer's actions as a function of whether he receives or not a purchase: Completed, Complained or NotComplained  using enum type
    enum Purchase { Completed, Complained, NotComplained } // variables of type Purchase holding values: 0 -> Purchase.Completed, 1 -> Purchase.Complained, 2 -> Purchase.NotComplained 
    
    // Constructor
    /// @dev address _addr of escrow account into which buers place payments for the items they order 
    constructor(address owner, address payable _addr) public{
        addrescrow = _addr;
        transferOwnership(owner);
    }
    
    /// Modifiers
    
    /// @dev modifier to check if the user is a seller
    modifier onlySeller (){
            require (parties[msg.sender].state == 1 , "only seller can call this function");
            _;
        }
    
     /// @dev modifier to check if the user is a buyer
    modifier onlyBuyer (){
            require (parties[msg.sender].state == 2 , "only buyer can call this function");
            _;
        }
    
     /// @dev modifier to check if the user is a buyer or a seller
     modifier onlyBuyerorSeller (){
            require (parties[msg.sender].state == 1  || parties[msg.sender].state == 2 , "only seller or buyer can call this function");
            _;
        }
    
    modifier NotRegistered () {
        require(parties[msg.sender].delayRegistration == 0, 'only non-registered users can call this function');
          _;
    }

    // Functions
    
    /// @dev only a user that hasn't already register as a Seller or a Buyer. The ids is given by the corresponding counter variables. Every new buyer or a seller is registered for a period of 1 year.
    /// @notice the function reverts if the user inputs a value different from 0 or 1, i.e different from Buyer or Seller
    /// @param _person : enum type determining whether the user is a buyer or a seller
    function register(Person _person) public NotRegistered {
        if (_person == Person.Buyer) {
        require(parties[msg.sender].state != 2 , "only for non registered users as buyers");
            if(parties[msg.sender].id != 0) {
           
            parties[msg.sender].state = 2;
            } else {
              counterPartie++;
              uint count0 = counterPartie;
              parties[msg.sender] = Partie(count0, 2, 0, block.timestamp + 52 weeks);
            }
        } else if (_person == Person.Seller) {
         require(parties[msg.sender].state != 1, "only for non registered users as sellers");
            if(parties[msg.sender].id != 0) {
           
            parties[msg.sender].state = 1;
            } else {
            counterPartie++;
            uint count1 = counterPartie;
            parties[msg.sender] = Partie(count1, 1, 0, block.timestamp + 52 weeks);
            }
        } else revert("Invalid status choice");
       
    }
    
     /// @dev Function that is used to retrieve the contents of a Buyer. Used for the tests in order to check the performance of register()
    /// @param partieAddress : address of the buyer (msg.sender)
    function getPartie(address partieAddress) public view returns (Partie memory) {
        return parties[partieAddress];
    }
    
     /// @dev only a seller already registered can call this function. It allows for an offer proposition
    /// @param _title: the title of the offer, i.e. the item offered
    /// @param _price : the item's price in wei
     function offer(string memory _title, uint _price) public onlySeller {
        counterOffer++;
        uint count = counterOffer;
        offers[_title] = Offer(count, _title, _price, msg.sender );
    }
    
    
    /// @dev Function that is used to retrieve the contents of an Offer. Used for the tests in order to check the performance of offer()
    /// @param _titleoffer : The item to be sold
    function getOffer(string memory _titleoffer) public view returns (Offer memory) {
        return offers[_titleoffer];
    }
    
    /// @dev Function that allows buyer's to credit their accounts. Used for the tests in order to check the performance of offer()
    /// @param _amount : The amount to deposit
    function credit(uint256 _amount) public payable onlyBuyerorSeller {
        balances[msg.sender]+= _amount;
        parties[msg.sender].credit = _amount;
    }
    
    /// @dev Function that allows a buyer to order an offer. Used for the tests in order to check the performance of offer()
    /// @notice The function reverts if the buyer does not possess the necessart amount of funds to order an item
    /// @param _title : The item to order
    function order(string memory _title) public onlyBuyer {
        require(balances[msg.sender] >= offers[_title].price, "The buyer needs to have the necessary funds in order to proceed to an order");
        counterOrder++;
        orders[_title].addrseller = offers[_title].addrseller;
        orders[_title] = Order(counterOrder, offers[_title].addrseller, false, false);
        balances[addrescrow]+= offers[_title].price;
        balances[msg.sender]-= offers[_title].price;

    }
    
     /// @dev Function that is used to retrieve the contents of an Order. Used for the tests in order to check the performance of order()
    /// @param _title : The item to be sold
     function getOrder(string memory _title) public view returns (Order memory) {
        return orders[_title];
    }
    
     /// @dev Function that is used to retrieve the escrow account balance.Only the owner of the escrow account can call it
    function getEscrow() public view onlyOwner() returns(uint256) {
        return balances[addrescrow];
    }
    
     /// @dev Function that is used to retrieve a buyer's or seller's account balance.Only a user registered as one of these parties can call it
    function getBalance() public view onlyBuyerorSeller returns(uint256) {
        return balances[msg.sender];
    }
    
     /// @dev Function that is used to determine the actions of a buyer when he receives or not a purchase
    /// @notice In the case where a buyer completes a purchase, teh function reverts if the buyer does not have the nesessary funds
    /// @param _title : The title of the order 
    function check_purchase(string memory _title, Purchase _purchase) public payable onlyBuyer {
        if(_purchase == Purchase.Completed) {
            require(balances[msg.sender]>= offers[_title].price, "there should be enough funds in buyer's account in order to complete the purchase");
            balances[orders[_title].addrseller]+= offers[_title].price;
            balances[addrescrow]-=  offers[_title].price;
            orders[_title].completed = true;
            orders[_title].complained = false;
        } else if (_purchase ==  Purchase.Complained) {
            require(orders[_title].completed == false, "a buyer can complain only for non-completed orders");
            balances[addrescrow]-=  offers[_title].price;
            balances[msg.sender]+= offers[_title].price;
            orders[_title].completed = false;
            orders[_title].complained = true;
           
        } else if (_purchase == Purchase.NotComplained) {
            require(orders[_title].completed == false, "applicable only for non-completed orders");
            orders[_title].completed = false;
            orders[_title].complained = false;
           
        } else revert("Invalid action");
        
    }
        
    }