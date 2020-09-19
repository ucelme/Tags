//
//  BuyScreen.swift
//  ShoppingList
//
//  Created by Dmitry Veleskevich on 1/3/20.
//  Copyright © 2020 Dmitry Veleskevich. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import DTGradientButton

class BuyScreen: UIViewController {
    
    @IBOutlet var freeTrial: UIButton!

    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
        
    @IBAction func freeTrial(_ sender: UIButton) {
        SwiftyStoreKit.purchaseProduct(AppInfo.oneTime, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: "purchased")
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }

    }
    
    @IBAction func restorePurchases(_ sender: UIButton) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                UserDefaults.standard.set(true, forKey: "purchased")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
                        
        freeTrial.setGradientBackgroundColors([UIColor(hex: "E21F70"), UIColor(hex: "FF4D2C")], direction: DTImageGradientDirection.toRight, for: UIControl.State.normal)
        freeTrial.layer.cornerRadius = freeTrial.frame.height/2
        freeTrial.layer.masksToBounds = true

                
        SwiftyStoreKit.retrieveProductsInfo([AppInfo.oneTime]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
                self.freeTrial.setTitle("\(priceString) one time", for: .normal)
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "Terms" {
    let controller = segue.destination as! TermsPrivacy
    controller.receivedString = "https://veleskevich.com/terms-of-use/"
    } else if segue.identifier == "Privacy" {
    let controller = segue.destination as! TermsPrivacy
    controller.receivedString = "https://veleskevich.com/privacy-policy/"
        }
    }

}
