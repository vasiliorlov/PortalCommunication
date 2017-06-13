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
        print(Bundle.main.bundleURL)
        let modelUrl = Bundle.main.url(forResource: "asyncOperation", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelUrl)!
    }()
    
    lazy var persistentStoreCoordinator:NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentDirectory.appendingPathComponent("asyncOperation.sqlite")
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
        var managedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedContext.persistentStoreCoordinator = coordinator
        return managedContext
    }()
    
    //MARK: - Core Data Method
    
    func saveContext(idOperation:UInt8 , asyncToken:String, dateChecked:Date, asyncDelay:UInt){
        
        // if operation is exist then update else insert new entity
        let predicate                                   = NSPredicate(format: "id == %@", idOperation)
        let fetchRequest:NSFetchRequest<AsyncOperation> = AsyncOperation.fetchRequest()
        fetchRequest.predicate                          = predicate
        
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(fetchRequest)
            if let asyncOperation = fetchedEntities.first {
                asyncOperation.asyncToken = asyncToken
                asyncOperation.dateChecked = dateChecked as NSDate
                asyncOperation.asyncDelay = Int64(asyncDelay)
            } else {
                let newAsyncOperation   = NSEntityDescription.insertNewObject(forEntityName: "AsyncOperation", into: self.managedObjectContext) as! AsyncOperation
                newAsyncOperation.id = Int16(idOperation)
                newAsyncOperation.asyncToken = asyncToken
                newAsyncOperation.dateChecked = dateChecked as NSDate
                newAsyncOperation.asyncDelay = Int64(asyncDelay)
            }
        } catch {
            fatalError("Failure to create context: \(error)")
        }
        
        saveContext()
    }
    
    func read(idOperation:UInt8) -> AsyncOperation?{
        let predicate                                   = NSPredicate(format: "id == %@", idOperation)
        let fetchRequest:NSFetchRequest<AsyncOperation> = AsyncOperation.fetchRequest()
        fetchRequest.predicate                          = predicate
        
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(fetchRequest)
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
        let predicate                                   = NSPredicate(format: "id == %@", idOperation)
        let fetchRequest:NSFetchRequest<AsyncOperation> = AsyncOperation.fetchRequest()
        fetchRequest.predicate                          = predicate
        
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(fetchRequest)
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
