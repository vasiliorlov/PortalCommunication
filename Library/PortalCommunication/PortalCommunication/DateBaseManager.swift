//
//  DateBaseManager.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/5/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit
import RealmSwift

class DateBaseManager: NSObject {
    let realm = try! Realm()
    
    func initModel(asyncToken:String, dateChecked:Date?, asyncDelay:Int, idOperation:Int8 ) -> AsyncOperationModel {
        let model = AsyncOperationModel()
        model.asyncToken = asyncToken
        model.dateChecked = dateChecked
        model.asyncDelay = asyncDelay
        model.id = Int(idOperation)
        
        return model
    }
    
    func save(model:AsyncOperationModel) {
        try! realm.write {
            realm.add(model, update: true)
        }
    }
    
    func readAll()  -> [AsyncOperationModel]?{
        let models = Array(realm.objects(AsyncOperationModel.self))
        return models.count>0 ? models : nil
    }
    
}
