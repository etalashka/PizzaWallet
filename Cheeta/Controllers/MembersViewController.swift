//
//  MembersViewController.swift
//  PizzaWallet
//
//  Created by Elina Talashka on 24/06/2018.
//  Copyright © 2018 Elina Talashka. All rights reserved.
//

import UIKit
import RealmSwift

protocol MembersViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}

class MembersViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: MembersViewControllerDelegate?
    
    let realm = try! Realm()
    var members: Results<Member>?
    var payments: Results<HistoryItem>?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var errorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        members = realm.objects(Member.self)
        payments = realm.objects(HistoryItem.self)

        makeRoundedCorners()
        makeSumFieldActive()
    }

    //MARK - General UI view changes ----------------------------------
    
    func makeRoundedCorners() {
        bgView.layer.cornerRadius = 15
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    }
    
    //MARK - TextField style and actions ----------------------------------
    
    func makeSumFieldActive() {
        nameTextField.becomeFirstResponder()
        
        nameTextField.layer.borderWidth = 1.5
        nameTextField.layer.borderColor = UIColor.white.cgColor
        nameTextField.backgroundColor = UIColor.clear
        
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: nameTextField.frame.height))
        nameTextField.leftViewMode = .always
        
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    @IBAction func countCharacters(_ sender: UITextField) {
        if (self.nameTextField.text?.count)! > 1 {
            saveButton.isHidden = false
            
            if errorText.isHidden == false {
                errorText.isHidden = true
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        var filteredMembers = [String]()
        filteredMembers = members!.map({$0.name})
        
        if filteredMembers.contains(nameTextField.text!) {
            errorText.isHidden = false
            
        } else {
            
            var allItems = [Float]()
            allItems = payments!.map({$0.singlePayment})
            let numberOfMembers = Float((members?.count)!)
        
            generalSumm = allItems.reduce(0, +)
            var paids = [Float]()
            paids = members!.map({$0.paidAmount})
            
            do {
                try self.realm.write {
                    let member = Member()
                    member.name = nameTextField.text!
                    member.paidAmount = 0
                    member.debtAmount = 0 - (generalSumm / Float(numberOfMembers + 1))
                    
                    realm.add(member)
                }
            } catch {
                print("Error saving new Member, \(error)")
            }
            
            for i in 0..<((members?.count)! - 1) {
                paids[i] = paids[i] - (generalSumm / Float(numberOfMembers + 1))
                do {
                    try realm.write {
                        members![i].debtAmount = paids[i]
                    }
                } catch {
                    print("Error saving debtAmount for all members \(error)")
                }
            }
            
            dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalIsDimissed"), object: nil)
            }
            
            delegate?.removeBlurredBackgroundView()
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
    }
    
    
}
