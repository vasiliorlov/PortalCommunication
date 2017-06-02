//
//  ViewController.swift
//  testBackGount
//
//  Created by Vasilij Orlov on 5/31/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var labelTimeSec: UILabel!
    @IBOutlet weak var textView: UITextView!
    let defUser = UserDefaults.standard
    var sec:Int = 0
    var backgroundTask:UIBackgroundTaskIdentifier = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let sec = defUser.integer(forKey: "test")
        let fetch = defUser.integer(forKey: "test2")
        textView.text = "\(sec) + fetch + \(fetch)"
        defUser.removeObject(forKey: "test")
    }
    
    func setupBackgrounding (){
        NotificationCenter.default.addObserver(self, selector: #selector(appBackgrounding), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appForegrounding), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func appBackgrounding(notification:NSNotification){
        keepAlive()
    }
    
    func keepAlive(){
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.backgroundTask = UIBackgroundTaskInvalid
            self.keepAlive()
        })
    }
    
    func appForegrounding(){
        if backgroundTask != UIBackgroundTaskInvalid{
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }
    
    
    @IBAction func refresh(_ sender: Any) {
           timeLabel.text = "\(UIApplication.shared.backgroundTimeRemaining)"
    }
    
    func update(){
        sec = sec + 1
        defUser.set(sec, forKey: "test")
    }
}

