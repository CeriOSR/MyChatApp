//
//  Users.swift
//  Messenger Clone 2.0
//
//  Created by Rey Cerio on 2016-11-19.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id: String?
    var name: String?
    var email: String?
    var password: String?
    var profileImageURL: String?
        
}

class Messages: NSObject {
    
    var text: String?
    var toId: String?
    var fromId: String?
    var time: String?
}


