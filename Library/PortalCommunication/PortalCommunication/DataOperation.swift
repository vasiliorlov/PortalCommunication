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
    
    
    init(serviceRoot:URL, type:RequestOperationType, params:[String:Any], callBack:OperationCallBack) {
        self.params             = params
        self.callBack           = callBack
        super.init(serviceRoot: serviceRoot, type: .data)
    }
    //MARK: - override operation method
    override func main() {
        
        self.state = .checkingStatus
        
        Alamofire.request(self.serviceRoot, method: .post, parameters: self.params, encoding: URLEncoding.default, headers: nil).validate().responseJSON { [unowned self]  response in
            switch response.result {
                
            case .success(let JSON):
                if let responseDict = JSON as? [String:Any]{
                    if (responseDict["is_async"] as? Bool) != nil {//async
                        if let delay = responseDict["async_delay"] as? UInt{
                            if let token = responseDict["async_token"] as? String{
                                let asyncResponse = ResponseAsync(asyncToken: token , asyncDelay: delay )
                                self.getResponseAfterCheckedStatus(asyncResponce: asyncResponse , callBack: self.callBack)
                            }else{
                                let error = NSError(domain: "Async response doesn't have async_token value ", code: 10004, userInfo: nil)
                                self.callBack.onError(error)
                            }
                        }else{
                            let error = NSError(domain: "Async response doesn't have delay value ", code: 10003, userInfo: nil)
                            self.callBack.onError(error)
                        }
                    } else {//sync
                        let dataDic = responseDict["data"] as? [String : Any]
                        self.callBack.onSuccess(dataDic)
                    }
                } else {
                    let error = NSError(domain: "Response Status is not Dict[String:Any]", code: 10002, userInfo: nil)
                    self.callBack.onError(error)
                }
                
            case .failure(let error):
                print(error)
                self.callBack.onError(error)
            }
        }
    }
    
}
