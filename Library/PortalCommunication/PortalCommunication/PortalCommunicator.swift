//
//  PortalCommunicator.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 5/23/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit

public protocol EventCallbackDelegate {
    func onLoginExpired()
    func onPingFailed(error:Error)
    func onCommandReceived(name:String,params:[String:Any])
}

public struct PortalSetting {
    var pingIntervalMs:     UInt
    var authServiceRoot:    String
    var appServiceRoot:     String
    var commonServiceRoot:  String
    
    public init(pingIntervalMs: UInt, authServiceRoot: String, appServiceRoot: String, commonServiceRoot: String ) {
        self.pingIntervalMs     = pingIntervalMs
        self.authServiceRoot    = authServiceRoot
        self.appServiceRoot     = appServiceRoot
        self.commonServiceRoot  = commonServiceRoot
    }
}

public struct OperationCallBack {
    var onSuccess:  (() -> ())?
    var onError:    ((_ error:Error) -> ())?
    var onProgress: ((_ delayMs:UInt, _ message:String) -> ())?
    
    public init(onSuccess:(() -> ())?, onError:((_ error:Error) -> ())?, onProgress:((_ delayMs:UInt, _ message:String) -> ())?){
        self.onSuccess  = onSuccess
        self.onError    = onError
        self.onProgress = onProgress
    }
}

public struct DataOperationCallBack {
    var onSuccess:  ((_ dataJson:Array<Any>,()) -> ())?
    var onError:    ((_ error:Error) -> ())?
    var onProgress: ((_ delayMs:UInt, _ message:String) -> ())?
}

public struct EventCallBack {
    var eventDelegate:      EventCallbackDelegate?
    var onLoginExpired:     (() -> ())?
    var onPingFailed:       ((_ error:Error) -> ())?
    var onCommandReceived:  ((_ name:String,_ params:[String:Any]) -> ())?
    
    public init(eventDelegate:EventCallbackDelegate?, onLoginExpired:(() -> ())?, onPingFailed:((_ error:Error) -> ())?, onCommandReceived:((_ name:String,_ params:[String:Any]) -> ())?){
        self.eventDelegate      = eventDelegate
        self.onLoginExpired     = onLoginExpired
        self.onPingFailed       = onPingFailed
        self.onCommandReceived  = onCommandReceived
    }
}

public struct PortalCredentials {
    var appId            :String
    var deviceId         :String
    var companyCode      :String?
    
    public init(appId:String, deviceId:String){
        self.appId      = appId
        self.deviceId   = deviceId
    }
    
    public init(appId:String, deviceId:String, companyCode:String?){
        self.init(appId: appId, deviceId: deviceId)
        self.companyCode        = companyCode
    }
    
}

public typealias StatusOperation = (unigId:UInt8, type:RequestOperationType, state:RequestOperationState)

public class PortalCommunicator: NSObject{
    
    fileprivate var setting             :PortalSetting
    fileprivate var eventCallBack       :EventCallBack
    fileprivate var credentials         :PortalCredentials
    
    fileprivate var currentOperations   :[UInt8:RequestOperation]?
    
    fileprivate var token           :UUID?
    
    public static let sharedInstance:(_ setting:PortalSetting, _ eventCallBack:EventCallBack, _ credentials:PortalCredentials) -> PortalCommunicator = {
        setting, eventCallBack, credetials in
        return PortalCommunicator(setting: setting, eventCallBack:eventCallBack, credentials:credetials)
    }
    
    
    fileprivate init(setting:PortalSetting, eventCallBack:EventCallBack, credentials:PortalCredentials) {
        self.setting       = setting
        self.eventCallBack = eventCallBack
        self.credentials   = credentials
        super.init()
    }

    //MARK: - public method
    
    /* This method is used for logging in. Library manages auth-specific data automatically, so the method does not return any data.*/
    public func login(params:[String:Any], callBack:OperationCallBack) {
        
        let urlAuthService = URL.init(string: setting.authServiceRoot)
        
        guard urlAuthService != nil else {
            if let errorCallBack = callBack.onError {
                let error = NSError(domain: "AuthServiceRoot is not correct", code: 10001, userInfo: nil)
                errorCallBack(error)
            }
            return
        }
        
        let operation = RequestOperation(serviceRoot: urlAuthService!, type: .login)
        operation.name = "login"
        operation.completionBlock = { () -> Void in
            
            sleep(5)
            print("login \(Date.init(timeIntervalSinceNow: 0))")
            
        }
        operation.start()
        
        
    }
    
    /*This method is used for cancelling request. It may happen if the result of the request is no longer needed.*/
    public func cancel(requestId:UUID){
        
    }
    
    /*This method is used for getting any data from the app service. Both parameters and request.*/
    public func getData(methodName:String, params:[String:Any], callBack:DataOperationCallBack) -> UInt8{
        
        return 1
    }
    /*This method is used for getting any data from the app service. Both parameters and request.*/
    public func sendData(methodName:String, params:[String:Any], callBack:OperationCallBack) -> UInt8{
        
        return 2
    }
    /*This method is used for updating library settings.*/
    public func setSettings(settings:PortalSetting){
        self.setting = settings
    }
    
    public func statusOperations() -> [StatusOperation] {
        //test
        let status:StatusOperation = (1, RequestOperationType.login, RequestOperationState.ready)
        return [status]
    }
    
    //MARK: - EventCallBack
    
    
    //MARK: - private method
}

