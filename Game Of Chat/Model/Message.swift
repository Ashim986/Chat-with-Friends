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
    @objc   var imageHeight : NSNumber?
    @objc   var imageWidth : NSNumber?
    
    func chatPartnerID()-> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
    
    init(dictionary : [String : AnyObject]) {
        super.init()
        fromID = dictionary["fromID"] as? String
        text = dictionary["text"] as? String
        toID = dictionary["toID"] as? String
        imageURL = dictionary["imageURL"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber


    }
}
