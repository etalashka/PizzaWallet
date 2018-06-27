//
//  ViewController.swift
//  PizzaWallet
//
//  Created by Elina Talashka on 20/06/2018.
//  Copyright © 2018 Elina Talashka. All rights reserved.
//

import UIKit
import RealmSwift

var generalSumm : Float = 0

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddSumViewControllerDelegate, MembersViewControllerDelegate {

    let realm = try! Realm()
    var members: Results<Member>?
    var payments: Results<HistoryItem>?
    
    @IBOutlet weak var genSummView: UIView!
    @IBOutlet weak var buttonAddSum: UIButton!
    @IBOutlet weak var generalSumLabel: UILabel!
    @IBOutlet weak var sumPerMember: UILabel!
    @IBOutlet weak var tableWithDebts: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.handleModalDismissed),
                                               name: NSNotification.Name(rawValue: "modalIsDimissed"),
                                               object: nil)
        
        members = realm.objects(Member.self)
        payments = realm.objects(HistoryItem.self)
        
        tableWithDebts.delegate = self
        tableWithDebts.dataSource = self
        tableWithDebts.register(UINib(nibName: "DebtsTableViewCell", bundle: nil) , forCellReuseIdentifier: "DebtCustomCell")
        
        tableWithDebts.rowHeight = UITableViewAutomaticDimension
        tableWithDebts.estimatedRowHeight = 52
        
        makeRoundedCorners()
        updateLabels()
    }
    
    @objc func handleModalDismissed() {
        updateLabels()
        tableWithDebts.reloadData()
    }
    
    //MARK - checking number of members after the view was loaded ----------------------------------------
    
    override func viewDidAppear(_ animated: Bool) {
        if members!.count == 1 {
            performSegue(withIdentifier: "ShowMembersModal", sender: self)
            overlayBlurredBackgroundView()
        }
    }

    //MARK - Blur out background ----------------------------------------
    
    func overlayBlurredBackgroundView() {
        
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        
        view.addSubview(blurredBackgroundView)
        
    }
    
    func removeBlurredBackgroundView() {
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        self.overlayBlurredBackgroundView()
    }
    
    @IBAction func addMemberPressed(_ sender: UIButton) {
        self.overlayBlurredBackgroundView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ShowAddModalView" || identifier == "ShowMembersModal" {
                if let viewController = segue.destination as? AddSumViewController {
                    viewController.delegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                } else if let viewController = segue.destination as? MembersViewController {
                    viewController.delegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                }
            }
        }
    }
    
    //MARK - UI changes ------------------------------------------
    
    func makeRoundedCorners() {
        genSummView.layer.cornerRadius = 15
        genSummView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    //MARK - update UI with data from DB -----------------------------------
    
    func updateLabels() {
        var allItems = [Float]()
        allItems = payments!.map({$0.singlePayment})
        let numberOfMembers = Float((members?.count)!)
        
        generalSumm = allItems.reduce(0, +)
        generalSumLabel.text = String(format: "%.2f", generalSumm)
        
        if numberOfMembers > 0 {
            sumPerMember.text = String(format: "%.2f", generalSumm / numberOfMembers)
        } else {
            sumPerMember.text = "0.00"
        }
    }

    //MARK - TableView methods and updating --------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (members?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var membersList = [String?]()
        membersList = members!.map({$0.name})
        
        var debts = [Float]()
        debts = members!.map({$0.debtAmount})
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DebtCustomCell", for: indexPath) as! DebtsTableViewCell
        
        cell.memberLabelInCell.text = membersList[indexPath.row]
        cell.debtAmountInCell.text = String(format: "%.2f", debts[indexPath.row])
        
        let text = (cell.debtAmountInCell.text! as NSString).floatValue
        if text < 0 {
            cell.debtAmountInCell.textColor = UIColor(red:0.92, green:0.47, blue:0.60, alpha:1.0)
        } else {
            cell.debtAmountInCell.textColor = UIColor(red:0.34, green:0.86, blue:0.75, alpha:1.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action =  UIContextualAction(style: .normal, title: "Удалить", handler: { (action,view,completionHandler ) in

            completionHandler(true)

            let alert = UIAlertController(title: "Удалить участника?", message: "После удаления участника общая сумма будет разделена между оставшимися участниками. Все-таки удалить?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Да, удалить", style: .default) { (deleteAction) in
                //add deleting member here
                if let member = self.members?[indexPath.row] {
                    do {
                        try self.realm.write {
                            self.realm.delete(member)
                        }
                    } catch {
                        print("Error deleting Item, \(error)")
                    }
                }
                
                let averageDebt = generalSumm / Float((self.members?.count)!)
                
                var paids = [Float]()
                paids = self.members!.map({$0.paidAmount})
                
                for i in 0..<(self.members?.count)! {
                    paids[i] = paids[i] - averageDebt
                    do {
                        try self.realm.write {
                            self.members![i].debtAmount = paids[i]
                        }
                    } catch {
                        print("Error saving debtAmount for all members \(error)")
                    }
                }
                self.tableWithDebts.reloadData()
                self.updateLabels()
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .default) { (cancelAction) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        })
        
        action.image = UIImage(named: "delete-icon")
        action.backgroundColor = UIColor(red:0.98, green:0.16, blue:0.24, alpha:1.0)
        let confrigation = UISwipeActionsConfiguration(actions: [action])

        return confrigation
    }
    
}
