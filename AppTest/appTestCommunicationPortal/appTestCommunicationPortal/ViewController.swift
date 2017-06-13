//
//  ViewController.swift
//  test
//
//  Created by Vasilij Orlov on 5/22/17.
//  Copyright © 2017 Vasilij Orlov. All rights reserved.
//

import UIKit
import PortalCommunication



class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelOperationId: UITextField!
    @IBOutlet weak var consoleLabel: UILabel!
    let portal = { () -> PortalCommunicator in
        // ##########################
        // --- Init ---
        
        let setting         = PortalSetting(pingIntervalMs: 100000, authServiceRoot: "http://localhost:8080//api/login", appServiceRoot: "http://localhost:8080//api/", commonServiceRoot: "http://localhost:8080//api/")
        let eventCallBack   = EventCallBack(onLoginExpired: {
            //code
        }, onPingFailed: { (error) in
            //code
        }) { (command, dictParam) in
            print("ping command \(dictParam)")
            //code
        }
        let credentials   = PortalCredentials(appId: "qwerty", deviceId: "asdf")
        return PortalCommunicator.sharedInstance(setting, eventCallBack, credentials)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         
         portal.login(params: loginParam, callBack: operationCallBack)
         portal.login(params: loginParam, callBack: operationCallBack)
         */
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    
    @IBAction func login(_ sender: Any) {
        // ##########################
        // --- login ---
        let loginParam:[String:Any] = [:]
        
        let loginOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            self.console("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data)) \n")
            print("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data))")
        }, onError: { (error) in
            //code
            self.console("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) \n")
            print("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) ")
        }) { (delayMS, message) in
            //code
            self.console("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) \n")
        }
        print("login start \(Date.init(timeIntervalSinceNow: 0))")
        portal.login(params: loginParam, callBack: loginOperationCallBack)
        
    }
    
    @IBAction func getDataSync(_ sender: Any) {
        // ##########################
        // --- GetData ---
        // ------- sync ---
        let getParam:[String:Any] = ["param1":"param1", "param2":"param2"]
        let methodName = "getData/sync"
        
        let getDataSyncOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            self.console("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data)) \n")
            print("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data))")
        }, onError: { (error) in
            //code
            self.console("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) \n")
            print("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) ")
        }) { (delayMS, message) in
            //code
            self.console("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) \n")
        }
        print("getDataSync start \(Date.init(timeIntervalSinceNow: 0))")
        let idGetDataSync = portal.getData(methodName: methodName, params: getParam, callBack: getDataSyncOperationCallBack)
        self.console("started operation with id = \(String(describing: idGetDataSync!))\n")
    }
    
    @IBAction func getDataAsync(_ sender: Any) {
        // ##########################
        // --- GetData ---
        // ------- Async ---
        let getParam:[String:Any] = ["param1":"param1", "param2":"param2"]
        let methodName = "getData/async"
        
        let getDataAsyncOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            self.console("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data)) \n")
            print("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data))")
        }, onError: { (error) in
            //code
            self.console("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) \n")
            print("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) ")
            
        }) { (delayMS, message) in
            //code
            print ("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) ")
            self.console("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) \n")
            
        }
        print("getDataAync start \(Date.init(timeIntervalSinceNow: 0))")
        let  idGetDataAsync = portal.getData(methodName: methodName, params: getParam, callBack: getDataAsyncOperationCallBack)
        self.console("started operation with id = \(String(describing: idGetDataAsync!))\n")
        
    }
    
    @IBAction func canceledOperation(_ sender: Any) {
        // ##########################
        // --- Cancel Operation --
        if let idOperation = UInt8(self.cancelOperationId.text ?? "0"){
            self.console("cancel operation id = \(String(describing: idOperation)) \n")
            portal.cancel(requestId: idOperation)
            
        }
    }
    
    @IBAction func setDataSync(_ sender: Any) {
        // ##########################
        // --- SetData ---
        // ------- sync ---
        let setParam:[String:Any] = ["param1":"param1", "param2":"param2", "locations":["loc1":["id":"id1", "sourceId":"sourceId1", "descr":"descr1"],"loc2":["id":"id2", "sourceId":"sourceId2", "descr":"descr2"]]]
        let methodName = "setData/sync"
        
        let setDataSyncOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            self.console("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data)) \n")
            print("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data))")
        }, onError: { (error) in
            //code
            self.console("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) \n")
            print("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) ")
        }) { (delayMS, message) in
            //code
            self.console("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) \n")
        }
        print("getDataSync start \(Date.init(timeIntervalSinceNow: 0))")
        let idSetDataSync = portal.sendData(methodName: methodName, params: setParam, callBack: setDataSyncOperationCallBack)
        self.console("started operation with id = \(String(describing: idSetDataSync!))\n")
    }
    
    @IBAction func setDataAsync(_ sender: Any) {
        // ##########################
        // --- SetData ---
        // ------- Async ---
        let setParam:[String:Any] = ["param1":"param1", "param2":"param2", "locations":["loc1":["id":"id1", "sourceId":"sourceId1", "descr":"descr1"],"loc2":["id":"id2", "sourceId":"sourceId2", "descr":"descr2"]]]
        let methodName = "setData/async"
        
        let setDataAsyncOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            self.console("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data)) \n")
            print("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data))")
        }, onError: { (error) in
            //code
            self.console("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) \n")
            print("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) ")
            
        }) { (delayMS, message) in
            //code
            print ("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) ")
            self.console("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) \n")
        }
        print("getDataAync start \(Date.init(timeIntervalSinceNow: 0))")
        let  idSetDataAsync = portal.sendData(methodName: methodName, params: setParam, callBack: setDataAsyncOperationCallBack)
        console("started operation with id = \(String(describing: idSetDataAsync!))\n")
    }
    
    
    @IBAction func getStatus(_ sender: Any) {
        // ##########################
        // --- Status Operations ---
        let operations = portal.statusOperations()
        console("status \(String(describing: operations)) \n")
        
    }
    func console(_ addText:String){
        if (consoleLabel.text != nil) {
            consoleLabel.text =  consoleLabel.text! + addText
        } else {
            consoleLabel.text = addText
        }
    }
    
    @IBAction func clearTextView(_ sender: Any) {
        consoleLabel.text = ""
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:
    func onLoginExpired(){
        
    }
    func onPingFailed(error:Error){
        
    }
    func onCommandReceived(name:String,params:[String:Any]){
        
    }
    //MARK - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

