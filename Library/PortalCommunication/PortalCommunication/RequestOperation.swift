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
    case data
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
    let serviceRoot     :URL
    let type            :RequestOperationType
    var state           :RequestOperationState
    var uniqId          :UInt8
    var serviceRootForStatus:URL {
        return serviceRoot.appendingPathComponent(MethodNameConstans.status)
    }
    
    init(serviceRoot:URL, type:RequestOperationType) {
        self.serviceRoot    = serviceRoot
        self.type           = type
        self.state          = .ready
        do{
            self.uniqId     = try UniqId.shared.getId()
            print("Generate new uniq id = \(self.uniqId)")
        } catch {
            self.uniqId     = 0
            assert(false, "Full set uniq Id")
        }
        super.init()
        
    }
    
    
    override var isAsynchronous: Bool{
        return true
    }
    
    //MARK: - override operation method
    
    //MARK: - custom method
    func getResponseAfterCheckedStatus(asyncResponce:ResponseAsync, callBack: OperationCallBack, onLoginExpired:@escaping () -> ()){
        
        let delay = asyncResponce.asyncDelay
        self.state = .waiting(delayMs: delay)
        sleep(UInt32(delay / 1000))
        self.state = .checkingStatus
        
        let param:Parameters = ["asyncToken":asyncResponce.asyncToken]
        
        Alamofire.request(serviceRootForStatus, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).validate().responseJSON { [unowned self]  response in
            switch response.result {
                
            case .success(let JSON):
                
                if let responseDict = JSON as? [String:Any]{
                    
                    guard responseDict["is_success"] as! Bool   else {
                        let error = NSError(domain: "Service returns incorrct response", code: 10007, userInfo: nil)
                        callBack.onError(error)
                        return
                    }
                    
                    guard (responseDict["message"] as! String) != "SessionExpired"    else {
                        _ = onLoginExpired
                        return
                    }
                    
                    if (responseDict["is_async"] as? Bool) != nil {//async
                        if let delay = responseDict["async_delay"] as? UInt{
                            if let token = responseDict["async_token"] as? String{
                                let asyncResponse = ResponseAsync(asyncToken: token , asyncDelay: delay )
                                let message = responseDict["message"] as? String
                                callBack.onProgress(delay, message ?? "")
                                self.getResponseAfterCheckedStatus(asyncResponce: asyncResponse , callBack: callBack, onLoginExpired: onLoginExpired)
                            }else{
                                let error = NSError(domain: "Async response doesn't have async_token value ", code: 10004, userInfo: nil)
                                callBack.onError(error)
                            }
                        }else{
                            let error = NSError(domain: "Async response doesn't have delay value ", code: 10003, userInfo: nil)
                            callBack.onError(error)
                        }
                    } else {//sync
                        let dataDic:[String:Any]? = responseDict["data"] as? [String : Any]
                        callBack.onSuccess(dataDic)
                        
                    }
                } else {
                    let error = NSError(domain: "Response Status is not Dict[String:Any]", code: 10002, userInfo: nil)
                    callBack.onError(error)
                }
                
            case .failure(let error):
                print(error)
                callBack.onError(error)
            }
        }
    }
    
    deinit {
        print("Erase uniq id = \(uniqId)")
        let _ = UniqId.shared.eraseId(uniqId: uniqId)
    }
}
