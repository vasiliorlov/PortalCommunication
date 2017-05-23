//
//  RequestOperation.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 5/23/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit

public enum RequestOperationType {
    case login
    case getData
    case sendData
    case ping
}

public enum RequestOperationState{
    case ready
    case waiting(delayMs:UInt)
    case requestin(requestpath:String)
    case canceling
    case finished
    
}
class RequestOperation: Operation {
    var serviceRoot: String
    var type:RequestOperationType
    
    var serviceRootStatus:String?  {
        get{
          return ""
        }
        set{
            
        }
    }
    init(serviceRoot:String, type:RequestOperationType) {
        self.serviceRoot = serviceRoot
        self.type = type
        super.init()
    }
   /*
    override var isAsynchronous: Bool{
        return true
    }
*/
    
    func checkStatus(){
        
    }
}
