//
//  PortalCommunicator.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 5/23/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit

struct MethodNameConstans {
    static let status   = "status"
    static let ping     = "ping"
}
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
    var onSuccess:  (_ dataJson:[String:Any]?) -> ()
    var onError:    (_ error:Error) -> ()
    var onProgress: (_ delayMs:UInt, _ message:String) -> ()
}

public struct EventCallBack {
    var eventDelegate:      EventCallbackDelegate?
    var onLoginExpired:     () -> ()
    var onPingFailed:       (_ error:Error) -> ()
    var onCommandReceived:  (_ name:String,_ params:[String:Any]) -> ()
    
    public init(eventDelegate:EventCallbackDelegate?, onLoginExpired:@escaping (() -> ()), onPingFailed:@escaping ((_ error:Error) -> ()), onCommandReceived:@escaping ((_ name:String,_ params:[String:Any]) -> ())){
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
    
    fileprivate var token               :String?
    
    var timer   = Timer()
    
    public static let sharedInstance:(_ setting:PortalSetting, _ eventCallBack:EventCallBack, _ credentials:PortalCredentials) -> PortalCommunicator = {
        setting, eventCallBack, credetials in
        return PortalCommunicator(setting: setting, eventCallBack:eventCallBack, credentials:credetials)
    }
    
    
    fileprivate init(setting:PortalSetting, eventCallBack:EventCallBack, credentials:PortalCredentials) {
        self.setting       = setting
        self.eventCallBack = eventCallBack
        self.credentials   = credentials
        super.init()
        
        prepareEventCallBack()
        
    }
    
    //MARK: - public method
    
    /* This method is used for logging in. Library manages auth-specific data automatically, so the method does not return any data.*/
    public func login(params:[String:Any], callBack:OperationCallBack) {
        
        let urlAuthService = URL.init(string: setting.authServiceRoot)
        
        guard urlAuthService != nil else {
            let error = NSError(domain: "AuthServiceRoot is not correct", code: 10001, userInfo: nil)
            callBack.onError(error)
            return
        }
        
        var authCallBack = callBack
        authCallBack.onSuccess = { [unowned self] data in
            if let token = data?["auth_token"]{
                self.token = token as? String
            }
            callBack.onSuccess(nil)
        }
        
        let operation = DataOperation(serviceRoot: urlAuthService!, type:.login, params: params, callBack: authCallBack)
        operation.start()
        
        currentOperations?[operation.uniqId] = operation
    }
    
    /*This method is used for cancelling request. It may happen if the result of the request is no longer needed.*/
    public func cancel(requestId:UInt8){
        let operation = currentOperations?[requestId]
        operation?.cancel()
    }
    
    /*This method is used for getting any data from the app service. Both parameters and request.*/
    public func getData(methodName:String, params:[String:Any], callBack:OperationCallBack) -> UInt8?{
        
        var urlGetDataService = URL.init(string: setting.appServiceRoot)
        urlGetDataService?.appendPathComponent(methodName)
        
        guard urlGetDataService != nil else {
            let error = NSError(domain: "AuthServiceRoot is not correct", code: 10001, userInfo: nil)
            callBack.onError(error)
            return nil
        }
        
        let operation = DataOperation(serviceRoot: urlGetDataService!, type:.data, params: params/*add auth*/, callBack: callBack)
        operation.start()
        currentOperations?[operation.uniqId] = operation
        
        return operation.uniqId
    }
    /*This method is used for getting any data from the app service. Both parameters and request.*/
    public func sendData(methodName:String, params:[String:Any], callBack:OperationCallBack) -> UInt8?{
        
        var urlGetDataService = URL.init(string: setting.appServiceRoot)
        urlGetDataService?.appendPathComponent(methodName)
        
        guard urlGetDataService != nil else {
            let error = NSError(domain: "AuthServiceRoot is not correct", code: 10001, userInfo: nil)
            callBack.onError(error)
            return nil
        }
        
        let operation = DataOperation(serviceRoot: urlGetDataService!,type:.data, params: params/*add auth*/, callBack: callBack)
        operation.start()
        currentOperations?[operation.uniqId] = operation
        
        return operation.uniqId
    }
    /*This method is used for updating library settings.*/
    public func setSettings(settings:PortalSetting){
        self.setting = settings
        
    }
    
    public func statusOperations() -> [StatusOperation] {
        
        var operationsStatus = [StatusOperation]()
        print("########### Current operation ###########")
        if let dictOperations = currentOperations {
            for uniqKey in dictOperations.keys{
                if let operation = dictOperations[uniqKey] {
                    let status:StatusOperation = (uniqKey, operation.type, operation.state)
                    operationsStatus.append(status)
                }
            }
        }
        print("#########################################")
        return operationsStatus
    }
    
    //MARK: - EventCallBack
    func prepareEventCallBack(){
        let repeatInterval = TimeInterval(setting.pingIntervalMs / 1000) //in Sec
        timer = Timer.scheduledTimer(timeInterval: repeatInterval, target: self, selector: #selector(pingServer), userInfo: nil, repeats: true)
    }
    /* This method is used for fetching the commands that can be executed by a mobile app.*/
    func pingServer(){
        
        var urlPingService = URL.init(string: setting.commonServiceRoot)
        urlPingService?.appendPathComponent(MethodNameConstans.ping)
        
        guard urlPingService != nil else {
            let error = NSError(domain: "urlPingService is not correct", code: 10001, userInfo: nil)
            eventCallBack.onPingFailed(error)
            return
        }
        let params = ["auth_token":self.token]
        
        let pingCallBack = OperationCallBack(onSuccess: { data in
            //<#code#>
        }, onError: { (error) in
            //<#code#>
        }) { (delaySec, message) in
           // <#code#>
        }
       
        
        let operation = DataOperation(serviceRoot: urlPingService!,type:.data, params: params/*add auth*/, callBack: pingCallBack)
        operation.start()
        currentOperations?[operation.uniqId] = operation
    }
    //MARK: - 
    deinit {
        timer.invalidate()
    }
}

