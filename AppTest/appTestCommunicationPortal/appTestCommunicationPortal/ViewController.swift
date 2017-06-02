//
//  ViewController.swift
//  test
//
//  Created by Vasilij Orlov on 5/22/17.
//  Copyright © 2017 Vasilij Orlov. All rights reserved.
//

import UIKit
import PortalCommunication



class ViewController: UIViewController {
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
     
        
        let setting         = PortalSetting(pingIntervalMs: 1000000, authServiceRoot: "https://authServiceRoot", appServiceRoot: "https://appServiceRoot", commonServiceRoot: "https://commonServiceRoot")
        let eventCallBack   = EventCallBack(onLoginExpired: {
            //code
        }, onPingFailed: { (error) in
            //code
        }) { (command, dictParam) in
            //code
        }
        let credentials   = PortalCredentials(appId: "appId", deviceId: "deviceId")
        
        //login
        let loginParam:[String:Any] = ["companyCode":"CompanyCode"]
        
        let operationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            print("success \(Date.init(timeIntervalSinceNow: 0))")
        }, onError: { (error) in
            //code
            print("error \(Date.init(timeIntervalSinceNow: 0)) error = \(error.localizedDescription) ")
        }) { (delayMS, message) in
            //code
        }
        
        
        
        
      let portal = PortalCommunicator.sharedInstance(setting, eventCallBack, credentials)
         print("login start \(Date.init(timeIntervalSinceNow: 0))")
       portal.login(params: loginParam, callBack: operationCallBack)
       /*
        
       portal.login(params: loginParam, callBack: operationCallBack)
       portal.login(params: loginParam, callBack: operationCallBack)
        */
             _ = portal.statusOperations()
       
        // Do any additional setup after loading the view, typically from a nib.
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
}

