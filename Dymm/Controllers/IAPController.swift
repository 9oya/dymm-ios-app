//
//  IAPController.swift
//  Dymm
//
//  Created by Eido Goya on 2019/10/20.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit
import StoreKit

class IAPController: UIViewController {
    
    // MARK - Properties
    
    // UIButton
    var purchaseButton: UIButton!
    var restoreButton: UIButton!
    
    // UILabel
    var lblPurchaseDone: UILabel!
    
    // UIImageView
    var loadingImageView: UIImageView!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var PRODUCT_ID = "com.9oya.dymm.premium2"
    var SHARED_SECRET = "6be41dc52be84d78ba58cf74d3b13af0"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let isPurchased = UserDefaults.standard.value(forKey: "isPurchased") as? Bool, isPurchased == true {
            // TODO: Product is purchased and make sure the functionality/availability of purchased product
            lblPurchaseDone.isHidden = false
            self.purchaseButton.isHidden = true
            self.restoreButton.isHidden = true
        }
        else{
            /* Product is not purchased */
            lblPurchaseDone.isHidden = true
            self.fetchAvailableProducts()
        }
    }
    
    // MARK - Actions
    
    @objc func purchaseButtonTapped() {
        purchaseProduct(product: iapProducts[0])
    }
    
    @objc func restoreButtonTapped() {
        showLoaderView(with: "Restoring...")
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension IAPController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        hideLoader()
        // TODO: Product is restored and make sure the functionality/availability of purchased product
        UserDefaults.standard.set(true, forKey: "isPurchased")
        lblPurchaseDone.text = "Pro Version Restored."
        lblPurchaseDone.isHidden = false
        purchaseButton.isHidden = true
        restoreButton.isHidden = true
        self.present(Utilities().showAlertContrller(title: "Restore Success", message: "You've successfully restored your purchase!"), animated: true, completion: nil)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            iapProducts = response.products
            let purchasingProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = purchasingProduct.priceLocale
            let price = numberFormatter.string(from: purchasingProduct.price)
            
            // Show description
            purchaseButton.setTitle("Get " + purchasingProduct.localizedDescription + " for \(price!)", for: .normal)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    hideLoader()
                    
                    if let paymentTransaction = transaction as? SKPaymentTransaction {
                        SKPaymentQueue.default().finishTransaction(paymentTransaction)
                    }
                    
                    if productID == PRODUCT_ID {
                        UserDefaults.standard.set(true, forKey: "isPurchased")
                        lblPurchaseDone.text = "Pro version PURCHASED!"
                        lblPurchaseDone.isHidden = false
                        purchaseButton.isHidden = true
                        restoreButton.isHidden = true
                        self.present(Utilities().showAlertContrller(title: "Purchase Success", message: "You've successfully purchased"), animated: true, completion: nil)
                    }
                case .failed:
                    hideLoader()
                    if trans.error != nil {
                        self.present(Utilities().showAlertContrller(title: "Purchase failed!", message: trans.error!.localizedDescription), animated: true, completion: nil)
                        print(trans.error!)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default: break
                }
            }
        }
    }
}

extension IAPController {
    // MARK: - Private methods
    
    private func setupLayout() {
        // Initialize super view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
//        navigationItem.title = lang.titleNotes
        view.backgroundColor = UIColor.whiteSmoke
        
        purchaseButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.white, for: .normal)
            _button.backgroundColor = .tomato
            _button.titleLabel?.font = .systemFont(ofSize: 15)
            _button.setTitle("Get Dymm Premium", for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        restoreButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.black, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 15)
            _button.setTitle("Restore Purchase", for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        lblPurchaseDone = {
            let _label = UILabel()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        activityIndicator = {
            let _indicator = UIActivityIndicatorView()
            _indicator.center = view.center
            _indicator.style = .gray
            _indicator.hidesWhenStopped = true
            return _indicator
        }()
        
        view.addSubview(purchaseButton)
        view.addSubview(restoreButton)
        view.addSubview(lblPurchaseDone)
        
        purchaseButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        purchaseButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
        
        restoreButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        restoreButton.topAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: 10).isActive = true
        
        lblPurchaseDone.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        lblPurchaseDone.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            showLoaderView(with: "Purchasing...")
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            print("Product to Purchase: \(product.productIdentifier)")
            productID = product.productIdentifier
        } else {
            // IAP Purchases disabled on the Device
            self.present(Utilities().showAlertContrller(title: "Oops!", message: "Purchases are disabled in your device!"), animated: true, completion: nil)
        }
    }
    
    func fetchAvailableProducts() {
        let productIdentifiers = NSSet(objects:
            PRODUCT_ID
        )
        
        guard let identifier = productIdentifiers as? Set<String> else { return }
        productsRequest.cancel()
        
        productsRequest = SKProductsRequest(productIdentifiers: identifier)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func showLoaderView(with title:String) {
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func hideLoader() {
        activityIndicator.stopAnimating()
    }
}
