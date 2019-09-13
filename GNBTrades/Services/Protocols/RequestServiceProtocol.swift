//
//  RequestServiceProtocol.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 10/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

protocol RequestServiceProtocol {
    func getTransactions(onSuccess success: @escaping (_ transactions: [Transaction]) -> Void, onFailure failure: @escaping (_ error: RequestServiceError?) -> Void)
    func getRates(onSuccess success: @escaping (_ rates: [Rate]) -> Void, onFailure failure: @escaping (_ error: RequestServiceError?) -> Void)
}

