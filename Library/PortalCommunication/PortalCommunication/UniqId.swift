//
//  UniqId.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 5/23/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit

enum UniqIdError:Error{
    case fullSetUniqId
}

class UniqId: NSObject {
    
    fileprivate var setUniqId:Set<UInt8> = []
    fileprivate let dataManager          = DateBaseManager.sharedInstance
    static let shared                    = UniqId()
    
    override init() {
        super.init()
        addUniqIdFromDb()
    }
    
   fileprivate func addUniqIdFromDb(){
        if let operations = dataManager.readAll(){
            for operation in operations{
                setUniqId.insert(operation.id!)
            }
        }
    }
    
    func getId() throws -> UInt8  {
        
        guard UInt8(setUniqId.count)  < UInt8.max else {
            throw UniqIdError.fullSetUniqId
        }
        
        var id:UInt8
        
        while (true)
        {
            id = UInt8(arc4random() % 255) 
            if !setUniqId.contains(id){
                setUniqId.insert(id)
                return id
            }
        }
    }
    
    func eraseId(uniqId:UInt8) -> Bool{
        
        guard setUniqId.contains(uniqId) else {
            return true
        }
        
        return setUniqId.remove(uniqId) != nil
    }
}
