//
//  Data.swift
//  PizzaWallet
//
//  Created by Elina Talashka on 20/06/2018.
//  Copyright © 2018 Elina Talashka. All rights reserved.
//

import Foundation
import RealmSwift

class Member: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var paidAmount: Float = 0
    @objc dynamic var debtAmount: Float = 0
}
