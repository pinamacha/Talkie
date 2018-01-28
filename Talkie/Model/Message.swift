//
//  Message.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/29/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var videoUrl: String?
    
    func chartPartnerId() -> String? {
        let chatPartnerId: String?
        //ternary operator
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        videoUrl = dictionary["videoUrl"] as? String
    }
}
