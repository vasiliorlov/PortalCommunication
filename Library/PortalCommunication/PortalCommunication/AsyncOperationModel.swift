//
//  AsyncOperationModel.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/8/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import Foundation

class AsyncOperationModel:NSObject {
    
    var asyncToken:String?  = nil
    var dateChecked:Date?   = nil
    var asyncDelay:UInt?    = nil
    var id:UInt8?           = nil
    
    init(idOperation:UInt8 , asyncToken:String, dateChecked:Date?, asyncDelay:UInt) {
        super.init()
        self.id            = idOperation
        self.asyncToken    = asyncToken
        self.dateChecked   = dateChecked
        self.asyncDelay    = asyncDelay
    }
    
    init(asyncOperation:AsyncOperation){
        super.init()
        self.id            = UInt8(asyncOperation.id)
        self.asyncToken    = asyncOperation.asyncToken
        self.dateChecked   = asyncOperation.dateChecked as Date?
        self.asyncDelay    = UInt(asyncOperation.asyncDelay)
    }
    
    override var description: String{
        return("id = \(String(describing: id!)) asyncDelay= \(String(describing: asyncDelay!)) dateCheked= \(String(describing: dateChecked!)) asyncToken= \(String(describing: asyncToken!))))")
    }
}
