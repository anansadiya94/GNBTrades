//
//  GNBTradesTests.swift
//  GNBTradesTests
//
//  Created by Anan Sadiya on 10/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import XCTest
@testable import GNBTrades

let fakeJsonTransactions = """
[{"sku":"W8153","amount":"23.1","currency":"AUD"},
{"sku":"W8153","amount":"22.5","currency":"EUR"},
{"sku":"V8560","amount":"33.1","currency":"CAD"},
{"sku":"A2573","amount":"23.7","currency":"EUR"},
{"sku":"Y0095","amount":"26.4","currency":"EUR"},
{"sku":"L4987","amount":"23.5","currency":"EUR"},
{"sku":"L2263","amount":"18.6","currency":"EUR"},
{"sku":"V8461","amount":"19.9","currency":"CAD"},
{"sku":"Y0095","amount":"24.6","currency":"AUD"},
{"sku":"Y0095","amount":"30.8","currency":"AUD"},
{"sku":"V8461","amount":"18.3","currency":"EUR"},
{"sku":"L2263","amount":"33.3","currency":"CAD"},
{"sku":"J2256","amount":"19.0","currency":"EUR"},
{"sku":"W8153","amount":"16.4","currency":"USD"},
{"sku":"Y0384","amount":"32.6","currency":"AUD"},
{"sku":"L2263","amount":"16.8","currency":"EUR"},
{"sku":"A2573","amount":"34.9","currency":"AUD"},
{"sku":"L2263","amount":"16.4","currency":"EUR"},
{"sku":"W8153","amount":"29.3","currency":"AUD"},
{"sku":"L2263","amount":"15.3","currency":"EUR"},
{"sku":"V8560","amount":"27.2","currency":"CAD"},
{"sku":"V8461","amount":"32.5","currency":"USD"},
{"sku":"K8543","amount":"16.7","currency":"USD"},
{"sku":"Y0095","amount":"16.6","currency":"CAD"},
{"sku":"T3236","amount":"29.4","currency":"CAD"},
{"sku":"L2263","amount":"15.8","currency":"AUD"},
{"sku":"Y0384","amount":"24.8","currency":"CAD"},
{"sku":"Y0384","amount":"25.7","currency":"EUR"},
{"sku":"A2573","amount":"19.3","currency":"AUD"},
{"sku":"W8153","amount":"31.9","currency":"USD"}]
"""

let fakeJsonRates = """
[{"from":"USD","to":"EUR","rate":"0.65"},
{"from":"EUR","to":"USD","rate":"1.54"},
{"from":"USD","to":"AUD","rate":"1.35"},
{"from":"AUD","to":"USD","rate":"0.74"},
{"from":"EUR","to":"CAD","rate":"1.18"},
{"from":"CAD","to":"EUR","rate":"0.85"}]
"""

class FakeSuccessNetworkService: NetworkServiceProtocol {
    var didCallGetTransactions = false
    var didCallGetRates = false
    
    func getTransactions(onSuccess success: @escaping ([Transaction]) -> Void, onFailure failure: @escaping (RequestServiceError?) -> Void) {
        didCallGetTransactions = true
        if let data: Data = fakeJsonTransactions.data(using: String.Encoding.utf8) {
            let transactions = try! JSONDecoder().decode([Transaction].self, from: data)
            success(transactions)
        }
    }
    
    func getRates(onSuccess success: @escaping ([Rate]) -> Void, onFailure failure: @escaping (RequestServiceError?) -> Void) {
        didCallGetRates = true
        if let data: Data = fakeJsonRates.data(using: String.Encoding.utf8) {
            let rates = try! JSONDecoder().decode([Rate].self, from: data)
            success(rates)
        }
    }
}

class FakeFailureNetworkService: NetworkServiceProtocol {
    var didCallGetTransactions = false
    var didCallGetRates = false
    
    func getTransactions(onSuccess success: @escaping ([Transaction]) -> Void, onFailure failure: @escaping (RequestServiceError?) -> Void) {
        failure(RequestServiceError.clientError)
    }
    
    func getRates(onSuccess success: @escaping ([Rate]) -> Void, onFailure failure: @escaping (RequestServiceError?) -> Void) {
        failure(RequestServiceError.clientError)
    }
}

class FakeSuccessCalculationService: CalculationServiceProtocol {
    var didCallGetTotal = false
    var sku = ""
    
    func getTotal(transactions: [Transaction], rates: [Rate], onSuccess success: @escaping (NSDecimalNumber) -> Void, onFailure failure: @escaping (String) -> Void) {
        didCallGetTotal = true
        let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        var sumUsingNSDecimalArray = [NSDecimalNumber]()
        var transactions = [Transaction]()
        var transactionsBySku = [Transaction]()
        var rates = [Rate]()
        if let data: Data = fakeJsonTransactions.data(using: String.Encoding.utf8) {
            transactions = try! JSONDecoder().decode([Transaction].self, from: data)
            transactionsBySku = transactions.filter {$0.sku == sku}
        }
        
        if let data: Data = fakeJsonRates.data(using: String.Encoding.utf8) {
            rates = try! JSONDecoder().decode([Rate].self, from: data)
        }
        
        for transaction in transactionsBySku {
            sumUsingNSDecimalArray.append(CalculationService.shared.chageToEuro(transaction, rates))
        }
        
        var sumUsingNSDecimalTotal = sumUsingNSDecimalArray.reduce(0, +)
        sumUsingNSDecimalTotal = sumUsingNSDecimalTotal.rounding(accordingToBehavior: handler)
        success(sumUsingNSDecimalTotal)
    }   
}

