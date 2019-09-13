//
//  RequestService.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 10/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

class RequestService: RequestServiceProtocol {
    static let shared = RequestService()
    
    private init(){}
    
    func getTransactions(onSuccess success: @escaping ([Transaction]) -> Void, onFailure failure: @escaping (RequestServiceError?) -> Void) {
        NetworkService.shared.getTransactions(onSuccess: { (transactions) in
            success(transactions)
        }) { (error) in
            failure(error)
        }
    }
    
    func getRates(onSuccess success: @escaping ([Rate]) -> Void, onFailure failure: @escaping (RequestServiceError?) -> Void) {
        NetworkService.shared.getRates(onSuccess: { (rates) in
            success(rates)
        }) { (error) in
            failure(error)
        }
    }
}
