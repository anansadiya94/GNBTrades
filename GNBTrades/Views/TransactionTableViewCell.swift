//
//  TransactionTableViewCell.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 10/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    func setUp(transaction: Transaction) {
        skuLabel.text = transaction.sku
        amountLabel.text = transaction.amount
        currencyLabel.text = transaction.currency
    }
}
