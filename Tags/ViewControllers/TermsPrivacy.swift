//
//  TermsPrivacy.swift
//  ShoppingList
//
//  Created by Dmitry Veleskevich on 1/3/20.
//  Copyright © 2020 Dmitry Veleskevich. All rights reserved.
//

import UIKit
import WebKit

class TermsPrivacy: UIViewController {

    @IBOutlet var webView: WKWebView!
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var receivedString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(receivedString)

        let url = URL(string: receivedString)!
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }

}
