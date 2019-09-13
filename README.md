# GNBTrades
> Mobile interview exercise

[![Swift compatible](https://img.shields.io/badge/Swift-5.0-orange.svg)]()

## International Business Men
The app offers a list of GNB products using their transactions. By scrolling down, a Search Bar will appear and you can even search for the desired product by his "sku". After finding the desired product, click on it to see all his tansactions and the total sum of them in Euros.

### About app
The app was developed using MVC (Model View Controller) architecture. While GNB products information has been extracted from [Transactions API](http://quiet-stone-2094.herokuapp.com/transactions.json), and GNB rates information has been extracted from [Rates API](http://quiet-stone-2094.herokuapp.com/rates.json). Design patterns were used, and Unit tests were done.

- Extra: 
    - As the app is dealing with money, 'NSDecimalNumber' was used and not 'Double', as 'Double' lose some decimals. 
    - The result has been rounded to two decimals, using Banker's Rounding.
    - Accept header with json type was used on making the HTTP request.

### Requirements
* iOS 12.4
* Xcode 10.3
* Swift 5.0

### Installation guide
#### Download repo
```sh
$ git clone https://github.com/anansadiya94/GNBTrades.git
$ cd GNBTrades
$ open GNBTrades.xcodeproj
```
#### Run app
Xcode will be opened, run the app using your iPhone or your favorite simulator and enjoy it :)

### About me
Anan Sadiya – anansadiya@gmail.com

[https://github.com/anansadiya94](https://github.com/anansadiya94)
