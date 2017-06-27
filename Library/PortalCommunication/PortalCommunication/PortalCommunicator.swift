//
//  PortalCommunicator.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 5/23/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit
import UserNotifications


struct Constans {
    struct Methodname {
        static let status       = "status"
        static let ping         = "ping"
        static let registerPush = "registerForPush"
    }
    
    static let safeIntervalSec  = 5     //safe work interval before suspended in Sec
    static let debugLog         = true  //print debug info
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

public typealias StatusOperation = (unigId:UInt8, type:RequestOperationType, state:RequestOperationState, isSavedDB:Bool)

func _log(_ info:String) {
    if Constans.debugLog {
        Swift.print(info)
    }
}

@objc public protocol PortalDelegate{
  @objc optional func operation(id:UInt8, didFinishWithData:[String:Any]?)
}

public class PortalCommunicator: NSObject{
    
    fileprivate var setting             :PortalSetting
    fileprivate var eventCallBack       :EventCallBack
    fileprivate var credentials         :PortalCredentials
    
    fileprivate var queueOperation      = OperationQueue()
    fileprivate var authToken           :String?
    
    fileprivate var timer               = Timer()
    public var delegate                 :PortDelegate?
    
    let dataManager         = DateBaseManager.sharedInstance
    
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
        
        guard credentials.appId != "" else {
            let error = NSError(domain: "Application ID is not installed", code: 10100, userInfo: nil)
            callBack.onError(error)
            return
        }
        
        guard credentials.deviceId != "" else {
            let error = NSError(domain: "Device ID is not installed", code: 10101, userInfo: nil)
            callBack.onError(error)
            return
        }
        
        var authParams          = params
        authParams["app_id"]    = credentials.appId
        authParams["device_id"] = credentials.deviceId
        
        
        var authCallBack = callBack
        authCallBack.onSuccess = { [unowned self] data in
            if let token = data?["auth_token"]{
                self.authToken = token as? String
                print("Auth token \(String(describing: self.authToken!)) was saved")
            }
            callBack.onSuccess(data)
        }
        
        let operation = DataOperation(serviceRoot: urlAuthService!, type:.login, params: authParams, callBack: authCallBack, onLoginExpired: self.eventCallBack.onLoginExpired)
        queueOperation.addOperation(operation)
        
    }
    
    /*This method is used for cancelling request. It may happen if the result of the request is no longer needed. */
    public func cancel(requestId:UInt8){
        
        
        for operation in queueOperation.operations{
            let dataOperation = operation as! RequestOperation
            if dataOperation.uniqId == requestId {
                dataOperation.cancel()
                dataOperation.finish()
                return
            }
        }
        //if operation only in DB
        dataManager.delete(idOperation: requestId)
    }
    
    /*This method is used for cancelling all requests. It may happen if the result of the request is no longer needed. */
    public func cancelAll(){
        for operation in queueOperation.operations{
            let dataOperation = operation as! RequestOperation
            dataOperation.cancel()
            dataOperation.finish()
            _log("Opertion id = \(dataOperation.uniqId) is canceled")
        }
        //if operation only in DB
        dataManager.deleteAll()
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
        
        let operation = DataOperation(serviceRoot: urlGetDataService!, type:.data, params: params/*add auth*/, callBack: callBack, onLoginExpired: self.eventCallBack.onLoginExpired)
        queueOperation.addOperation(operation)
        
        return operation.uniqId
    }
    
    /*This method is used for getting any data from the app service. Both parameters and request. */
    public func sendData(methodName:String, params:[String:Any], callBack:OperationCallBack) -> UInt8?{
        
        var urlSetDataService = URL.init(string: setting.appServiceRoot)
        urlSetDataService?.appendPathComponent(methodName)
        
        guard urlSetDataService != nil else {
            let error = NSError(domain: "AuthServiceRoot is not correct", code: 10001, userInfo: nil)
            callBack.onError(error)
            return nil
        }
        
        let operation = DataOperation(serviceRoot: urlSetDataService!,type:.data, params: params/*add auth*/, callBack: callBack, onLoginExpired: self.eventCallBack.onLoginExpired)
        queueOperation.addOperation(operation)
        
        return operation.uniqId
    }
    
