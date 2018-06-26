//
//  HistoryItem.swift
//  PizzaWallet
//
//  Created by Elina Talashka on 20/06/2018.
//  Copyright © 2018 Elina Talashka. All rights reserved.
//

import Foundation
import RealmSwift

class HistoryItem: Object {
    @objc dynamic var payer: String = ""
    @objc dynamic var singlePayment: Float = 0
    @objc dynamic var time: String = ""
}
