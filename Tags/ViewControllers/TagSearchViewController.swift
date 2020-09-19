//
//  ViewController.swift
//  H#
//
//  Created by Dzmitry Veliaskevich on 12.03.20.
//  Copyright © 2020 Dzmitry Veliaskevich. All rights reserved.
//

import UIKit

class TagSearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tagSearchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var bulletSwitch: UISwitch!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        self.tagSearchTextField.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
    }
    
    @objc func tapDone(sender: Any) {
        self.view.endEditing(true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tagSearchTextField.becomeFirstResponder()
        setObservers()
        
        if UserDefaults.standard.bool(forKey: "bullet") == true {
            bulletSwitch.setOn(true, animated: false)
        } else {
            bulletSwitch.setOn(false, animated: false)
        }
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "bullet")
        } else {
            UserDefaults.standard.set(false, forKey: "bullet")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func didClickSearchButton(_ sender: Any) {
        search()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return false
    }
    
    private func search() {
        guard tagSearchTextField.text != nil, tagSearchTextField.text! != "" else {
            print("Text field is blank")
            return
        }
        
        performSegue(withIdentifier: "ShowTagResults", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if tagSearchTextField.isFirstResponder {
            tagSearchTextField.resignFirstResponder()
        }

        if segue.identifier == "ShowTagResults" {
            guard let destination = segue.destination as? TagResultsViewController else {
                print("Bad segue destination: TagResultsViewController")
                return
            }
            
            let tagsString = tagSearchTextField.text?.replacingOccurrences(of: " ", with: "-")
            destination.unsafeTag = tagsString
            destination.shouldShowBullets = bulletSwitch.isOn
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
    }
}


// MARK: - Handle Keyboard
extension TagSearchViewController {
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(TagSearchViewController.keyboardWillShowNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TagSearchViewController.keyboardWillShowNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    @objc func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions.init(rawValue: UInt(rawAnimationCurve))
        bottomLayoutConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
