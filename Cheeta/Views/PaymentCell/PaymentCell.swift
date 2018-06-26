//
//  PaymentCell.swift
//  PizzaWallet
//
//  Created by Elina Talashka on 24/06/2018.
//  Copyright © 2018 Elina Talashka. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {

    @IBOutlet weak var namePayerCell: UILabel!
    @IBOutlet weak var amountPayerCell: UILabel!
    @IBOutlet weak var datePayerCell: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
