pragma solidity ^0.4.18;

import "./Ownable.sol";

contract ChainList is Ownable{
  //custom types

  struct Article{
    uint id;
    address seller;
    address buyer;
    string name;
    string description;
    uint256 price;
  }

  //state variables
  mapping (uint => Article) public articles;
  uint articleCounter;
  //constructor
  /*function ChainList() public {
    sellArticle("Default article", "this is an article set by default", 1000000000000000000);
  }*/
  //events
  event LogSellArticle(
    uint indexed _id,
    address indexed _seller,
    string _name,
    uint256 _price
  );

  event LogBuyArticle(
    uint indexed _id,
    address indexed _seller,
    address indexed _buyer,
    string _name,
    uint256 _price
  );

  //deactivate contract
  function kill() public onlyOwner{
    //only allow the contract owner with modifier onlyOwner
    selfdestruct(owner);
  }
  //sell article
  function sellArticle(string _name, string _description, uint256 _price) public {
    /*seller = msg.sender;
    name = _name;
    description = _description;
    price = _price;*/

    //a new article
    articleCounter++;
    articles[articleCounter] = Article(
      articleCounter,
      msg.sender,
      0x0,
      _name,
      _description,
      _price
      );

    LogSellArticle(articleCounter, msg.sender, _name, _price);
  }


  //get an article
  /*function getArticle() public view returns (
    address _seller,
    address _buyer,
    string _name,
    string _description,
    uint256 _price
    ){
      return(seller, buyer, name, description, price);
  }*/

  //fetch the number of articles in the contract
  function getNumberOfArticles() public view returns (uint){
    return articleCounter;
  }

  //fetch and return all article IDs for articles still for sale
  function getArticlesForSale() public view returns (uint[]){
    //prepare output array
    uint[] memory articleIds = new uint[](articleCounter);

    uint numberOfArticlesForSale = 0;

    //iterate for articles
    for (uint i = 1; i<= articleCounter; i++){
      //keep the ID if article is still for sale
      if(articles[i].buyer == 0x0){
        articleIds[numberOfArticlesForSale] = articles[i].id;
        numberOfArticlesForSale++;
      }
    }
    //copy the articleIds array into a smaller for sale array
    uint[] memory forSale = new uint[](numberOfArticlesForSale);
    for (uint j; j< numberOfArticlesForSale;j++){
      forSale[j] = articleIds[j];
    }
    return forSale;
  }

  function buyArticle(uint _id) payable public{
    // we check whether there is an article to sale
    require(articleCounter > 0);

    //we check that the article exists\
    require(_id > 0 && _id<=articleCounter);

    //we retrieve the article from mappping
    Article storage article = articles[_id];

    //we check that the article has not been sold yet
    require(article.buyer == 0x0);

    //we don't allow the seller to buy his onw article
    require(msg.sender != article.seller);

    // we chech that the value sent corresponds to the price of the article
    require(msg.value == article.price);

    //keep track of buyer information
    article.buyer = msg.sender;

    //the buyer can pay the _seller
    article.seller.transfer(msg.value);

    //trigger the event
    LogBuyArticle(_id, article.seller, article.buyer, article.name, article.price);
  }
}
