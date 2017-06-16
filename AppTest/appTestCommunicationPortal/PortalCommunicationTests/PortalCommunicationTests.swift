//
//  PortalCommunicationTests.swift
//  PortalCommunicationTests
//
//  Created by Vasilij Orlov on 6/15/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import XCTest
import PortalCommunication
import OCMock

class PortalCommunicationTests: XCTestCase {
    
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
    let portalFail = { () -> PortalCommunicator in
        // ##########################
        // --- Init ---
        
        let setting         = PortalSetting(pingIntervalMs: 100000, authServiceRoot: "http://_localhost:8080//api/login", appServiceRoot: "http://_localhost:8080//api/", commonServiceRoot: "http://_localhost:8080//api/")
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
    
    
    func testCreatePortal(){
        XCTAssertNotNil(portal)
        XCTAssertNotNil(portalFail)
    }
    
    func testLogin(){
        let loginParam:[String:Any] = [:]
        
        
        let loginOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            XCTAssertNotNil(data)
        }, onError: { (error) in
            //code
            XCTFail("we don't have error")
        }) { (delayMS, message) in
            //code
            XCTFail("we don't have error")
        }
        
        portal.login(params: loginParam, callBack: loginOperationCallBack)
        
        let loginOperationCallBackFail = OperationCallBack(onSuccess: { (data) in
            //code
            XCTFail("we don't have error")
        }, onError: { (error) in
            //code
            XCTAssertNotNil(error)
        }) { (delayMS, message) in
            //code
            XCTFail("we don't have error")
        }
        
        portalFail.login(params: loginParam, callBack: loginOperationCallBackFail)
    }
    
    func testGetSsync(){
        
        var countDB  = portal.statusOperations().filter{$0.isSavedDB}.count
        var countAll = portal.statusOperations().count
        
        XCTAssertEqual(countDB, 0, "\(countDB) equal to 0")
        XCTAssertEqual(countAll, 0, "\(countAll) equal to 0")
        
        let getParam:[String:Any] = ["param1":"param1", "param2":"param2"]
        let methodName = "getData/sync"
        
        let getDataSyncOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            XCTAssertNotNil(data)
        }, onError: { (error) in
            //code
            XCTFail("we don't have error")
        }) { (delayMS, message) in
            //code
            XCTFail("we don't have error")
        }
        
        
        let idGetDataSync = portal.getData(methodName: methodName, params: getParam, callBack: getDataSyncOperationCallBack)
        XCTAssertGreaterThanOrEqual(idGetDataSync!, 0)
        XCTAssertLessThanOrEqual(idGetDataSync!, UInt8.max)
        
        //don't save operation
        countDB = portal.statusOperations().filter{$0.isSavedDB}.count
        countAll = portal.statusOperations().count
        
        XCTAssertEqual(countDB, 0, "\(countDB) equal to 0")
        XCTAssertEqual(countAll, 1, "\(countAll) equal to 1")
        
    }
    
    func testGetAsync(){
        
        var countDB  = portal.statusOperations().filter{$0.isSavedDB}.count
        var countAll = portal.statusOperations().count
        
        XCTAssertEqual(countDB, 0, "\(countDB) equal to 0")
        XCTAssertEqual(countAll, 0, "\(countAll) equal to 0")
        
        let getParam:[String:Any] = ["param1":"param1", "param2":"param2"]
        let methodName = "getData/async"
        
        let getDataSyncOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            XCTFail("we don't have error")
            
        }, onError: { (error) in
            //code
            XCTFail("we don't have error")
        }) { (delayMS, message) in
            //code
            XCTAssertNotNil(delayMS)
            XCTAssertNotNil(message)
        }
        
        
        let idGetDataAync = portal.getData(methodName: methodName, params: getParam, callBack: getDataSyncOperationCallBack)
        XCTAssertGreaterThanOrEqual(idGetDataAync!, 0)
        XCTAssertLessThanOrEqual(idGetDataAync!, UInt8.max)
        
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            countDB = self.portal.statusOperations().filter{$0.isSavedDB}.count
            countAll = self.portal.statusOperations().count
            XCTAssertEqual(countDB, 1, "\(countDB) equal to 1")
            XCTAssertEqual(countAll, 1, "\(countAll) equal to 1")
        }
        
        
    }
    
    
    func testCancell(){
        var countDB  = portal.statusOperations().filter{$0.isSavedDB}.count
        var countAll = portal.statusOperations().count
        
        XCTAssertEqual(countDB, 0, "\(countDB) equal to 0")
        XCTAssertEqual(countAll, 0, "\(countAll) equal to 0")
        
        let getParam:[String:Any] = ["param1":"param1", "param2":"param2"]
        let methodName = "getData/async"
        
        let getDataSyncOperationCallBack = OperationCallBack(onSuccess: { (data) in
        }, onError: { (error) in
        }) { (delayMS, message) in
        }
        
        
        let idGetDataAync1  = portal.getData(methodName: methodName, params: getParam, callBack: getDataSyncOperationCallBack)
        _                   = portal.getData(methodName: methodName, params: getParam, callBack: getDataSyncOperationCallBack)
        _                   = portal.getData(methodName: methodName, params: getParam, callBack: getDataSyncOperationCallBack)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            countDB = self.portal.statusOperations().filter{$0.isSavedDB}.count
            countAll = self.portal.statusOperations().count
            
            XCTAssertEqual(countDB, 3, "\(countDB) equal to 3")
            XCTAssertEqual(countAll, 3, "\(countAll) equal to 3")
            
            self.portal.cancel(requestId: idGetDataAync1!)
            
            countDB = self.portal.statusOperations().filter{$0.isSavedDB}.count
            countAll = self.portal.statusOperations().count
            
            XCTAssertEqual(countDB, 2, "\(countDB) equal to 2")
            XCTAssertEqual(countAll, 2, "\(countAll) equal to 2")
            
            
            
            countDB = self.portal.statusOperations().filter{$0.isSavedDB}.count
            countAll = self.portal.statusOperations().count
            
            XCTAssertEqual(countDB, 0, "\(countDB) equal to 0")
            XCTAssertEqual(countAll, 0, "\(countAll) equal to 0")
        }
    }
    

    
    
    override func setUp() {
        portal.cancelAll()
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    

    
}
