//
//  ModelComplaintsData.swift
//  ProviDesk
//
//  Created by Omkar Awate on 09/10/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import SwiftyJSON

struct ComplaintData {
    var number = 0
    var subCategoryName = ""
    var unreadComments = true
    var complaintCategoryName = ""
    var id = ""
    var unitInfo = ""
    var description = ""
    var aasmState = ""
    var requestCategoryName = ""
    var priority = ""
    var category_short_name = ""
    
    
}

class ModelComplaintsData {
    
    var arrayComplaints : [ComplaintData] = Array()
    
    init(withData data:JSON) {
        let arrayReceivedData = data["data"]["complaints"].arrayValue
        
        for complaint in arrayReceivedData {
            var complaintData = ComplaintData()
            complaintData.number = complaint["number"].intValue
            complaintData.subCategoryName = complaint["sub_category_name"].stringValue
            complaintData.unreadComments = complaint["unread_comments"].boolValue
            complaintData.complaintCategoryName = complaint["complaint_category_name"].stringValue
            complaintData.id = complaint["id"].stringValue
            complaintData.unitInfo = complaint["unit_info"].stringValue
            complaintData.description = complaint["description"].stringValue
            complaintData.aasmState = complaint["aasm_state"].stringValue
            complaintData.requestCategoryName = complaint["request_category_name"].stringValue
            complaintData.category_short_name = complaint["category_short_name"].stringValue
            complaintData.priority = complaint["priority"].stringValue
            self.arrayComplaints.append(complaintData)
        }
    }
    
}
