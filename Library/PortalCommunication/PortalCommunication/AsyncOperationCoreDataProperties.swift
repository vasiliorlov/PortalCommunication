//
//  AsyncOperationCoreDataProperties.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/13/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import Foundation
import CoreData


extension AsyncOperation {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AsyncOperation> {
        return NSFetchRequest<AsyncOperation>(entityName: "AsyncOperation")
    }
    
    @NSManaged public var asyncDelay        : Int64
    @NSManaged public var asyncToken        : String?
    @NSManaged public var urlVerification   : String?
    @NSManaged public var dateVerification  : NSDate?
    @NSManaged public var id                : Int16
    
}
