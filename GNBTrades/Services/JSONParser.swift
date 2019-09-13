//
//  JSONParser.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 10/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

class JSONParser {
    static func parseTransactions(_ params: Data) -> [Transaction]? {
        do {
            let decoder = JSONDecoder()
            let transactions = try decoder.decode([Transaction].self, from: params)
            return transactions
        } catch {
            return nil
        }
    }
    
    static func parseRates(_ params: Data) -> [Rate]? {
        do {
            let decoder = JSONDecoder()
            let rates = try decoder.decode([Rate].self, from: params)
            return rates
        } catch {
            return nil
        }
    }
}
