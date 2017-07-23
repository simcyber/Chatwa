//
//  PattyPurchaseOptionsViewController.swift
//  Chatwa iOS
//
//  Created by Javon Davis on 7/11/17.
//  Copyright © 2017 Chatwa. All rights reserved.
//

import UIKit
import StoreKit

typealias Products = [SKProduct]


class PattyPurchaseOptionsViewController: UIViewController {
    @IBOutlet weak var purchaseOptionsTableView: UITableView!
    
    var costs = Constants.Costs.Patties.costs
    var products = Products()
    let store = IAPHelper(productIds: Constants.ProductIdentifiers.pattyIdentifiers)
    var purchaseOptionsIndicator = UIActivityIndicatorView()
    var gameplayDelegate: GameplayDelegate?
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchaseOptionsTableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addActivityIndicator()
        purchaseOptionsIndicator.startAnimating()
        
        // Subscribe to purchase notifications
        NotificationCenter.default.addObserver(self, selector: #selector(applyPattyPurchase(_:)), name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: nil)
        
        
        loadProducts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Outlets
    
    @IBAction func dismissController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PattyPurchaseOptionsViewController {
    
    func addActivityIndicator() {
        purchaseOptionsIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        purchaseOptionsIndicator.activityIndicatorViewStyle = .gray
        purchaseOptionsIndicator.center = self.view.center
        purchaseOptionsIndicator.hidesWhenStopped = true
        self.view.addSubview(purchaseOptionsIndicator)
    }
    
    func loadProducts() {
        products = []
        
        store.requestProducts(completionHandler: { success, products in
            self.purchaseOptionsIndicator.stopAnimating()
            if success {
                self.products = products!
                self.purchaseOptionsTableView.reloadData()
            } else {
                print("Error getting products")
                self.alert(message: "Could not load Patties :(. Please try again later")
            }
        })
    }
    
    func applyPattyPurchase(_ notification: NSNotification) {
        print("Received notification: \(String(describing: notification.object))")
        guard let productIdentifier = notification.object as? String else {
            return
        }
        
        var numberOfPatties: Int?
        
        for pattyCost in Constants.Costs.Patties.costs {
            if pattyCost.productIdentifier == productIdentifier {
                numberOfPatties = pattyCost.numberOfPatties
            }
        }
        
        if numberOfPatties != nil {
            gameplayDelegate?.pattiesPurchased(numberOfPatties!)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table view data source

extension PattyPurchaseOptionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
}

extension PattyPurchaseOptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PattyPurchaseOptionCell", for: indexPath)
        
        let cost = costs[indexPath.row]
        cell.textLabel?.text = "\(cost.numberOfPatties) Patties"
        cell.detailTextLabel?.text = String(cost.cost)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard IAPHelper.canMakePayments() else {
            alert(message: "Purchases can not be made right now. Please check your network and try again later.")
            return
        }
        
        let purchaseOption = costs[indexPath.row]
        
        var product: SKProduct?
        
        for _product in products {
            if _product.productIdentifier == purchaseOption.productIdentifier {
                product = _product
                break
            }
        }
        
        guard product != nil else {
            alert(message: "Purchases can not be made right now. Please check your network and try again later.")
            return
        }
        
        store.buyProduct(product!)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
