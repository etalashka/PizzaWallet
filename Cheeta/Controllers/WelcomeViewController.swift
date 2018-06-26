//
//  WelcomeViewController.swift
//  PizzaWallet
//
//  Created by Elina Talashka on 23/06/2018.
//  Copyright © 2018 Elina Talashka. All rights reserved.
//

import UIKit
import RealmSwift

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    

    let realm = try! Realm()
    var members: Results<Member>?
    var arrayForTable : [String] = [""]
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var okButtonYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        nameField.delegate = self

        members = realm.objects(Member.self)
        
        makeFieldActive()
    }
    
    // method to get height of keyboard before it's shown -----
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight : Int = Int(keyboardSize.height)
            print("keyboardHeight",keyboardHeight)
            okButtonYConstraint.constant = CGFloat(keyboardHeight + 20)
        }
    }
    
    func makeFieldActive() {
        nameField.becomeFirstResponder()

        nameField.layer.borderWidth = 1.5
        nameField.layer.borderColor = UIColor.white.cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        okButton.isHidden = false
        
        return true
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        do {
            try self.realm.write {
                let newMember = Member()
                newMember.name = nameField.text!
                
                realm.add(newMember)
            }
        } catch {
            print("Error saving new items, \(error)")
        }
    }

    @IBAction func validateNumberOfCharacters(_ sender: UITextField) {
        if (self.nameField.text?.count)! > 1 {
            okButton.isHidden = false
        }
    }
    
}
