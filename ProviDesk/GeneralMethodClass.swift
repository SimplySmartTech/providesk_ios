//
//  GeneralMethodClass.swift
//  ProviDesk
//
//  Created by Omkar Awate on 19/09/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import SystemConfiguration
import SwiftyJSON


class GeneralMethodClass: NSObject {
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    class func Get_Current_Flat_id () ->String{
        
        var Flat_uuid = ""
        let flatno = UserDefaults.standard.value(forKey: "mySelectedFlatNo") as? NSString
        let Dictionary = GeneralMethodClass.getUserData()
        //print(Dictionary)
        var keyLoginType = "sites"
        if GeneralMethodClass.isCurrentLoginForIndustrial() {
            keyLoginType = "sites"
        }
        let array = Dictionary!.value(forKeyPath: String(format: "data.user.%@",keyLoginType)) as! NSArray
        
        for dict in array
        {
            let obj = dict as! NSDictionary
            if(flatno!.isEqual(to: obj.value(forKey: "name") as! String))
            {
                Flat_uuid = (obj.value(forKey: "id") as! String)
                return Flat_uuid
            }
        }
        return Flat_uuid
    }
    
    //    class func Get_Current_Site_id () ->String{
    //
    //        var Flat_uuid = ""
    //        let flatno = UserDefaults.standard.value(forKey: "mySelectedSiteId") as? NSString
    //        let Dictionary = GeneralMethodClass.getUserData()
    //        //print(Dictionary)
    //        var keyLoginType = "sites"
    //        if GeneralMethodClass.isCurrentLoginForIndustrial() {
    //            keyLoginType = "sites"
    //        }
    //        let array = Dictionary!.value(forKeyPath: String(format: "data.user.%@",keyLoginType)) as! NSArray
    //
    //        for dict in array
    //        {
    //            let obj = dict as! NSDictionary
    //            if(flatno!.isEqual(to: obj.value(forKey: "id") as! String))
    //            {
    //                Flat_uuid = (obj.value(forKey: "id") as! String)
    //                return Flat_uuid
    //            }
    //        }
    //        return Flat_uuid
    //    }
    
    class func Get_selected_Flat_id (_ SelectedFlatNo: NSString) ->String{
        
        var Flat_uuid = ""
        let Dictionary = GeneralMethodClass.getUserData()
        //print(Dictionary)
        var keyLoginType = "sites"
        if GeneralMethodClass.isCurrentLoginForIndustrial() {
            keyLoginType = "sites"
        }
        let array = Dictionary!.value(forKeyPath: String(format: "data.user.%@",keyLoginType)) as! NSArray
        
        for dict in array
        {
            let obj = dict as! NSDictionary
            if(SelectedFlatNo.isEqual(to: obj.value(forKey: "name") as! String))
            {
                Flat_uuid = (obj.value(forKey: "id") as! String)
                return Flat_uuid
            }
        }
        return Flat_uuid
    }
    
    class func getSelectedFlatDisplayName() -> String {
        let myFlatsDisplayNameDict=(UserDefaults.standard.value(forKey: "FlatDisplayDict") as! NSMutableDictionary)
        // print(myFlatsDisplayNameDict)
        let flatno = UserDefaults.standard.value(forKey: "mySelectedFlatNo") as? NSString ?? ""
        if(flatno.length > 0){
            return (myFlatsDisplayNameDict.value(forKey: flatno as String) as? String)!
        }else{
            return ""
        }
    }
    
    class func Get_SubCategory_id (_ SubCategoryArr: Array<JSON>, SelectedSubCategory: String) ->String{
        
        var SubCategory_id = ""
        //print(SubCategoryArr)
        for dict in SubCategoryArr
        {
            if(SelectedSubCategory.isEqual(dict["name"].string))
            {
                SubCategory_id = dict["id"].string!
                return SubCategory_id
            }
        }
        return SubCategory_id
    }
    
    class func Get_Current_Resident_id () ->String{
        
        let Dictionary = GeneralMethodClass.getUserData()
        //print(Dictionary)
        let ID = Dictionary!.value(forKeyPath: "data.resident.id") as! String
        
        return ID
    }
    
    class func Get_Current_UserName () ->String{
        
        let Dictionary = GeneralMethodClass.getUserData()
        //print(Dictionary)
        let userName = Dictionary!.value(forKeyPath: "data.resident.name") as! String
        print("Logged in User Is : \(userName)")
        
        return userName
    }
    
    class func Get_Current_companyName () ->String{
        
        let Dictionary = GeneralMethodClass.getUserData()
        //print(Dictionary)
        if Dictionary!.value(forKeyPath: "data.user.company.name") as? String != nil{
        let companyName = Dictionary!.value(forKeyPath: "data.user.company.name") as! String
        
        return companyName
        }
        else{
            return ""}
    }
    
    //    class func Get_Current_company_logoURL () ->String{
    //
    //        let Dictionary = GeneralMethodClass.getUserData()
    //
    //        var logoURL = ""
    //        //print(Dictionary)
    //        if Dictionary!.value(forKeyPath: "data.user.company.logo_url") != nil{
    //            logoURL = Dictionary!.value(forKeyPath: "data.user.company.logo_url") as! String
    //        }
    //
    //        return logoURL
    //    }
    
    
    class func isCurrentLoginForIndustrial() -> Bool {
        let policyData = GeneralMethodClass.getUserData()!["policy"] as! NSDictionary
        //        if policyData["company_type"] as! String == "industrial" {
        //            return true
        //        } else {
        return false
        //        }
    }
    
    func ConvertDateFormater(_ date: String, Old_Format: String, New_Format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Old_Format
        guard let date = dateFormatter.date(from: date) else {
            assert(false, "no date from string")
            return ""
        }
        dateFormatter.dateFormat = New_Format
        let timeStamp = dateFormatter.string(from: date)
        return timeStamp
    }
    
    // Convert from NSData to json object
    class func nsdataToJSON(_ data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    // Convert from JSON to nsdata
    class func jsonToNSData(_ json: AnyObject) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    
    class func getUserData() -> NSDictionary? {
        return GeneralMethodClass.nsdataToJSON((UserDefaults.standard.value(forKey: "UserData") as? Data)!) as? NSDictionary
    }
    
    class func getUIColorFromHex(_ hexColor : String) -> UIColor {
        var hexString = hexColor.replacingOccurrences(of: "#", with: "")
        var alpha = 255
        if hexString.characters.count > 6 {
            let aplhaString = hexString.substring(to: hexString.index(hexString.endIndex, offsetBy: -6))
            alpha = Int(aplhaString, radix: 16) ?? 0
            hexString = hexString.substring(from: hexString.index(hexString.endIndex, offsetBy: -6))
        }
        
        let hexValue = Int(hexString, radix: 16) ?? 0
        return UIColor.init(red: ((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hexValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(hexValue & 0xFF))/255.0, alpha: (CGFloat)(alpha)/255.0)
    }
    
}


