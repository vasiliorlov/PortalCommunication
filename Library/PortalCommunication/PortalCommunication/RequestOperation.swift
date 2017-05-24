//
//  RequestOperation.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 5/23/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit
import Alamofire

public enum RequestOperationType {
    case login
    case getData
    case sendData
    case ping
}

public enum RequestOperationState {
    case ready
    case waiting(delayMs:UInt)
    case requesting(requestpath:String)
    case checkingStatus
    case canceling
    case finished
}


struct ResponseAsync {
    var asyncToken:     String
    var asyncDelay:     UInt
}

class RequestOperation: Operation {
    let serviceRoot :URL
    let type        :RequestOperationType
    var state       :RequestOperationState
    
    var serviceRootForStatus:URL {
        return serviceRoot.appendingPathComponent("Status")
    }
    
    init(serviceRoot:URL, type:RequestOperationType) {
        self.serviceRoot    = serviceRoot
        self.type           = type
        self.state          = .ready
        super.init()
    }
    
    /*
     override var isAsynchronous: Bool{
     return true
     }
     */
    
    func getResponseAfterCheckedStatus(asyncResponce:ResponseAsync, onSuccess:@escaping (_ responseDict:[String:Any]) -> (), onError:@escaping ( _ error:Error) -> ()){
        
        let delay = asyncResponce.asyncDelay
        self.state = .waiting(delayMs: delay)
        sleep(UInt32(delay / 1000))
        self.state = .checkingStatus
        
        let param:Parameters = ["asyncToken":asyncResponce.asyncToken]
        
        Alamofire.request(serviceRootForStatus, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).validate().responseJSON { [unowned self]  response in
            switch response.result {
                
            case .success(let JSON):
                if let responseDict = JSON as? [String:Any]{
                    if (responseDict["is_async"] as? Bool) != nil {//async
                        if let delay = responseDict["async_delay"] as? UInt{
                            if let token = responseDict["async_token"] as? String{
                                let asyncResponse = ResponseAsync(asyncToken: token , asyncDelay: delay )
                                self.getResponseAfterCheckedStatus(asyncResponce: asyncResponse , onSuccess: onSuccess, onError: onError)
                            }else{
                                let error = NSError(domain: "Async response doesn't have async_token value ", code: 10004, userInfo: nil)
                                onError(error)
                            }
                        }else{
                            let error = NSError(domain: "Async response doesn't have delay value ", code: 10003, userInfo: nil)
                            onError(error)
                        }
                    } else {//sync
                        if let dataDic:[String:Any] = responseDict["data"] as? [String : Any] {
                            onSuccess(dataDic)
                        } else{
                            let error = NSError(domain: "Sync response doesn't have data value", code: 10002, userInfo: nil)
                            onError(error)
                        }
                    }
                } else {
                    let error = NSError(domain: "Response Status is not Dict[String:Any]", code: 10001, userInfo: nil)
                    onError(error)
                }
                
            case .failure(let error):
                print(error)
                onError(error)
            }
        }
    }

    
}
