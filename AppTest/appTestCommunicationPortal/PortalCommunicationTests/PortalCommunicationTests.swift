//
//  PortalCommunicationTests.swift
//  PortalCommunicationTests
//
//  Created by Vasilij Orlov on 6/15/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import XCTest
import PortalCommunication

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
            XCTAssertNotNil(data);
        }, onError: { (error) in
            //code
            XCTFail("we don't have error");
        }) { (delayMS, message) in
            //code
            XCTFail("we don't have error");
        }
        
        portal.login(params: loginParam, callBack: loginOperationCallBack)
        
        let loginOperationCallBackFail = OperationCallBack(onSuccess: { (data) in
            //code
            XCTFail("we don't have error");
        }, onError: { (error) in
            //code
            XCTAssertNotNil(error);
        }) { (delayMS, message) in
            //code
            XCTFail("we don't have error");
        }
        
        portalFail.login(params: loginParam, callBack: loginOperationCallBackFail)
    }
    
    func testGetSync(){
        
        var countDB  = portal.statusOperations().filter{$0.isSavedDB}.count
        var countAll = portal.statusOperations().count
        
        XCTAssertEqual(countDB, 0, "\(countDB) equal to 0");
        XCTAssertEqual(countAll, 0, "\(countAll) equal to 0");
        
        let getParam:[String:Any] = ["param1":"param1", "param2":"param2"]
        let methodName = "getData/sync"
        
        let getDataSyncOperationCallBack = OperationCallBack(onSuccess: { (data) in
            //code
            XCTAssertNotNil(data);
        }, onError: { (error) in
            //code
            XCTFail("we don't have error");
        }) { (delayMS, message) in
            //code
            XCTFail("we don't have error");
        }
        
        
        let idGetDataSync = portal.getData(methodName: methodName, params: getParam, callBack: getDataSyncOperationCallBack)
        XCTAssertGreaterThanOrEqual(idGetDataSync!, 0);
        XCTAssertLessThanOrEqual(idGetDataSync!, UInt8.max)
        
        //don't save operation
        countDB = portal.statusOperations().filter{$0.isSavedDB}.count
        countAll = portal.statusOperations().count
        
        XCTAssertEqual(countDB, 0, "\(countDB) equal to 0");
        XCTAssertEqual(countAll, 1, "\(countDB) equal to 1");
    }
    
    override func setUp() {
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
