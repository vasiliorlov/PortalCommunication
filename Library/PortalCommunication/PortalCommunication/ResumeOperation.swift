//
//  ResumeOperation.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/16/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit

class ResumeOperation: RequestOperation {
    let asyncResponse   :ResponseAsync
    let callBack        :OperationCallBack
    let onLoginExpired  :() -> ()
    
     init(resumeOperationModel:AsyncOperationModel,callBack:OperationCallBack, onLoginExpired:@escaping () -> ()){
        let url                 = resumeOperationModel.urlVerification
        let asyncToken          = resumeOperationModel.asyncToken
        let delay               = resumeOperationModel.asyncDelay
        let id                  = resumeOperationModel.id
        
        self.callBack           = callBack
        self.onLoginExpired     = onLoginExpired
        self.asyncResponse      = ResponseAsync(asyncToken: asyncToken! , asyncDelay: delay! )
        super.init(serviceRoot: url!, type: .data)
        self.uniqId             = id!
    }
    
    override func start() {
        _log("[\(Date())] start")
        _executing = true
        
        state = .requesting(requestPath: self.serviceRoot.absoluteString)
        self.getResponseFromCheckLoop(asyncResponce: asyncResponse , callBack: self.callBack, onLoginExpired:self.onLoginExpired)
    
    }
}
