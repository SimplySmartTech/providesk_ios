//
//  ModelNotificationsData.swift
//  ProviDesk
//
//  Created by Omkar Awate on 09/11/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import SwiftyJSON

struct NotificationData {
    var category = ""
    var unread = true
    var unitID = ""
    var unitInfo = ""
    var unitBuilding = ""
    var unitName = ""
    var companyID = ""
    var createdAt = ""
    var ID = ""
    var subject = ""
    var description = ""
    var noticeable_type = ""
    var noticeable_id = ""
    
}

//struct NotificationCategory_V2 {
//    var unreadCount = 0
//    var category = ""
//   // var arrayNotifications : [NotificationData] = Array()
//}

class ModelNotificationsData {
    
    var arrayNotifications: [NotificationData] = Array()
    
    init(withData data:JSON) {
        //let arrayReceivedData = data["notifications"].arrayValue
        
        //        for category in arrayReceivedData {
        //            var categoryData = NotificationCategory_V2()
        //            categoryData.unreadCount = category["unread_count"].intValue
        //            categoryData.category = category["category"].stringValue
        
        print ("Data Json : \(data)")
        
        for notification in data["data"]["notifications"].arrayValue {
            var notificationData = NotificationData()
            notificationData.category = notification["category"].stringValue
            notificationData.unread = notification["unread"].boolValue
            notificationData.unitID = notification["unit"]["id"].stringValue
            notificationData.unitInfo = notification["unit"]["info"].stringValue
            notificationData.unitBuilding = notification["unit"]["building"].stringValue
            notificationData.unitName = notification["unit"]["name"].stringValue
            notificationData.companyID = notification["company_id"].stringValue
            notificationData.createdAt = notification["created_at"].stringValue
            notificationData.ID = notification["id"].stringValue
            notificationData.subject = notification["subject"].stringValue
            notificationData.description = notification["description"].stringValue
            notificationData.noticeable_type = notification["noticeable_type"].stringValue
            notificationData.noticeable_id = notification["noticeable_id"].stringValue
            arrayNotifications.append(notificationData)
        }
        //           self.arrayNotifications.append(categoryData)
        // }
    }
}
