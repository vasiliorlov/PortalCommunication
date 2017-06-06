//
//  AsyncOperation+CoreDataProperties.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/5/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import Foundation
import CoreData


extension AsyncOperation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AsyncOperation> {
        return NSFetchRequest<AsyncOperation>(entityName: "AsyncOperation")
    }

    @NSManaged public var asyncToken: String?
    @NSManaged public var dateChecked: NSDate?
    @NSManaged public var idOperation: Int16

}
