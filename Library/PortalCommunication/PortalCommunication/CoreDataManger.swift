//
//  CoreDataManger.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/13/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    static let sharedInstance = CoreDataManager()
    
    lazy var applicationDocumentDirectory:URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var managedObjectModel:NSManagedObjectModel = {
        let bundleURL = Bundle.init(for: CoreDataManager.self).url(forResource: "PortalCommunication", withExtension: "bundle")!
        let frameworkBundle = Bundle.init(url: bundleURL)!
        let momURL = frameworkBundle.url(forResource: "AsyncOperation", withExtension: "momd")!
        
        
        return NSManagedObjectModel(contentsOf: momURL)!
    }()
    
    lazy var persistentStoreCoordinator:NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentDirectory.appendingPathComponent("AsyncOperation.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        }
        catch{
            fatalError("Error migrating store: \(error)")
        }
        return coordinator
    }()
    
    lazy var managedObjectContext:NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedContext.persistentStoreCoordinator = coordinator
        return managedContext
    }()
    
    //MARK: - Core Data Method
    
    func fetchRequest(withIdOperation:UInt8) -> NSFetchRequest<AsyncOperation> {
        let predicate                                   = NSPredicate(format: "id == %@", String(withIdOperation))
        let fetchRequest:NSFetchRequest<AsyncOperation> = AsyncOperation.fetchRequest()
        fetchRequest.predicate                          = predicate
        return fetchRequest
    }
    
    func saveContext(idOperation:UInt8 , asyncToken:String, dateVerification:Date, asyncDelay:UInt, urlVerification:URL){
        
        // if operation is exist then update else insert new entity
        let request = fetchRequest(withIdOperation: idOperation)
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(request)
            if let asyncOperation = fetchedEntities.first {
                asyncOperation.asyncToken           = asyncToken
                asyncOperation.dateVerification     = dateVerification as NSDate
                asyncOperation.asyncDelay           = Int64(asyncDelay)
                asyncOperation.urlVerification      = urlVerification.absoluteString
            } else {
                let newAsyncOperation               = NSEntityDescription.insertNewObject(forEntityName: "AsyncOperation", into: self.managedObjectContext) as! AsyncOperation
                newAsyncOperation.id                = Int16(idOperation)
                newAsyncOperation.asyncToken        = asyncToken
                newAsyncOperation.dateVerification  = dateVerification as NSDate
                newAsyncOperation.asyncDelay        = Int64(asyncDelay)
                newAsyncOperation.urlVerification   = urlVerification.absoluteString
            }
        } catch {
            fatalError("Failure to create context: \(error)")
        }
        
        saveContext()
    }
    
    func read(idOperation:UInt8) -> AsyncOperation?{
        let request = fetchRequest(withIdOperation: idOperation)
        
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(request)
            return fetchedEntities.first
        } catch {
            fatalError("Failure to read context: \(error)")
        }
    }
    
    func readAll() -> [AsyncOperation]?{
        let fetchRequest:NSFetchRequest<AsyncOperation> = AsyncOperation.fetchRequest()
        
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(fetchRequest)
            return fetchedEntities
        } catch {
            fatalError("Failure to read all context: \(error)")
        }
    }
    
    func delete(idOperation:UInt8){
        let request = fetchRequest(withIdOperation: idOperation)
        
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(request)
            if let entityToDelete = fetchedEntities.first {
                self.managedObjectContext.delete(entityToDelete)
            }
        } catch {
            fatalError("Failure to delete context: \(error)")
        }
        
        saveContext()
    }
    
    func deleteAll(){
        let fetchRequest:NSFetchRequest<AsyncOperation> = AsyncOperation.fetchRequest()
        
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(fetchRequest)
            for entity in fetchedEntities {
                self.managedObjectContext.delete(entity)
            }
        } catch {
            fatalError("Failure to delete context: \(error)")
        }
        
        saveContext()
    }
    
    func saveContext(){
        if managedObjectContext.hasChanges{
            do {
                try managedObjectContext.save()
            }
            catch{
                fatalError("Failure to save context: \(error)")
            }
        }
    }
}
