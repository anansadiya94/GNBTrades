//
//  CalculationService.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 11/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

func +(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.adding(rhs)
}

class CalculationService: CalculationServiceProtocol {
    static let shared = CalculationService()
    
    private init(){}
    
    func getTotal(transactions: [Transaction], rates: [Rate], onSuccess success: @escaping (NSDecimalNumber) -> Void, onFailure failure: @escaping (String) -> Void) {
        let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        var sumUsingNSDecimalArray = [NSDecimalNumber]()
        for transaction in transactions {
            sumUsingNSDecimalArray.append(chageToEuro(transaction, rates))
        }
        var sumUsingNSDecimalTotal = sumUsingNSDecimalArray.reduce(0, +)
        sumUsingNSDecimalTotal = sumUsingNSDecimalTotal.rounding(accordingToBehavior: handler)
        success(sumUsingNSDecimalTotal)
    }
    
    func chageToEuro(_ transaction: Transaction, _ rates: [Rate]) -> NSDecimalNumber {
        if transaction.currency == ConvertTo.currency {
            return NSDecimalNumber(string: transaction.amount)
        } else if existsDirectCurrencyExchange(transaction, rates) {
            return convertExistingDirectCurrencyExchange(transaction, rates)
        } else if existsInDirectCurrencyExchange(transaction, rates) {
            return convertExistingInDirectCurrencyExchange(transaction, rates)
        }
        return 0.0
    }
    
    private func existsDirectCurrencyExchange(_ transaction: Transaction, _ rates: [Rate]) -> Bool {
        let filteredRates = rates.filter {$0.from == transaction.currency && $0.to == ConvertTo.currency}
        if filteredRates.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    private func convertExistingDirectCurrencyExchange(_ transaction: Transaction, _ rates: [Rate]) -> NSDecimalNumber {
        let filteredRates = rates.filter {$0.from == transaction.currency && $0.to == ConvertTo.currency}
        if filteredRates.isEmpty {
            return 0.0
        } else if filteredRates.count == 1 {
            return NSDecimalNumber(string: transaction.amount).multiplying(by: NSDecimalNumber(string: filteredRates[0].rate))
        } else {
            return 0.0
        }
    }
    
    private func existsInDirectCurrencyExchange(_ transaction: Transaction, _ rates: [Rate]) -> Bool {
        var isExist = false
        for rate in rates {
            if rate.to == ConvertTo.currency || isExist == false {
                for r in rates {
                    if r.from == transaction.currency && r.to == rate.from {
                        isExist = true
                        break
                    }
                }
            } else {
                break
            }
        }
        return isExist
    }
    
    private func convertExistingInDirectCurrencyExchange(_ transaction: Transaction, _ rates: [Rate]) -> NSDecimalNumber {
        var isExist = false
        for rate in rates {
            if rate.to == ConvertTo.currency || isExist == false {
                for r in rates {
                    if r.from == transaction.currency && r.to == rate.from {
                        let amount = NSDecimalNumber(string: transaction.amount)
                        let rate1 = NSDecimalNumber(string: r.rate)
                        let rate2 = NSDecimalNumber(string: rate.rate)
                        let firstMultply = amount.multiplying(by: rate1)
                        let secondMultply = firstMultply.multiplying(by: rate2)
                        isExist = true
                        return secondMultply
                    }
                }
            }
        }
        return 0.0
    }
}
