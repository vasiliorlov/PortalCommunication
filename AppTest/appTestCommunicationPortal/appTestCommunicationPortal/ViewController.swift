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
    
    
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var cancelOperationId: UITextField!
    
    let portal = { () -> PortalCommunicator in
        // ##########################
        // --- Init ---
        
        let setting         = PortalSetting(pingIntervalMs: 1000000, authServiceRoot: "http://localhost:8080//api/login", appServiceRoot: "http://localhost:8080//api/", commonServiceRoot: "http://localhost:8080//api/")
        let eventCallBack   = EventCallBack(onLoginExpired: {
            //code
        }, onPingFailed: { (error) in
            //code
        }) { (command, dictParam) in
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
            self.consoleTextView.text.append("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data)) \n")
            print("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data))")
        }, onError: { (error) in
            //code
            self.consoleTextView.text.append("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) \n")
            print("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) ")
        }) { (delayMS, message) in
            //code
            self.consoleTextView.text.append("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) \n")
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
            self.consoleTextView.text.append("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data)) \n")
            print("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data))")
        }, onError: { (error) in
            //code
            self.consoleTextView.text.append("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) \n")
            print("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) ")
        }) { (delayMS, message) in
            //code
            self.consoleTextView.text.append("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) \n")
        }
        print("getDataSync start \(Date.init(timeIntervalSinceNow: 0))")
        let idGetDataSync = portal.getData(methodName: methodName, params: getParam, callBack: getDataSyncOperationCallBack)
        consoleTextView.text.append("started operation with id = \(String(describing: idGetDataSync!))\n")
    }
    
    @IBAction func getDataAsync(_ sender: Any) {
        // ##########################
        // --- GetData ---
        // ------- Async ---
        let getParam:[String:Any] = ["param1":"param1", "param2":"param2"]
        let methodName = "getData/async"
        
        let getDataAsyncOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            self.consoleTextView.text.append("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data)) \n")
            print("success \(Date.init(timeIntervalSinceNow: 0)) data \(String(describing: data))")
        }, onError: { (error) in
            //code
            self.consoleTextView.text.append("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) \n")
            print("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) ")
            
        }) { (delayMS, message) in
            //code
            print ("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) ")
            self.consoleTextView.text.append("progress \(Date.init(timeIntervalSinceNow: 0)) delay = \(delayMS) \(message) \n")
        }
        print("getDataAync start \(Date.init(timeIntervalSinceNow: 0))")
        let  idGetDataAsync = portal.getData(methodName: methodName, params: getParam, callBack: getDataAsyncOperationCallBack)
        consoleTextView.text.append("started operation with id = \(String(describing: idGetDataAsync!))\n")
        
    }
    
    
    @IBAction func canceledOperation(_ sender: Any) {
        // ##########################
        // --- Cancel Operation --
        if let idOperation = UInt8(self.cancelOperationId.text ?? "0"){
            self.consoleTextView.text.append("try cancel operation id = \(String(describing: idOperation)) \n")
            let result = portal.cancel(requestId: idOperation)
            self.consoleTextView.text.append("canceled \(result ? "Ok" : "Failure") \n")
        }
    }
    
    @IBAction func setDataSync(_ sender: Any) {
    }
    
    @IBOutlet weak var setDataAsync: UIButton!
    
    
    @IBAction func getStatus(_ sender: Any) {
        // ##########################
        // --- Status Operations ---
        let operations = portal.statusOperations()
        self.consoleTextView.text.append("status \(String(describing: operations)) \n")
        
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

