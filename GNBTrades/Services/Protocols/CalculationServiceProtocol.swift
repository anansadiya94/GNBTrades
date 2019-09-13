//
//  CalculationServiceProtocol.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 11/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

protocol CalculationServiceProtocol {
    func getTotal(transactions: [Transaction], rates: [Rate], onSuccess success: @escaping (_ sum: NSDecimalNumber) -> Void, onFailure failure: @escaping (_ error: String) -> Void)
}
