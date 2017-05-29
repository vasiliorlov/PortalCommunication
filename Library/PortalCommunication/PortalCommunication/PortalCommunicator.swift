//
//  PortalCommunicator.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 5/23/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit
import UserNotifications

struct MethodNameConstans {
    static let status   = "status"
    static let ping     = "ping"
}

public struct PortalSetting {
    var pingIntervalMs      :UInt
    var authServiceRoot     :String
    var appServiceRoot      :String
    var commonServiceRoot   :String
    
    public init(pingIntervalMs: UInt, authServiceRoot: String, appServiceRoot: String, commonServiceRoot: String ) {
        self.pingIntervalMs     = pingIntervalMs
        self.authServiceRoot    = authServiceRoot
        self.appServiceRoot     = appServiceRoot
        self.commonServiceRoot  = commonServiceRoot
    }
}


public struct OperationCallBack {
    var onSuccess           :(_ dataJson:[String:Any]?) -> ()
    var onError             :(_ error:Error) -> ()
    var onProgress          :(_ delayMs:UInt, _ message:String) -> ()
    
    public init(onSuccess:@escaping (_ dataJson:[String:Any]?) -> (), onError:@escaping (_ error:Error) -> (), onProgress:@escaping (_ delayMs:UInt, _ message:String) -> ()){
        self.onSuccess  = onSuccess
        self.onError    = onError
        self.onProgress = onProgress
    }
}

public struct EventCallBack {
    var onLoginExpired      :() -> ()
    var onPingFailed        :(_ error:Error) -> ()
    var onCommandReceived   :(_ name:String,_ params:[String:Any]) -> ()
    
    public init( onLoginExpired:@escaping (() -> ()), onPingFailed:@escaping ((_ error:Error) -> ()), onCommandReceived:@escaping ((_ name:String,_ params:[String:Any]) -> ())){
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
    
    fileprivate var queueOperation      = OperationQueue()
    fileprivate var token               :String?
    
    fileprivate var timer                = Timer()
    
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
        
        let operation = DataOperation(serviceRoot: urlAuthService!, type:.login, params: params, callBack: authCallBack, onLoginExpired: self.eventCallBack.onLoginExpired)
        queueOperation.addOperation(operation)
        
    }
    
    /*This method is used for cancelling request. It may happen if the result of the request is no longer needed. RequestId = 0 is error*/
    public func cancel(requestId:UInt8){
        for operation in queueOperation.operations{
            let dataOperation = operation as! DataOperation
            if dataOperation.uniqId == requestId {
                dataOperation.cancel()
                dataOperation.finish()
            }
            
        }
    }
    
    /*This method is used for getting any data from the app service. Both parameters and request. RequestId = 0 is error*/
    public func getData(methodName:String, params:[String:Any], callBack:OperationCallBack) -> UInt8{
        
        var urlGetDataService = URL.init(string: setting.appServiceRoot)
        urlGetDataService?.appendPathComponent(methodName)
        
        guard urlGetDataService != nil else {
            let error = NSError(domain: "AuthServiceRoot is not correct", code: 10001, userInfo: nil)
            callBack.onError(error)
            return 0
        }
        
        let operation = DataOperation(serviceRoot: urlGetDataService!, type:.data, params: params/*add auth*/, callBack: callBack, onLoginExpired: self.eventCallBack.onLoginExpired)
        queueOperation.addOperation(operation)
        
        return operation.uniqId
    }
    /*This method is used for getting any data from the app service. Both parameters and request.  RequestId = 0 is error*/
    public func sendData(methodName:String, params:[String:Any], callBack:OperationCallBack) -> UInt8{
        
        var urlGetDataService = URL.init(string: setting.appServiceRoot)
        urlGetDataService?.appendPathComponent(methodName)
        
        guard urlGetDataService != nil else {
            let error = NSError(domain: "AuthServiceRoot is not correct", code: 10001, userInfo: nil)
            callBack.onError(error)
            return 0
        }
        
        let operation = DataOperation(serviceRoot: urlGetDataService!,type:.data, params: params/*add auth*/, callBack: callBack, onLoginExpired: self.eventCallBack.onLoginExpired)
        queueOperation.addOperation(operation)
        
        return operation.uniqId
    }
    /*This method is used for updating library settings.*/
    public func setSettings(settings:PortalSetting){
        self.setting = settings
    }
    
    public func statusOperations() -> [StatusOperation] {
        
        var operationsStatus = [StatusOperation]()
        print("########### Current operation ###########")
        
        for operation in queueOperation.operations{
            let dataOperation = operation as! DataOperation
            let status:StatusOperation = (dataOperation.uniqId, dataOperation.type, dataOperation.state)
            operationsStatus.append(status)
            print("id \(dataOperation.uniqId) type \(dataOperation.type) state \(dataOperation.state)")
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
        
        let pingCallBack = OperationCallBack(onSuccess: { data in
            if let data = data{
                if  let commands = data["commands"] as? [[String:Any]] {
                    for command in commands {
                        if let name  = command["name"] as? String {
                            let params = command["params"] as! [String:Any]
                            self.eventCallBack.onCommandReceived(name, params)
                        }
                    }
                }
            }
        }, onError: { (error) in
            
            self.eventCallBack.onPingFailed(error)
        }) { (delaySec, message) in
            //code
        }
        
        let paramsAuth:[String:Any] = ["auth_token":self.token ?? ""]
        
        let operation = DataOperation(serviceRoot: urlPingService!,type:.data, params: paramsAuth/*add auth*/, callBack: pingCallBack, onLoginExpired: self.eventCallBack.onLoginExpired)
        queueOperation.addOperation(operation)
        
    }
    
    /*This method is used for register device for receiving push notifications.*/
    func registerForPush(){
        
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: []) { (granted, error) in
                if granted {
                    application.registerForRemoteNotifications()
                    center.delegate = self as? UNUserNotificationCenterDelegate
                }
            }
            application.registerForRemoteNotifications()
        } else {
            let notificationSettings = UIUserNotificationSettings(types: [], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }
    }
    
    func receiveRemoteNotification(){
        pingServer()
    }
    //MARK: - memory control
    deinit {
        timer.invalidate()
    }
}

