//
//  AddSumViewController.swift
//  PizzaWallet
//
//  Created by Elina Talashka on 21/06/2018.
//  Copyright © 2018 Elina Talashka. All rights reserved.
//

import UIKit
import RealmSwift

protocol AddSumViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}

class AddSumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    weak var delegate: AddSumViewControllerDelegate?
    
    let realm = try! Realm()
    var members: Results<Member>?
    var payments: Results<HistoryItem>?
    var payer = ""
    var paidSum : Float = 0
    
    @IBOutlet weak var mainBG: UIView!
    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var tablePayrs: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var payerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        members = realm.objects(Member.self)
        payments = realm.objects(HistoryItem.self)
        
        tablePayrs.delegate = self
        tablePayrs.dataSource = self
        sumTextField.delegate = self
        
        tablePayrs.register(UINib(nibName: "SelectMemberCell", bundle: nil) , forCellReuseIdentifier: "SelectMemberCell")
        tablePayrs.rowHeight = UITableViewAutomaticDimension
        tablePayrs.estimatedRowHeight = 60
        
        makeRoundedCorners()
        makeSumFieldActive()
        setPayerButtonStyle()
        tablePayrs.reloadData()
    }
    
    //MARK - General UI view changes ----------------------------------
    
    func makeRoundedCorners() {
        mainBG.layer.cornerRadius = 15
        mainBG.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    }
    
    //MARK - TextField style and actions ----------------------------------
    
    func makeSumFieldActive() {
        sumTextField.becomeFirstResponder()

        sumTextField.layer.borderWidth = 1.5
        sumTextField.layer.borderColor = UIColor.white.cgColor
        sumTextField.backgroundColor = UIColor.clear
        
        sumTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: sumTextField.frame.height))
        sumTextField.leftViewMode = .always
    }
    
    func makeSumFieldInactive() {
        sumTextField.resignFirstResponder()
        
        sumTextField.layer.borderColor = UIColor.clear.cgColor
        sumTextField.backgroundColor = UIColor(white: 1, alpha: 0.2)
        
        sumTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: sumTextField.frame.height))
        sumTextField.leftViewMode = .always
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        makeSumFieldActive()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if sumTextField.text?.isEmpty == true {
            if saveButton.isHidden == false {
                saveButton.isHidden = !saveButton.isHidden
            }
            makeSumFieldInactive()
        } else {
            if saveButton.isHidden == true && payer.isEmpty == true {
                makeSumFieldInactive()
            } else if saveButton.isHidden == true && payer.isEmpty == false {
                saveButton.isHidden = !saveButton.isHidden
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        makeSumFieldInactive()
    }
    
    @IBAction func editSumField(_ sender: UITextField) {
        makeSumFieldActive()
        if tablePayrs.isHidden == false {
            tablePayrs.isHidden = !tablePayrs.isHidden
        }
    }
    
    //method to prevent entering two decimals:
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let newString = (sumTextField.text! as NSString).replacingCharacters(in: range, with: string)
        let arrayOfString = newString.components(separatedBy: ".")
        
        if arrayOfString.count > 2 {
            return false
        }
        return true
    }
    
    //MARK - UI of the button (concider creating UI classes and default styles ----------------------------------

    func setPayerButtonStyle() {
        payerButton.layer.backgroundColor = UIColor(white: 1, alpha: 0.2).cgColor
    }

    
    //MARK - Table view: select payer in the dropdown set up ----------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let names = Array(members!)
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let names = Array(members!)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberCell", for: indexPath) as! SelectMemberCell
        
        cell.payerInCell.text = names[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let names = Array(members!)
        
        payer = names[indexPath.row].name
        payerButton.titleLabel?.text = names[indexPath.row].name
        tablePayrs.isHidden = !tablePayrs.isHidden
        
        if sumTextField.text?.isEmpty == true {
            makeSumFieldActive()
        }else{
            if saveButton.isHidden == true {
                saveButton.isHidden = !saveButton.isHidden
            }
        }
    }
    
    
    //MARK - Save and edit values, create new items in DB ----------------------------------

    @IBAction func saveSumPressed(_ sender: UIButton) {
        paidSum = Float(sumTextField.text!)!
        
        createNewItem()
        calculateMemberPaid()

        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalIsDimissed"), object: nil)
        }
        delegate?.removeBlurredBackgroundView()
    }
    
    func createNewItem() {
        
        // get local date amd time
        let date = Date()
        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = NSTimeZone() as TimeZone?
        
        let localDate = dateFormatter.string(from: date)
        
        do {
            try self.realm.write {
                let newItem = HistoryItem()
                newItem.payer = payer
                newItem.time = "\(localDate)"
                newItem.singlePayment = Float(sumTextField.text!)!
                
                realm.add(newItem)
            }
        } catch {
            print("Error saving new items, \(error)")
        }

        updateGenSum()
    }
    
    func updateGenSum()  {
        var allItems = [Float]()
        allItems = payments!.map({$0.singlePayment})
        generalSumm = allItems.reduce(0, +)
    }
    
    func calculateMemberPaid() {
        let memberPaid = members?.filter("name CONTAINS[cd] %@", payer)
        
        do {
            try realm.write {
                memberPaid?[0].paidAmount = (memberPaid?[0].paidAmount)! + paidSum
            }
        } catch {
            print("Error saving paidAmount for selected member")
        }
        
        calculateDebts()
    }
    
    func calculateDebts() {
        let averageDebt = generalSumm / Float((members?.count)!)
        
        var paids = [Float]()
        paids = members!.map({$0.paidAmount})

        for i in 0..<(members?.count)! {
            paids[i] = paids[i] - averageDebt
            do {
                try realm.write {
                    members![i].debtAmount = paids[i]
                }
            } catch {
                print("Error saving debtAmount for selected member")
            }
        }
    }
    
    @IBAction func selectPayerPressed(_ sender: UIButton) {
        makeSumFieldInactive()
        tablePayrs.isHidden = !tablePayrs.isHidden
        if saveButton.isHidden == false {
            saveButton.isHidden = !saveButton.isHidden
        }
    }
    
    @IBAction func closeTheView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
}
