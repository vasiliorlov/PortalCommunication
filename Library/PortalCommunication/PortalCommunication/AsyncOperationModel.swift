//
//  AsyncOperationModel.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/8/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import Foundation
import RealmSwift

class AsyncOperationModel:Object {
  
    dynamic var asyncToken          = ""
    dynamic var dateChecked:Date?   = nil
    dynamic var asyncDelay          = 0
    dynamic var id                  = -1
    override static func primaryKey() -> String? {
        return "id"
    }
}
