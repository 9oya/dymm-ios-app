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
    var topBarView: UIView!
    var descScrollView: UIScrollView!
    
    // UIButton
    var purchaseBtn: UIButton!
    var restoreBtn: UIButton!
    var privacyPolicyLink: UIButton!
    var termsLink: UIButton!
    
    // UILabel
    var eventLabel: UILabel!
    var productPriceDscLabel: UILabel!
    var productDsc1Label: UILabel!
    var productDsc2Label: UILabel!
    var purchaseComplLabel: UILabel!
    
    // UIImageView
    var logoImageView: UIImageView!
    var bgImgView: UIImageView!
    
    // Non-view properties
    var PRODUCT_ID = "dymm_premium_plan1"
    var SHARED_SECRET = "6be41dc52be84d78ba58cf74d3b13af0"
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        if UserDefaults.standard.isPurchased() {
            purchaseComplLabel.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.productPriceDscLabel.textColor = .gray
                self.productDsc1Label.textColor = .gray
            }
            purchaseBtn.isHidden = true
            restoreBtn.isHidden = true
            eventLabel.isHidden = true
            fetchAvailableProducts()
        } else{
            /* Product is not purchased */
            purchaseComplLabel.isHidden = true
            fetchAvailableProducts()
        }
    }
    
    // MARK - Actions
    
    @objc func alertCompl(_ title: String, _ message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleDone, style: .default) { _ in }
        alert.addAction(confirmAction)
        alert.view.tintColor = .purple_DB8BFF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func purchaseButtonTapped() {
        purchaseProduct(product: iapProducts[0])
    }
    
    @objc func restoreButtonTapped() {
        view.showSpinner()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @objc func privacyPolicyTapped() {
        var url = "https://www.dymm.io/privacy/en"
        switch lang.currentLanguageId {
        case LanguageId.eng: url = "https://www.dymm.io/privacy/en"
        case LanguageId.kor: url = "https://www.dymm.io/privacy/ko"
        default: fatalError() }
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func termsTapped() {
        var url = "https://www.dymm.io/terms/en"
        switch lang.currentLanguageId {
        case LanguageId.eng: url = "https://www.dymm.io/terms/en"
        case LanguageId.kor: url = "https://www.dymm.io/terms/ko"
        default: fatalError() }
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
}

extension IAPController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        view.hideSpinner()
        UserDefaults.standard.setIsPurchased(value: true)
        purchaseComplLabel.text = lang.msgPremiumRestored
        productDsc2Label.text = self.lang.msgProductDesc2_2
        purchaseComplLabel.isHidden = false
        eventLabel.isHidden = true
        purchaseBtn.isHidden = true
        restoreBtn.isHidden = true
        alertCompl(lang.titleRestoreCompl, lang.msgRestoreCompl)
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
            if UserDefaults.standard.isPurchased() {
                DispatchQueue.main.async {
                    self.purchaseComplLabel.text = self.lang.titlePremiumMemberShip
                    self.productPriceDscLabel.text = "\(price!) / \(purchasingProduct.localizedDescription)"
                    self.productDsc1Label.text = self.lang.msgProductDesc1
                    self.privacyPolicyLink.setTitle(self.lang.titlePrivaryPolocy, for: .normal)
                    self.termsLink.setTitle(self.lang.titleTerms, for: .normal)
                    self.productDsc2Label.text = self.lang.msgProductDesc2_2
                    self.view.hideSpinner()
                }
            } else {
                // Show description
                DispatchQueue.main.async {
                    self.eventLabel.text = self.lang.msgPriceDesc
                    self.purchaseBtn.setTitle(purchasingProduct.localizedTitle.uppercased(), for: .normal)
                    self.productPriceDscLabel.text = "\(price!) / \(purchasingProduct.localizedDescription)"
                    self.productDsc1Label.text = self.lang.msgProductDesc1
                    self.privacyPolicyLink.setTitle(self.lang.titlePrivaryPolocy, for: .normal)
                    self.termsLink.setTitle(self.lang.titleTerms, for: .normal)
                    self.productDsc2Label.text = self.lang.msgProductDesc2_1
                    self.view.hideSpinner()
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    view.hideSpinner()
                    if let paymentTransaction = transaction as? SKPaymentTransaction {
                        SKPaymentQueue.default().finishTransaction(paymentTransaction)
                    }
                    if productID == PRODUCT_ID {
                        UserDefaults.standard.setIsPurchased(value: true)
                        purchaseComplLabel.text = lang.msgProductPurchased
                        purchaseComplLabel.isHidden = false
                        purchaseBtn.isHidden = true
                        restoreBtn.isHidden = true
                        alertCompl(lang.titlePurchaseCompl, lang.msgPurchaseCompl)
                    }
                case .failed:
                    view.hideSpinner()
                    if trans.error != nil {
                        alertCompl(lang.titlePurchaseFail, trans.error!.localizedDescription)
                        print(trans.error!)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                case .restored:
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
//        view.backgroundColor = UIColor(hex: "#ACF6D1")
        view.backgroundColor = .clear
        
        topBarView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        logoImageView = {
            let _imageView = UIImageView()
            _imageView.image = .itemLogoMPurple
            _imageView.contentMode = .scaleAspectFit
            _imageView.clipsToBounds = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        bgImgView = {
            let _imageView = UIImageView()
            _imageView.image = .itemBgIap
            _imageView.contentMode = .scaleToFill
            _imageView.clipsToBounds = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        eventLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15, weight: .medium)
            _label.textColor = .purple_921BEA
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        purchaseBtn = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(UIColor(hex: "#ACF6D1"), for: .normal)
            _button.backgroundColor = .purple_921BEA
            _button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            _button.layer.cornerRadius = 10.0
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
            _button.addShadowView()
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        productPriceDscLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15, weight: .regular)
            _label.textColor = .purple_921BEA
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        descScrollView = {
            let _scrollView = UIScrollView()
            _scrollView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            _scrollView.translatesAutoresizingMaskIntoConstraints = false
            return _scrollView
        }()
        productDsc1Label = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 12, weight: .regular)
            _label.textColor = .gray
            _label.textAlignment = .center
            _label.numberOfLines = 10
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        productDsc2Label = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 12, weight: .regular)
            _label.textColor = .purple_7671FF
            _label.textAlignment = .center
            _label.numberOfLines = 10
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        restoreBtn = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.purple_7671FF, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
            _button.setTitle(lang.titleRestoreProduct, for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        purchaseComplLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 18, weight: .bold)
            _label.textColor = .purple_921BEA
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        privacyPolicyLink = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.dodgerBlue, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 12)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        termsLink = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.dodgerBlue, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 12)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        
        
        view.addSubview(bgImgView)
        view.addSubview(logoImageView)
        view.addSubview(purchaseBtn)
        view.addSubview(productPriceDscLabel)
        view.addSubview(eventLabel)
        view.addSubview(purchaseComplLabel)
        view.addSubview(topBarView)
        view.addSubview(descScrollView)
        
        topBarView.addSubview(restoreBtn)
        
        descScrollView.addSubview(productDsc1Label)
        descScrollView.addSubview(productDsc2Label)
        descScrollView.addSubview(privacyPolicyLink)
        descScrollView.addSubview(termsLink)
        
        
        bgImgView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        bgImgView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        bgImgView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        bgImgView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        topBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        topBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        topBarView.heightAnchor.constraint(equalToConstant: CGFloat(topBarHeightInt)).isActive = true
        
        restoreBtn.topAnchor.constraint(equalTo: topBarView.topAnchor, constant: 0).isActive = true
        restoreBtn.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -20).isActive = true
        restoreBtn.bottomAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 0).isActive = true
        
        logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: purchaseBtn.topAnchor, constant: -40).isActive = true
        
        purchaseBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        purchaseBtn.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -20).isActive = true
        purchaseBtn.widthAnchor.constraint(equalToConstant: 250).isActive = true
        purchaseBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        eventLabel.bottomAnchor.constraint(equalTo: purchaseBtn.topAnchor, constant: -5).isActive = true
        eventLabel.trailingAnchor.constraint(equalTo: purchaseBtn.trailingAnchor, constant: 0).isActive = true
        
        productPriceDscLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        productPriceDscLabel.topAnchor.constraint(equalTo: purchaseBtn.bottomAnchor, constant: 10).isActive = true
        
        descScrollView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        descScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        descScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        descScrollView.topAnchor.constraint(equalTo: productPriceDscLabel.bottomAnchor, constant: 25).isActive = true
        descScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -7).isActive = true
        
        productDsc1Label.topAnchor.constraint(equalTo: descScrollView.topAnchor, constant: 15).isActive = true
        productDsc1Label.centerXAnchor.constraint(equalTo: descScrollView.centerXAnchor, constant: 0).isActive = true
        productDsc1Label.leadingAnchor.constraint(equalTo: descScrollView.leadingAnchor, constant: 7).isActive = true
        productDsc1Label.trailingAnchor.constraint(equalTo: descScrollView.trailingAnchor, constant: -7).isActive = true
        
        privacyPolicyLink.topAnchor.constraint(equalTo: productDsc1Label.bottomAnchor, constant: 1).isActive = true
        privacyPolicyLink.trailingAnchor.constraint(equalTo: termsLink.leadingAnchor, constant: -7).isActive = true
        
        termsLink.topAnchor.constraint(equalTo: productDsc1Label.bottomAnchor, constant: 1).isActive = true
        termsLink.trailingAnchor.constraint(equalTo: descScrollView.trailingAnchor, constant: -25).isActive = true
        
        productDsc2Label.topAnchor.constraint(equalTo: privacyPolicyLink.bottomAnchor, constant: 25).isActive = true
        productDsc2Label.centerXAnchor.constraint(equalTo: descScrollView.centerXAnchor, constant: 0).isActive = true
        productDsc2Label.leadingAnchor.constraint(equalTo: descScrollView.leadingAnchor, constant: 10).isActive = true
        productDsc2Label.trailingAnchor.constraint(equalTo: descScrollView.trailingAnchor, constant: -10).isActive = true
        productDsc2Label.bottomAnchor.constraint(equalTo: descScrollView.bottomAnchor, constant: -10).isActive = true
        
        purchaseComplLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        purchaseComplLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -30).isActive = true
        
        view.showSpinner()
    }
    
    private func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            view.showSpinner()
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
        } else {
            // IAP Purchases disabled on the Device
            alertCompl(lang.titlePurchaseDisable, lang.msgPurchaseDisable)
        }
    }
    
    private func fetchAvailableProducts() {
        let productIdentifiers = NSSet(objects:
            PRODUCT_ID
        )
        guard let identifier = productIdentifiers as? Set<String> else { return }
        productsRequest.cancel()
        productsRequest = SKProductsRequest(productIdentifiers: identifier)
        productsRequest.delegate = self
        productsRequest.start()
    }
}