    /*This method is used for updating library settings.*/
    public func setSettings(settings:PortalSetting){
        self.setting = settings
    }
    
    public func statusOperations() -> [StatusOperation] {
        
        var operationsStatus = [StatusOperation]()
        _log("########### Current operation ###########")
        
        for operation in queueOperation.operations{
            let dataOperation = operation as! DataOperation
            let status:StatusOperation = (dataOperation.uniqId, dataOperation.type, dataOperation.state, false)
            operationsStatus.append(status)
            _log("id =  \(dataOperation.uniqId) type = \(dataOperation.type) state = \(dataOperation.state)")
        }
        _log("########### Async Operations in DB ###########")
        getDataBase(arrayStatus: &operationsStatus)
        return operationsStatus
    }
    
    /*This method is used for register device for receiving push notifications. The only usage for now "push-to-ping"*/
    public func registerForPush(pushToken:String, callBack:OperationCallBack) -> UInt8?{
        var urlRegisterpushService = URL.init(string: setting.commonServiceRoot)
        urlRegisterpushService?.appendPathComponent(Constans.Methodname.registerPush)
        
        guard urlRegisterpushService != nil else {
            let error = NSError(domain: "urlRegisterForPushService is not correct", code: 10001, userInfo: nil)
            eventCallBack.onPingFailed(error)
            return nil
        }
        
        
        
        let paramsPush:[String:Any] = ["auth_token":self.authToken ?? "", "push_token":pushToken, "push_service":"APNS" ]
        
        let operation = DataOperation(serviceRoot: urlRegisterpushService!,type:.registerForPush, params: paramsPush, callBack: callBack, onLoginExpired: self.eventCallBack.onLoginExpired)
        queueOperation.addOperation(operation)
        return operation.uniqId
    }
    
    /*This method is used for resume all operation from DB after reload application.*/
    public func resumeOperationFromDB(id:UInt8, callBack:OperationCallBack){
         let resumeOperationModel  = dataManager.read(idOperation: id)
        guard (resumeOperationModel != nil) else {
            let error = NSError(domain: "Async operation is not found in DB", code: 10013, userInfo: nil)
            callBack.onError(error)
            return
        }
        let resumeOperation = ResumeOperation.init(resumeOperationModel: resumeOperationModel!, callBack: callBack, onLoginExpired: self.eventCallBack.onLoginExpired)

        queueOperation.addOperation(resumeOperation)
        
    }
    
    //MARK: - EventCallBack
    
    func prepareEventCallBack(){
        let repeatInterval = TimeInterval(setting.pingIntervalMs / 1000) //in Sec
        timer = Timer.scheduledTimer(timeInterval: repeatInterval, target: self, selector: #selector(pingServer), userInfo: nil, repeats: true)
        
    }
    
    //MARK: - private method
    //print saved async operation
    func getDataBase( arrayStatus:inout [StatusOperation]){
        if  let savedOperations = dataManager.readAll(){
            for operation in savedOperations {
                _log("\(operation.description)")
                let status:StatusOperation = (operation.id!, RequestOperationType.data, RequestOperationState.waiting(delayMs: operation.asyncDelay!), true)
                arrayStatus.append(status)
            }
        }
    }
    
    /* This method is used for fetching the commands that can be executed by a mobile app.*/
    func pingServer(){
        
        var urlPingService = URL.init(string: setting.commonServiceRoot)
        urlPingService?.appendPathComponent(Constans.Methodname.ping)
        
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
        
        let paramsAuth:[String:Any] = ["auth_token":self.authToken ?? ""]
        
        let operation = DataOperation(serviceRoot: urlPingService!,type:.ping, params: paramsAuth/*add auth*/, callBack: pingCallBack, onLoginExpired: self.eventCallBack.onLoginExpired)
        queueOperation.addOperation(operation)
        
    }
    
    func receiveRemoteNotification(){
        pingServer()
    }
    
    
    //MARK: - memory control
    deinit {
        timer.invalidate()
    }
    
}

