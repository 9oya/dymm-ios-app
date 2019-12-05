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
    
    // UIView
    var blackBoardView: UIView!
    var topBarView: UIView!
    
    // UIButton
    var purchaseButton: UIButton!
    var restoreButton: UIButton!
    
    // UILabel
    var eventLabel: UILabel!
    var productDscLabel: UILabel!
    var lblPurchaseDone: UILabel!
    
    // UIImageView
    var logoImageView: UIImageView!
    
    // UIActivityIndicatorView
    var activityIndicator: UIActivityIndicatorView!
    
    var PRODUCT_ID = "V1APcEPXKg1fPCUULWtZ1cuCcEGOleI3"
    var SHARED_SECRET = "6be41dc52be84d78ba58cf74d3b13af0"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
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
    
//    override func viewWillAppear(_ animated: Bool) {
//
//    }
    
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
//            UIView.transition(with: purchaseButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
//                self.purchaseButton.setTitle("Get " + purchasingProduct.localizedDescription + " for \(price!)", for: .normal)
//            })
            DispatchQueue.main.async {
                self.purchaseButton.setTitle(purchasingProduct.localizedTitle.uppercased(), for: .normal)
                self.productDscLabel.text = "\(price!) / \(purchasingProduct.localizedDescription)"
//                self.purchaseButton.setTitle("Get " + purchasingProduct.localizedDescription + " for \(price!)", for: .normal)
            }
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
        
        topBarView = getAddtionalTopBarView()
        logoImageView = {
            let _imageView = UIImageView()
            _imageView.image = .itemLogoM
            _imageView.contentMode = .scaleAspectFit
            _imageView.clipsToBounds = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        eventLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15, weight: .medium)
            _label.textColor = .mediumSeaGreen
            _label.textAlignment = .center
            _label.text = "+1 Month Free Trial"
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        purchaseButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.white, for: .normal)
            _button.backgroundColor = .red_FE4C4C
            _button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            _button.layer.cornerRadius = 10.0
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        productDscLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15, weight: .regular)
            _label.textColor = .black
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        restoreButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.black, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 16)
            _button.setTitle("Restore premium", for: .normal)
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
        blackBoardView = {
            let _view = UIView()
            _view.backgroundColor = UIColor(hex: "#26312B")
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        activityIndicator = {
            let _indicator = UIActivityIndicatorView()
            _indicator.center = view.center
            _indicator.style = .gray
            _indicator.hidesWhenStopped = true
            return _indicator
        }()
        
        view.addSubview(logoImageView)
        view.addSubview(purchaseButton)
        view.addSubview(productDscLabel)
        view.addSubview(eventLabel)
        view.addSubview(lblPurchaseDone)
        view.addSubview(blackBoardView)
        view.addSubview(topBarView)
        
        topBarView.addSubview(restoreButton)
        
        topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        topBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        topBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        topBarView.heightAnchor.constraint(equalToConstant: CGFloat(topBarHeightInt)).isActive = true
        
        restoreButton.topAnchor.constraint(equalTo: topBarView.topAnchor, constant: 0).isActive = true
        restoreButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -20).isActive = true
        restoreButton.bottomAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 0).isActive = true
        
        logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: purchaseButton.topAnchor, constant: -40).isActive = true
        
        purchaseButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        purchaseButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -20).isActive = true
        purchaseButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        purchaseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        eventLabel.bottomAnchor.constraint(equalTo: purchaseButton.topAnchor, constant: -5).isActive = true
        eventLabel.trailingAnchor.constraint(equalTo: purchaseButton.trailingAnchor, constant: 0).isActive = true
        
        productDscLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        productDscLabel.topAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: 10).isActive = true
        
        lblPurchaseDone.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        lblPurchaseDone.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
        
        blackBoardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        blackBoardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        blackBoardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        blackBoardView.heightAnchor.constraint(equalToConstant: view.frame.height / 3.5).isActive = true
        
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
