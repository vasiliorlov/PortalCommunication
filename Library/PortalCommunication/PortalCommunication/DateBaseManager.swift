//
//  DateBaseManager.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/5/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit
//import RealmSwift

class DateBaseManager: NSObject {
    
    static let sharedInstance = DateBaseManager()
    let coreManager = CoreDataManager.sharedInstance
    
    
    
    func save(model:AsyncOperationModel) {
        coreManager.saveContext(idOperation: model.id!, asyncToken: model.asyncToken!, dateChecked: model.dateChecked!, asyncDelay: model.asyncDelay!)
    }
    
    func read(idOperation:UInt8) -> AsyncOperationModel?{
        if let asyncOperation = coreManager.read(idOperation: idOperation) {
            return AsyncOperationModel(asyncOperation: asyncOperation)
        }
        return nil
    }
    
    func readAll()  -> [AsyncOperationModel]?{
        if let asyncOperations = coreManager.readAll() {
            var models:[AsyncOperationModel]?
            for asyncOperation in asyncOperations{
                let model = AsyncOperationModel(asyncOperation: asyncOperation)
                models?.append(model)
            }
            return models
        }
        return nil
    }
    
    func delete(idOperation:UInt8){
        coreManager.delete(idOperation: idOperation)
    }
    
    func delete(model:AsyncOperationModel){
        if  let idOperation = model.id{
            delete(idOperation: idOperation)
        }
    }
    
    func deleteAll(){
        coreManager.deleteAll()
    }
}
