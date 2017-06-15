//
//  AsyncOperationModel.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/8/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import Foundation

class AsyncOperationModel:NSObject {
    
    var asyncToken:String?      = nil
    var urlVerification:URL?    = nil
    var dateVerification:Date?  = nil
    var asyncDelay:UInt?        = nil
    var id:UInt8?               = nil
    
    init(idOperation:UInt8 , asyncToken:String, dateVerification:Date?, asyncDelay:UInt, urlVerification:URL) {
        super.init()
        self.id                 = idOperation
        self.asyncToken         = asyncToken
        self.dateVerification   = dateVerification
        self.asyncDelay         = asyncDelay
        self.urlVerification    = urlVerification
    }
    
    init(asyncOperation:AsyncOperation){
        super.init()
        self.id                 = UInt8(asyncOperation.id)
        self.asyncToken         = asyncOperation.asyncToken
        self.dateVerification   = asyncOperation.dateVerification as Date?
        self.asyncDelay         = UInt(asyncOperation.asyncDelay)
        self.urlVerification    = URL.init(string:asyncOperation.urlVerification!)
    }
    
    override var description: String{
        return("id = \(String(describing: id!)) asyncDelay= \(String(describing: asyncDelay!)) dateVerification= \(String(describing: dateVerification!)) asyncToken= \(String(describing: asyncToken!))) urlVerification = \(String(describing: urlVerification?.absoluteString)))")
    }
}
