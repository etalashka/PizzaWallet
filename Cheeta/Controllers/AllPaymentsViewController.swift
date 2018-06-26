//
//  AllPaymentsViewController.swift
//  PizzaWallet
//
//  Created by Elina Talashka on 24/06/2018.
//  Copyright © 2018 Elina Talashka. All rights reserved.
//

import UIKit
import RealmSwift

class AllPaymentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    var members: Results<Member>?
    var payments: Results<HistoryItem>?

    @IBOutlet weak var mainTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib(nibName: "PaymentCell", bundle: nil) , forCellReuseIdentifier: "PaymentCell")
        
        mainTable.rowHeight = UITableViewAutomaticDimension
        mainTable.estimatedRowHeight = 60
        
        members = realm.objects(Member.self)
        payments = realm.objects(HistoryItem.self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (payments?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var names = [String?]()
        names = payments!.map({$0.payer})
        
        var amounts = [Float]()
        amounts = payments!.map({$0.singlePayment})
        
        var dates = [String]()
        dates = payments!.map({$0.time})
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        
        cell.namePayerCell.text = names[indexPath.row]
        cell.amountPayerCell.text = String(format: "%.2f", amounts[indexPath.row])
        cell.datePayerCell.text = dates[indexPath.row]
        
        return cell
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalIsDimissed"), object: nil)
        }
    }

    @IBAction func clearHistoryPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Удалить всю историю?", message: "Удалённые платежи невозможно будет восстановить. Все-таки удалить?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Да, удалить", style: .default) { (deleteAction) in
            for payment in self.payments! {
                do {
                    try self.realm.write {
                        self.realm.delete(payment)
                        self.mainTable.reloadData()
                    }
                } catch {
                    print("Error deleting all payments, \(error)")
                }
            }
            
            for member in self.members! {
                do {
                    try self.realm.write {
                        member.paidAmount = 0
                        member.debtAmount = 0
                    }
                } catch {
                    print("Error deleting all payments, \(error)")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { (cancelAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
}
