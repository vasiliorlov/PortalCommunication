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
    var backgroundTaskID:UIBackgroundTaskIdentifier? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = " \(defUser.integer(forKey: "int"))"
        
        
        
        
    }
    
    @IBAction func start(_ sender: Any) {
        print("start")
        var timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(timedCalc), userInfo: nil, repeats: true)
   
    }
    
    
    
    func timedCalc(){
        print("delay end \(self.sec)")
        self.sec += 300
        self.defUser.set(self.sec, forKey: "int")
        self.textView.text = " \(self.defUser.integer(forKey: "int"))"
        
    }
    
}
