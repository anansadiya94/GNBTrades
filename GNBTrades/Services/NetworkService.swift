//
//  NetworkService.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 10/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private init(){}

    func getTransactions(onSuccess success: @escaping (_ transactions: [Transaction]) -> Void, onFailure failure: @escaping (RequestServiceError?) -> Void) {
        let url = NetworkingConstants.transactionsUrl
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request as URLRequest) { data, urlResponse, error in
            if error != nil || data == nil {
                failure(.clientError)
                return
            }
            guard let response = urlResponse as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                failure(.serverError)
                return
            }
            guard let data = data else {return}
            guard let transactions = JSONParser.parseTransactions(data) else {
                failure(.parserError)
                return
            }
            success(transactions)
        }.resume()
    }
    
    func getRates(onSuccess success: @escaping (_ rates: [Rate]) -> Void, onFailure failure: @escaping (RequestServiceError?) -> Void) {
        let url = NetworkingConstants.ratesUrl
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request as URLRequest) { data, urlResponse, error in
            if error != nil || data == nil {
                failure(.clientError)
                return
            }
            guard let response = urlResponse as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                failure(.serverError)
                return
            }
            guard let data = data else {return}
            guard let rates = JSONParser.parseRates(data) else {
                failure(.parserError)
                return
            }
            success(rates)
        }.resume()
    }
    
}
