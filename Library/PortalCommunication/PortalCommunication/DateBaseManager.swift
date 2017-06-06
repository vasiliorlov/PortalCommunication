//
//  DateBaseManager.swift
//  PortalCommunication
//
//  Created by Vasilij Orlov on 6/5/17.
//  Copyright © 2017 Stylesoft LLC. All rights reserved.
//

import UIKit

class DateBaseManager: NSObject {
    
    lazy var applicationDocumentDirectory:NSURL  {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }

}
