//
//  ViewController.swift
//  GNBTrades
//
//  Created by Anan Sadiya on 10/09/2019.
//  Copyright © 2019 Anan Sadiya. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let spinner = UIActivityIndicatorView(style: .gray)
    let searchController = UISearchController(searchResultsController: nil)
    var transactions = [Transaction]()
    var filteredTransactions = [Transaction]()
    var isFiltering = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController()
        setSpinner()
        registerTransactionCell()
        getTransactions()
    }
    
    private func setNavigationController() {
        self.navigationItem.title = NavigationControllerTexts.navigationControllerTitle
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NavigationControllerTexts.navigationControllerSearchBarText
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setSpinner() {
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }
    
    private func registerTransactionCell() {
        tableView.register(UINib(nibName: "TransnactionCell", bundle: nil), forCellReuseIdentifier: "TransnactionCell")
    }
    
    private func getTransactions() {
        RequestService.shared.getTransactions(onSuccess: { (transactionsReponse) in
            self.transactions = transactionsReponse
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }) { (error) in
            self.handleRequestServiceError(error!)
        }
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
    
    private func generateAlert(title: String, message: String, actionTitle: String, requestServiceError: RequestServiceError, viewController: TransactionsViewController) {
        DispatchQueue.main.async{
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            switch requestServiceError {
            case .clientError, .serverError:
                alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { action in
                    self.getTransactions()
                }))
                break
            default:
                break
            }
            viewController.present(alert, animated: true)
        }
    }
}

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isFiltering ? self.filteredTransactions.count : transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        spinner.stopAnimating()
        if let cell: TransactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransnactionCell") as? TransactionTableViewCell {
            let transaction: Transaction
            if isFiltering {
                transaction = filteredTransactions[indexPath.row]
            } else {
                transaction = transactions[indexPath.row]
            }
            cell.setUp(transaction: transaction)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let transactionDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "TransactionDetailViewController") as? TransactionDetailViewController else {return}
        transactionDetailViewController.transactionsBySku = transactions.filter {$0.sku == transactions[indexPath.row].sku}
        self.navigationController?.pushViewController(transactionDetailViewController, animated: true)
    }
}

extension TransactionsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            filteredTransactions = transactions.filter({ (transaction) -> Bool in
                return transaction.sku.lowercased().contains(text.lowercased())
            })
            isFiltering = true
        }
        else {
            isFiltering = false
            filteredTransactions = [Transaction]()
        }
        tableView.reloadData()
    }
}
