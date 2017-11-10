//
//  Message.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 11/5/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
 @objc   var fromID : String?
 @objc   var text : String?
 @objc   var timeStamp : NSNumber?
 @objc   var toID : String?
 @objc   var imageURL : String?
    
    func chatPartnerID()-> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
}
