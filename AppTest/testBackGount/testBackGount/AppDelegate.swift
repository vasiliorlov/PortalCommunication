//
//  AppDelegate.swift
//  testBackGount
//
//  Created by Vasilij Orlov on 5/31/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var countStart:Int = 0
    
    var count:Int = 0
    var backgroundTaskID:UIBackgroundTaskIdentifier = -1
    let defUser = UserDefaults.standard
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    /*
    func backgrounfSycle(){
        bgTask = UIApplication.shared.beginBackgroundTask {
           self.backgrounfSycle()
            var duserTxt = (self.defUser.string(forKey:"txt") ?? "") + "| \(Date.init(timeIntervalSinceNow: 0))"
            self.defUser.set(duserTxt, forKey: "txt")
            UIApplication.shared.endBackgroundTask(self.bgTask)
   
        }
*/
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
      

    
        }

        
        
      
        // create a corresponding local notification

        /*
        aler
        // Create a new notification.
        UILocalNotification* alarm = [[UILocalNotification alloc] init];
        if (alarm)
        {
            alarm.fireDate = theDate;
            alarm.timeZone = [NSTimeZone defaultTimeZone];
            alarm.repeatInterval = 0;
            alarm.soundName = @"alarmsound.caf";
            alarm.alertBody = @"Time to wake up!";
            
            [app scheduleLocalNotification:alarm];
        }*/
        /*
        bgTask = application.beginBackgroundTask {
            application.endBackgroundTask(self.bgTask)
            self.bgTask = UIApplication.shared.beginBackgroundTask {
                UIApplication.shared.endBackgroundTask(self.bgTask)
            }
        }
        // Start the long-running task and return immediately.
        DispatchQueue.global().async {
            while true {
                sleep(10)
                self.sec = self.sec  + 10
                self.defUser.set(self.sec, forKey: "test")
            }
        }


        
        let timer = Timer.scheduledTimer(timeInterval: 150, target: self, selector: #selector(update), userInfo: nil, repeats: false)
         defUser.set(sec, forKey: "test")
        
        
    }
    func update(){
        

        bgTask = UIApplication.shared.beginBackgroundTask {
             UIApplication.shared.endBackgroundTask(self.bgTask)
        }
        let timer = Timer.scheduledTimer(timeInterval: 150, target: self, selector: #selector(update), userInfo: nil, repeats: false)
        
*/
        

 
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    /*
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        var fetch = defUser.integer(forKey: "test2")
        fetch = fetch + 1
       defUser.set(fetch, forKey: "test2")
        
        completionHandler(.newData)
    }*/
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }
}



