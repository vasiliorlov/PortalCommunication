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
    case registerForPush
}

public enum RequestOperationState {
    case ready
    case pause
    case waiting(delayMs:UInt)
    case requesting(requestpath:String)
    case checkingStatus
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
        return URL.init(string:"http://localhost:8080//api/status/ready")! //for loca test
        //return serviceRoot.appendingPathComponent(Constans.Methodname.status)
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    var _canceled = false{
        willSet {
            willChangeValue(forKey: "isCancelled")
        }
        didSet {
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override var isCancelled: Bool{
        return _canceled
    }
    
    
    
    
    init(serviceRoot:URL, type:RequestOperationType) {
        self.serviceRoot    = serviceRoot
        self.type           = type
        self.state          = .ready
        do{
            uniqId     = try UniqId.shared.getId()
            print("Generate new uniq id = \(self.uniqId) for operation \(type)")
        } catch {
            assert(false, "Full set uniq Id")
            uniqId     = 0
        }
        super.init()
    }
    
    //MARK: - control operation method
    /* This method is used for stopping operation. The current asynctoken's cycle will be closed immediately. The request's status won't be checked.*/
    func finish() {
        print("[\(Date())] Operation id = \(uniqId) type = \(type) was finished ")
        state = .finished
        _executing = false
        _finished = true
    }

    
    //MARK: - override operation method
    
    //MARK: - custom method
    func getResponseAfterCheckedStatus(asyncResponce:ResponseAsync, callBack: OperationCallBack, onLoginExpired:@escaping () -> ()){
        
        let delay = asyncResponce.asyncDelay
        self.state = .waiting(delayMs: delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay) / 1000){ [unowned self] in
            
            self.state = .checkingStatus
            
            let param:Parameters = ["asyncToken":asyncResponce.asyncToken]
            
            Alamofire.request(self.serviceRootForStatus, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).validate().responseJSON { [unowned self]  response in
                switch response.result {
                    
                case .success(let JSON):
                    
                    if let responseDict = JSON as? [String:Any]{
                        
                        guard responseDict["is_success"] as! Bool else {
                            let error = NSError(domain: "Service returns incorrct response", code: 10007, userInfo: nil)
                            callBack.onError(error)
                            self.finish()
                            return
                        }
                        
                        guard (responseDict["message"] as! String) != "SessionExpired" else {
                            _ = onLoginExpired
                            return
                        }
                        
                        if (responseDict["is_async"] as? Bool) != nil {//async
                            if let delay = responseDict["async_delay"] as? UInt{
                                if let token = responseDict["async_token"] as? String{
                                    let asyncResponse = ResponseAsync(asyncToken: token , asyncDelay: delay )
                                    let message = responseDict["message"] as? String
                                    if !self.isFinished {
                                        callBack.onProgress(delay, message ?? "")
                                        self.getResponseAfterCheckedStatus(asyncResponce: asyncResponse , callBack: callBack, onLoginExpired: onLoginExpired)
                                    }
                                }else{
                                    let error = NSError(domain: "Async response doesn't have async_token value ", code: 10004, userInfo: nil)
                                    callBack.onError(error)
                                    self.finish()
                                }
                            }else{
                                let error = NSError(domain: "Async response doesn't have delay value ", code: 10003, userInfo: nil)
                                callBack.onError(error)
                                self.finish()
                            }
                        } else {//sync
                            let dataDic:[String:Any]? = responseDict["data"] as? [String : Any]
                            callBack.onSuccess(dataDic)
                            self.finish()
                            
                        }
                    } else {
                        let error = NSError(domain: "Response Status is not Dict[String:Any]", code: 10002, userInfo: nil)
                        callBack.onError(error)
                        self.finish()
                    }
                    
                case .failure(let error):
                    callBack.onError(error)
                    self.finish()
                }
            }
        }
    }
    
    //
    func saveOperationIfNeed(asyncDelay:UInt) -> Bool{
        let dateCheckedStatus   = Date(timeIntervalSinceNow: TimeInterval(asyncDelay))
        let dateEndSafeInterval = Date(timeIntervalSinceNow: UIApplication.shared.backgroundTimeRemaining - TimeInterval(Constans.safeIntervalSec))
        if dateCheckedStatus.compare(dateEndSafeInterval) == .orderedDescending {
            //save
            return true
        }
        return false
    }
    
    deinit {
        print("Erase uniq id = \(uniqId)")
        let _ = UniqId.shared.eraseId(uniqId: uniqId)
    }
}