class FakeFailureCalculationService: CalculationServiceProtocol {
    func getTotal(transactions: [Transaction], rates: [Rate], onSuccess success: @escaping (NSDecimalNumber) -> Void, onFailure failure: @escaping (String) -> Void) {
        failure(ShowSumFeedback.error)
    }
}

class GNBTradesTests: XCTestCase {
    var successNetworkService : FakeSuccessNetworkService?
    var failureNetworkService : FakeFailureNetworkService?
    var successCalculationService : FakeSuccessCalculationService?
    var failureCalculationService : FakeFailureCalculationService?
    
    var transactions = [Transaction]()
    var rates = [Rate]()
    
    override func setUp() {
        successNetworkService = FakeSuccessNetworkService()
        failureNetworkService = FakeFailureNetworkService()
        successCalculationService = FakeSuccessCalculationService()
        failureCalculationService = FakeFailureCalculationService()
    }
    
    override func tearDown() {
        successNetworkService = nil
        successCalculationService = nil
    }

    func testGetTransactions() {
        XCTAssertFalse(successNetworkService?.didCallGetTransactions ?? false)
        successNetworkService?.getTransactions(onSuccess: { transactionsResponse in
            XCTAssertTrue(self.successNetworkService?.didCallGetTransactions ?? false)
            XCTAssertTrue(!transactionsResponse.isEmpty)
            XCTAssert(transactionsResponse.count == 30)
            self.transactions = transactionsResponse
        }, onFailure: { (failure) in
        })
    }
    
    func testGetRates() {
        XCTAssertFalse(successNetworkService?.didCallGetRates ?? false)
        successNetworkService?.getRates(onSuccess: { ratesResponse in
            XCTAssertTrue(self.successNetworkService?.didCallGetRates ?? false)
            XCTAssertTrue(!ratesResponse.isEmpty)
            XCTAssert(ratesResponse.count == 6)
            self.rates = ratesResponse
        }, onFailure: { (failure) in
        })
    }
    
    //Client has no internet
    func testGetTransactionsFails() {
        XCTAssertFalse(successNetworkService?.didCallGetTransactions ?? false)
        failureNetworkService?.getTransactions(onSuccess: { transactions in
        }, onFailure: { (failure) in
            XCTAssertNotNil(failure)
            XCTAssertTrue(failure == RequestServiceError.clientError)
        })
    }
    
    func testGetRatesFails() {
        XCTAssertFalse(successNetworkService?.didCallGetRates ?? false)
        failureNetworkService?.getRates(onSuccess: { rates in
        }, onFailure: { (failure) in
            XCTAssertNotNil(failure)
            XCTAssertTrue(failure == RequestServiceError.clientError)
        })
    }
    
    func testGetTotalW8153() {
        XCTAssertFalse(successCalculationService?.didCallGetTotal ?? false)
        successCalculationService?.sku = "W8153"
        let transactionsBySku = transactions.filter {$0.sku == successCalculationService?.sku}
        successCalculationService?.getTotal(transactions: transactionsBySku, rates: rates, onSuccess: { sum in
            XCTAssertTrue(self.successCalculationService?.didCallGetTotal ?? false)
            XCTAssertEqual(sum.stringValue, "79.1")
        }, onFailure: { (failure) in
            XCTAssertNotNil(failure)
        })
    }
    
    func testGetTotalV8560() {
        XCTAssertFalse(successCalculationService?.didCallGetTotal ?? false)
        successCalculationService?.sku = "V8560"
        let transactionsBySku = transactions.filter {$0.sku == successCalculationService?.sku}
        successCalculationService?.getTotal(transactions: transactionsBySku, rates: rates, onSuccess: { sum in
            XCTAssertTrue(self.successCalculationService?.didCallGetTotal ?? false)
            XCTAssertEqual(sum.stringValue, "51.26")
        }, onFailure: { (failure) in
            XCTAssertNotNil(failure)
        })
    }
    
    func testGetTotalA2573() {
        XCTAssertFalse(successCalculationService?.didCallGetTotal ?? false)
        successCalculationService?.sku = "A2573"
        let transactionsBySku = transactions.filter {$0.sku == successCalculationService?.sku}
        successCalculationService?.getTotal(transactions: transactionsBySku, rates: rates, onSuccess: { sum in
            XCTAssertTrue(self.successCalculationService?.didCallGetTotal ?? false)
            XCTAssertEqual(sum.stringValue, "49.77")
        }, onFailure: { (failure) in
            XCTAssertNotNil(failure)
        })
    }
    
    func testGetTotalY0095() {
        XCTAssertFalse(successCalculationService?.didCallGetTotal ?? false)
        successCalculationService?.sku = "Y0095"
        let transactionsBySku = transactions.filter {$0.sku == successCalculationService?.sku}
        successCalculationService?.getTotal(transactions: transactionsBySku, rates: rates, onSuccess: { sum in
            XCTAssertTrue(self.successCalculationService?.didCallGetTotal ?? false)
            XCTAssertEqual(sum.stringValue, "67.16")
        }, onFailure: { (failure) in
            XCTAssertNotNil(failure)
        })
    }
    
    func testGetTotalL4987() {
        XCTAssertFalse(successCalculationService?.didCallGetTotal ?? false)
        successCalculationService?.sku = "L4987"
        let transactionsBySku = transactions.filter {$0.sku == successCalculationService?.sku}
        successCalculationService?.getTotal(transactions: transactionsBySku, rates: rates, onSuccess: { sum in
            XCTAssertTrue(self.successCalculationService?.didCallGetTotal ?? false)
            XCTAssertEqual(sum.stringValue, "23.5")
        }, onFailure: { (failure) in
            XCTAssertNotNil(failure)
        })
    }
}
