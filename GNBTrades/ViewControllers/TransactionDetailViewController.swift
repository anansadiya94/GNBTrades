//
//  TransactionDetailViewController.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 11/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

class TransactionDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var transactionsTotalLabel: UILabel!
    let spinner = UIActivityIndicatorView(style: .gray)
    var transactionsBySku = [Transaction]()
    var rates = [Rate]()
    var isTotal = false
    var isErrorGetingTotal = false
    var sum = NSDecimalNumber(string: "0.0")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSpinner()
        registerTransactionCell()
        showSumFeedback(errorGetingTotal: false, loading: true, total: sum)
        getRates()
    }
    
    private func setSpinner() {
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }
    
    private func registerTransactionCell() {
        tableView.register(UINib(nibName: "TransnactionCell", bundle: nil), forCellReuseIdentifier: "TransnactionCell")
    }
    
    private func showSumFeedback(errorGetingTotal isErrorGetingTotal: Bool, loading isLoading: Bool, total sum: NSDecimalNumber) {
        if isErrorGetingTotal {
            totalView.backgroundColor = .red
            transactionsTotalLabel.text = ShowSumFeedback.error
        } else if isLoading {
            transactionsTotalLabel.text = ShowSumFeedback.loading
        } else {
            transactionsTotalLabel.text = ShowSumFeedback.done + String(describing: sum) + " " + ConvertTo.currency
        }
    }
    
    private func getRates() {
        RequestService.shared.getRates(onSuccess: { (ratesResponse) in
            self.rates = ratesResponse
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
            self.calculateTotal()
        }) { (error) in
            self.handleRequestServiceError(error!)
        }
    }
    
    private func calculateTotal() {
        CalculationService.shared.getTotal(transactions: transactionsBySku, rates: rates, onSuccess: { (sumResponse) in
            self.sum = sumResponse
            DispatchQueue.main.async{
                self.showSumFeedback(errorGetingTotal: false, loading: false, total: self.sum)
            }
        }) { (error) in
            self.showSumFeedback(errorGetingTotal: true, loading: false, total: self.sum)
        }
    }
    
    private func getAmountInEuro(amount: String) -> Double? {
        guard let doubleAmount = Double(amount) else {return 0.0}
        return doubleAmount
    }
    
    private func handleRequestServiceError(_ error: RequestServiceError) {
        switch error {
        case .clientError:
            self.generateAlert(title: RequestServiceErrorTexts.clientErrorTitle, message: RequestServiceErrorTexts.clientErrorMessage, actionTitle: RequestServiceErrorTexts.tryAgainErrorActionTitle, requestServiceError: .clientError, viewController: self)
        case .serverError:
            self.generateAlert(title: RequestServiceErrorTexts.serverErrorTitle, message: RequestServiceErrorTexts.serverErrorMessage, actionTitle: RequestServiceErrorTexts.tryAgainErrorActionTitle, requestServiceError: .serverError, viewController: self)
        case .parserError:
            self.generateAlert(title: RequestServiceErrorTexts.parserErrorTitle, message: RequestServiceErrorTexts.parserErrorTitle, actionTitle: RequestServiceErrorTexts.tryAgainErrorActionTitle, requestServiceError: .serverError, viewController: self)
        }
    }
    
    private func generateAlert(title: String, message: String, actionTitle: String, requestServiceError: RequestServiceError, viewController: TransactionDetailViewController) {
        DispatchQueue.main.async{
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            switch requestServiceError {
            case .clientError, .serverError:
                alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { action in
                    self.getRates()
                }))
                break
            default:
                break
            }
            viewController.present(alert, animated: true)
        }
    }
}

extension TransactionDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsBySku.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        spinner.stopAnimating()
        if let cell: TransactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransnactionCell") as? TransactionTableViewCell {
            cell.setUp(transaction: transactionsBySku[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}
