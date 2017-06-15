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
    case requesting(requestPath:String)
    case checkingStatus(statusPath:String)
    case finished
}


struct ResponseAsync {
    var asyncToken:     String
    var asyncDelay:     UInt
}

class RequestOperation: Operation {
    let serviceRoot         :URL
    let type                :RequestOperationType
    var state               :RequestOperationState
    var uniqId              :UInt8
    var dateCheckedStatus   :Date? = nil
    var serviceRootForStatus:URL {
        return URL.init(string:"http://localhost:8080//api/status/ready")! //for localhost simulator test
        // return serviceRoot.appendingPathComponent(Constans.Methodname.status)
    }
    let dataManager         = DateBaseManager.sharedInstance
    
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
    
    override var description: String{
        return "id = \(uniqId) type = \(type) state = \(state)"
    }
    
    
    init(serviceRoot:URL, type:RequestOperationType) {
        self.serviceRoot    = serviceRoot
        self.type           = type
        self.state          = .ready
        do{
            uniqId     = try UniqId.shared.getId()
            _log("Generate new uniq id = \(self.uniqId) for operation \(type)")
        } catch {
            assert(false, "Full set uniq Id")
            uniqId     = 0
        }
        super.init()
    }
    
    //MARK: - control operation method
    /* This method is used for stopping operation. The current asynctoken's cycle will be closed immediately. The request's status won't be checked.*/
    func finish() {
        _log("[\(Date())] Operation id = \(uniqId) type = \(type) was finished ")
        dataManager.delete(idOperation: uniqId)
        state = .finished
        _executing = false
        _finished = true
        
    }
    
    
    //MARK: - override operation method
    
    //MARK: - custom method
    func getResponseFromCheckLoop(asyncResponce:ResponseAsync, callBack: OperationCallBack, onLoginExpired:@escaping () -> ()){
        
        
        let delayMs = asyncResponce.asyncDelay
        self.state = .waiting(delayMs: delayMs)
        self.dateCheckedStatus = Date.init(timeIntervalSinceNow: TimeInterval(delayMs / 1000))
        self.saveOperation(asyncResponce: asyncResponce)
        
        _log("\(Date())  - \(String(describing: self.dateCheckedStatus)) ")
        DispatchQueue.global().async {
            while true {
                guard !self.isFinished     else { break }
                guard !self.isCancelled    else { break }
                if Date().compare(self.dateCheckedStatus!) == .orderedDescending {
                    self.getResponseExpiredRequest(asyncResponce: asyncResponce, callBack: callBack, onLoginExpired: onLoginExpired)
                    break
                }
                sleep(1)
            }
        }
    }
    
    
    func getResponseExpiredRequest(asyncResponce:ResponseAsync, callBack: OperationCallBack, onLoginExpired:@escaping () -> ()){
        self.state = .checkingStatus(statusPath: serviceRootForStatus.absoluteString)
        
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
                                    self.getResponseFromCheckLoop(asyncResponce: asyncResponse , callBack: callBack, onLoginExpired: onLoginExpired)
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
    
    //save / update async operation
    
    func saveOperation(asyncResponce:ResponseAsync){
        let asyncToken = asyncResponce.asyncToken
        let delay      = asyncResponce.asyncDelay
        
        
        let model = AsyncOperationModel(idOperation: uniqId, asyncToken: asyncToken, dateVerification: self.dateCheckedStatus, asyncDelay: delay, urlVerification: self.serviceRootForStatus)
        dataManager.save(model: model)
        
    }
    
    deinit {
        _log("Erase uniq id = \(uniqId)")
        let _ = UniqId.shared.eraseId(uniqId: uniqId)
    }
}
