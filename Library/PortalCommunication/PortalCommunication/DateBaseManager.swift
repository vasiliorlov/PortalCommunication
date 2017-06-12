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
    static let sharedInstance = DateBaseManager()
    
    func initModel(idOperation:UInt8 , asyncToken:String, dateChecked:Date?, asyncDelay:UInt) -> AsyncOperationModel {
        let model = AsyncOperationModel()
        model.asyncToken = asyncToken
        model.dateChecked = dateChecked
        model.asyncDelay = Int(asyncDelay)
        model.id = Int(idOperation)
        
        return model
    }
    
    func save(model:AsyncOperationModel) {
        try! realm.write {
            realm.add(model, update: true)
        }
    }
    
    func read(idOperation:UInt8) -> AsyncOperationModel?{
        let asyncModel = realm.objects(AsyncOperationModel.self).filter("id == \(idOperation)").first
        return asyncModel
    }
    
    func readAll()  -> [AsyncOperationModel]?{
        let models = Array(realm.objects(AsyncOperationModel.self))
        return models.count>0 ? models : nil
    }
    
    func delete(idOperation:UInt8){
        
        if let asyncModel = realm.objects(AsyncOperationModel.self).filter("id == \(idOperation)").first {
            try! realm.write {
                realm.delete(asyncModel)
            }
        }
    }
    
    func delete(model:AsyncOperationModel){
        try! realm.write {
            realm.delete(model)
        }
    }
    
    func deleteAll(){
        try! realm.write {
            realm.deleteAll()
        }
    }
}
