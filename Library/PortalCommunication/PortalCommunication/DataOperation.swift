//
//  GetDataOperation.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 5/25/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit
import Alamofire


class DataOperation: RequestOperation {
    
    let params          :[String:Any]
    let callBack        :OperationCallBack
    let onLoginExpired  :() -> ()
    
    
    init(serviceRoot:URL, type:RequestOperationType, params:[String:Any], callBack:OperationCallBack, onLoginExpired:@escaping () -> ()) {
        self.params             = params
        self.callBack           = callBack
        self.onLoginExpired     = onLoginExpired
        super.init(serviceRoot: serviceRoot, type: type)
    }
    

    //MARK: - override operation method
    
    
    override func start() {
        _log("[\(Date())] start")
        _executing = true
        
        state = .requesting(requestPath: self.serviceRoot.absoluteString)
        
        
        Alamofire.request(self.serviceRoot, method: .post, parameters: self.params, encoding: URLEncoding.default, headers: nil).validate().responseJSON { response in
            
            switch response.result {
                
            case .success(let JSON):
                if let responseDict = JSON as? [String:Any]{
                    if (responseDict["is_async"] as? Bool) != nil {//async
                        if let delay = responseDict["async_delay"] as? UInt{
                            if let token = responseDict["async_token"] as? String{
                                let asyncResponse = ResponseAsync(asyncToken: token , asyncDelay: delay )
                                if !self.isFinished {
                                    self.getResponseFromCheckLoop(asyncResponce: asyncResponse , callBack: self.callBack, onLoginExpired:self.onLoginExpired)
                                }
                            }else{
                                let error = NSError(domain: "Async response doesn't have async_token value ", code: 10004, userInfo: nil)
                                self.callBack.onError(error)
                                self.finish()
                            }
                        }else{
                            let error = NSError(domain: "Async response doesn't have delay value ", code: 10003, userInfo: nil)
                            self.callBack.onError(error)
                            self.finish()
                        }
                    } else {//sync
                        let dataDic = responseDict["data"] as? [String : Any]
                        self.callBack.onSuccess(dataDic)
                        self.finish()
                    }
                } else {
                    let error = NSError(domain: "Response Status is not Dict[String:Any]", code: 10002, userInfo: nil)
                    self.callBack.onError(error)
                    self.finish()
                }
                
            case .failure(let error):
                self.callBack.onError(error)
                self.finish()
            }
        }
        
    }
    
    override func main() {
        _log("[\(Date())] main")
    }
}
