//
//  Constants.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 10/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

struct NetworkingConstants {
    private init () { }
    static let transactionsUrl = Bundle.main.infoDictionary?["TransactionsAPI"] as! String
    static let ratesUrl = Bundle.main.infoDictionary?["RatesAPI"] as! String
}

struct RequestServiceErrorTexts {
    private init () { }
    static let clientErrorTitle = "Internet connection error"
    static let clientErrorMessage = "Check you internet connection and try again."
    static let serverErrorTitle = "Server error"
    static let serverErrorMessage = "Something happened with the server, try again."
    static let parserErrorTitle = "Parser error"
    static let parserErrorMessage = "Something happened while parsing the data, try again."
    static let tryAgainErrorActionTitle = "Try again"
    static let emptyDataErrorTitle = "No results found"
    static let emptyDataErrorActionTitle = "Search again"
}

struct NavigationControllerTexts {
    private init () { }
    static let navigationControllerTitle = "Transactions"
    static let navigationControllerSearchBarText = "Search transaction"
}

struct ConvertTo {
    private init () { }
    static let currency = "EUR"
}

struct ShowSumFeedback {
    private init () { }
    static let error = "Something happend while calculating..."
    static let loading = "Calculating total in euros ..."
    static let done = "Total: "
}
