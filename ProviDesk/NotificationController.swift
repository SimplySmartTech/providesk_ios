//
//  NotificationController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 08/11/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import PKHUD
import Localize_Swift
import SwiftyJSON

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class NotificationController: UIViewController,UIGestureRecognizerDelegate {
    
    //    MARK: - Variable Declaration
    @IBOutlet weak var notificationLbl: UILabel!
    
    var FromDashboard: NSString? = NSString()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isOverlayHide : Bool = false
    @IBOutlet weak var MenuOrBackImg : UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var overLayView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var noDataButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var faicon  = [String: UniChar]()
    var WS_Obj : WebServiceClass = WebServiceClass()
    var GEN_Obj : GeneralMethodClass = GeneralMethodClass()
    
//    var array:NSMutableArray = NSMutableArray()
//    var dictionary=NSMutableDictionary()
//    var modelNotificationsData : ModelNotificationsData?
//    var SectionsArr: Array<String> = []
//    var subLabel:String?
//    var descLabel:String?
//    var catagoryLabel:String?
//    var NotificationCatagory:String?
//    var Notification_id: String!
//    var Resident_id: String!
    
    
    var array:NSMutableArray = NSMutableArray()
    var dictionary=NSMutableDictionary()
    var modelNotificationsData : ModelNotificationsData?
    var SectionsArr: Array<String> = []
    var subLabel:String?
    var descLabel:String?
    var catagoryLabel:String?
    var NotificationCatagory:String?
    var Notification_id: String!
    var Resident_id: String!
    var noticeable_type: String!
    var noticeable_id: String!
    var imageLbl:String!
    
    //    MARK: - View controller life cycle methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=true
        tableView.tableFooterView = UIView(frame: .zero)
        self.FromDashboard = ""
        if((self.FromDashboard)?.length > 0)
        {
            MenuOrBackImg.image = UIImage(named: "BackImg")
        }
        else
        {
            MenuOrBackImg.image = UIImage(named: "Menu_Icon")
        }
        
        self.setText()
        setMenuItemUnicode()
        for _ in 0...7{
            let dict1:NSMutableDictionary=["section_OPEN":"NO"]
            array.add(dict1)
        }
        SectionsArr = NotificationSections()
        //        if GeneralMethodClass.isConnectedToNetwork() == true {
        //            print("Internet connection OK")
        //            self.hideOverlayView()
        //            CallNotificationAPI()
        //
        //        } else {
        //            print("Internet connection FAILED")
        //            self.displayNoData()
        //            self.noDataLbl.text = "Please check your internet connection.".localized()
        //        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationController.setText), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that +can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        notificationLbl.text = GeneralMethodClass.getSelectedFlatDisplayName()
        
        if GeneralMethodClass.isConnectedToNetwork() == true {
            print("Internet connection OK")
            //
            if(appDelegate.notificationResponceDic.count>0)
            {
                isOverlayHide = true
                self.modelNotificationsData = ModelNotificationsData.init(withData: appDelegate.notificationResponceDic)
                if self.modelNotificationsData!.arrayNotifications.count > 0 {
                    self.tableView.reloadData()
                }
            }
            else
            {
                isOverlayHide = false
            }
            //
            self.hideOverlayView()
            CallNotificationAPI()
        }
        else
        {
            print("Internet connection FAILED")
            self.displayNoData()
            self.noDataLbl.text = "Please check your internet connection.".localized()
        }
    }
    // MARK: Localized Text
    
    func setText(){
        //        notificationLbl.text = "Notifications".localized();
    }
    //    MARK: - Notification API Call
    func CallNotificationAPI(){
        
        DispatchQueue.main.async(execute: {
            if(self.isOverlayHide == false){
                self.displayLoader()
            }
        })
        
        let Dictionary = GeneralMethodClass.getUserData()
        //        print(Dictionary)
        if(Dictionary != nil)
        {
            Resident_id = Dictionary!.value(forKeyPath: String(format:"data.%@.id",GeneralMethodClass.GET_RESPONSE_KEY())) as? String
        }
        print("Resident_id :\(Resident_id)")
        let urlString = String(format: "api/residents/%@/notifications",Resident_id)
        
        WS_Obj.WebAPI_WithOut_Body_V2(urlString, RequestType: "GET"){(responce) in
            
            DispatchQueue.main.async(execute: {
                print(responce)
                
                self.hideOverlayView()
                print("Omkar:\(responce)")
                
                if(responce["Error"] != JSON.null)
                {
                    
                }
                else if((responce["message"]) == JSON.null)
                {
                    self.modelNotificationsData = ModelNotificationsData.init(withData: responce)
                    self.appDelegate.notificationResponceDic = responce
                    if self.modelNotificationsData!.arrayNotifications.count > 0 {
                        self.tableView.reloadData()
                    } else
                    {
                        self.displayNoData()
                        print("In message Omkar")
                        self.noDataLbl.text = "No data found.".localized()
                    }
                }
                else
                {
                    print("after else Omkar")
                    self.displayNoData()
                    self.noDataLbl.text = "No data found.".localized()
                }
            })
        }
    }
    
    func CallUpdateNotificationAPI(){
        
        if(isOverlayHide == false){
            self.displayLoader()
        }
        
        let date:Date = Date()
        let dateformatter:DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        let dateInFormat:String = dateformatter.string(from: date)
        
        let Dictionary = GeneralMethodClass.getUserData()
        // print(Dictionary)
        if(Dictionary != nil)
        {
            Resident_id = Dictionary!.value(forKeyPath: String(format:"data.%@.id",GeneralMethodClass.GET_RESPONSE_KEY())) as? String
        }
        let urlString = String(format: "api/residents/%@/notifications/%@",Resident_id,Notification_id)
        //notification[read_at]=2015-12-22T13%3A58%3A19%2B05%3A30
        
        let body = String(format: "notification[read_at]=%@",dateInFormat)
        
        WS_Obj.WebAPI_With_Body(urlString, Body: body, RequestType: "PUT"){(response) in
            self.hideOverlayView()
            
            var receivedData: JSON = JSON(0)
            receivedData = response
            if(receivedData["Error"] != JSON.null)
            {
                
            }
            else if (receivedData["message"].string?.isEqual("Notification updated successfully."))!
            {
                print(response)
            }
            else
            {
                let xyz = receivedData["message"].string
                
                DispatchQueue.main.async(execute: {
                    
                    let alert = UIAlertController(title: "Alert".localized(), message: xyz, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    // MARK: - Other Methods
    
    func handleTap(_ sender: UITapGestureRecognizer){
        
        if(sender.state == .ended)
        {
            //  print("section header is tapped")
        }
        let tempDict=NSMutableDictionary(object:array.object(at: (sender.view?.tag)!) , forKey: "section_OPEN" as NSCopying)
        if(((array.object(at: (sender.view?.tag)!) as AnyObject).value(forKey: "section_OPEN")! as AnyObject).isEqual(to: "YES")){
            tempDict.setValue("NO", forKey: "section_OPEN")
        }
        else
        {
            tempDict.setValue("YES", forKey: "section_OPEN")
        }
        
        array .replaceObject(at: (sender.view?.tag)!, with: tempDict)
        
        self.tableView.reloadData()
    }
    
    func setMenuItemUnicode(){
        faicon["Electricity"] = 0xE602
        faicon["Water"] = 0xE60B
        faicon["MyFlat"] = 0xe606
        faicon["Helpdesk"] = 0xe600
        faicon["Shopping"] = 0xe603
        faicon["DTH"] = 0xe604
        faicon["eWallet"] = 0xE60A
    }
    
    func NotificationSections() -> Array<String>
    {
        var menuObjectNameArray: Array<String> = []
        menuObjectNameArray.append("Electricity")
        menuObjectNameArray.append("Water")
        menuObjectNameArray.append("MyFlat")
        menuObjectNameArray.append("Helpdesk")
        menuObjectNameArray.append("Shopping")
        menuObjectNameArray.append("DTH")
        menuObjectNameArray.append("eWallet")
        return menuObjectNameArray
    }
    
    // MARK: - TableView data source
    //    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
    //        if self.modelNotificationsData != nil {
    //            return self.modelNotificationsData!.arrayNotifications.count
    //        } else {
    //            return 0
    //        }
    //    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let view=UIView(frame: CGRect(x: 0,y: 0,width: tableView.frame.size.width,height: 50))
    //        view.tag=section
    //        view.backgroundColor=UIColor.white
    //
    //        var doesCategoryTitleExsist = true
    //        var categoryTitle = modelNotificationsData!.arrayNotifications[section].category
    //        if categoryTitle.characters.count == 0 {
    //            categoryTitle = modelNotificationsData!.arrayNotifications[section].arrayNotifications[0].subject
    //            doesCategoryTitleExsist = false
    //        }
    //
    //        let imageLabel=UILabel(frame: CGRect(x: 5,y: 0,width: 60,height: 60))
    //
    //        if doesCategoryTitleExsist {
    //            imageLabel.backgroundColor=UIColor.clear
    //            imageLabel.textColor=UIColor.black
    //            imageLabel.font = UIFont(name:"botsworth", size: 30)
    //            //            imageLabel.text = String(format: "%C",faicon[categoryTitle]!)
    //        }
    //
    //
    //        let UnreadCountLabel = UILabel(frame: CGRect(x: 22,y: 0,width: 30,height: 30))
    //        if !doesCategoryTitleExsist {
    //            UnreadCountLabel.frame = CGRect(x: 10, y: 15, width: 30, height: 30)
    //        }
    //        UnreadCountLabel.layer.cornerRadius=15
    //        UnreadCountLabel.clipsToBounds=true
    //        var  str : Int = 0
    //        if self.modelNotificationsData!.arrayNotifications.count>0{
    //            str = self.modelNotificationsData!.arrayNotifications[section].unreadCount
    //            UnreadCountLabel.text=NSString(format: "%d", str) as String
    //        }
    //
    //        UnreadCountLabel.textAlignment=NSTextAlignment.center
    //        UnreadCountLabel.textColor=UIColor.black
    //        UnreadCountLabel.backgroundColor = UIColor(red: 251/255.0, green: 186/255.0, blue: 16/255.0, alpha: 1.0)
    //
    //        let screenSize: CGRect = UIScreen.main.bounds
    //        let screenWidth = screenSize.width
    //
    //        var catagoryLabel : UILabel!
    //        var descriptionLabel : UILabel!
    //        var dateLabel : UILabel!
    //        if ((screenWidth==320))
    //        {
    //            catagoryLabel=UILabel(frame: CGRect(x: 62, y: 15, width: 145, height: 21))
    //            descriptionLabel=UILabel(frame: CGRect(x: 62,y: 35,width: 235,height: 21))
    //            dateLabel=UILabel(frame: CGRect(x: 200, y: 15, width: 115, height: 21))
    //        }
    //        else if (screenWidth==375)
    //        {
    //            catagoryLabel=UILabel(frame: CGRect(x: 62, y: 15, width: 195, height: 21))
    //            descriptionLabel=UILabel(frame: CGRect(x: 62,y: 35,width: 285,height: 21))
    //            dateLabel=UILabel(frame: CGRect(x: 250, y: 15, width: 115, height: 21))
    //        }
    //        else if (screenWidth==414)
    //        {
    //            catagoryLabel=UILabel(frame: CGRect(x: 62, y: 15, width: 235, height: 21))
    //            descriptionLabel=UILabel(frame: CGRect(x: 62,y: 35,width: 325,height: 21))
    //            dateLabel=UILabel(frame: CGRect(x: 290, y: 15, width: 115, height: 21))
    //        }
    //        else
    //        {
    //            catagoryLabel=UILabel(frame: CGRect(x: 62, y: 15, width: 145, height: 21))
    //            descriptionLabel=UILabel(frame: CGRect(x: 62,y: 35,width: 235,height: 21))
    //            dateLabel=UILabel(frame: CGRect(x: 200, y: 15, width: 115, height: 21))
    //        }
    //
    //
    //        if self.modelNotificationsData!.arrayNotifications.count > 0 {
    //            catagoryLabel.text = categoryTitle
    //        }
    //        catagoryLabel.textColor=UIColor.black
    //
    //
    //
    ////        if self.modelNotificationsData!.arrayNotifications.count > 0 {
    ////            descriptionLabel.text = modelNotificationsData!.arrayNotifications[section].arrayNotifications[0].description
    ////        }
    //        descriptionLabel.textColor=UIColor.black
    //
    //        dateLabel.textAlignment = NSTextAlignment.right
    //        if self.modelNotificationsData!.arrayNotifications.count > 0 {
    //
    ////            let myDate = self.modelNotificationsData!.arrayNotifications[section].arrayNotifications[0].createdAt
    ////
    ////            let TimeStamp = GEN_Obj.ConvertDateFormater(myDate, Old_Format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ", New_Format: "dd MMM,yy hh:mm a")
    ////            //let TimeStamp = self.convertDateFormater(myDate!)
    ////
    ////            dateLabel.text = TimeStamp
    //        }
    //
    //
    //        //adding tap gesture on view
    //        let tap=UITapGestureRecognizer(target: self, action: #selector(NotificationController.handleTap(_:)))
    //        tap.numberOfTapsRequired=1
    //        tap.numberOfTouchesRequired=1
    //        tap.delegate=self
    //
    //        view.addSubview(imageLabel)
    //        if str != 0{
    //            view.addSubview(UnreadCountLabel)
    //        }
    //        view.addSubview(descriptionLabel)
    //        view.addSubview(catagoryLabel)
    //        view.addSubview(dateLabel)
    //        view.addGestureRecognizer(tap)
    //
    //        // UnreadCountLabel.font = UnreadCountLabel.font.fontWithSize(14)
    //        UnreadCountLabel.font = UIFont(name:"Eurostile-Med", size: 14.0)
    //        //catagoryLabel.font = catagoryLabel.font.fontWithSize(14)
    //        catagoryLabel.font = UIFont(name:"Eurostile-Med", size: 16.0)
    //        //descriptionLabel.font = descriptionLabel.font.fontWithSize(12)
    //        descriptionLabel.font = UIFont(name:"Eurostile-Med", size: 13.0)
    //        //  dateLabel.font = dateLabel.font.fontWithSize(12)
    //        dateLabel.font = UIFont(name:"Eurostile-Med", size: 12.0)
    //
    //        return view
    //    }
    //
    
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 60.0
    //    }
    //
    //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //        return 3.0
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.modelNotificationsData?.arrayNotifications.count > 0)
        {
            //            if(((array.object(at: (section)) as AnyObject).value(forKey: "section_OPEN")! as AnyObject).isEqual(to: "YES")){
            return self.modelNotificationsData!.arrayNotifications.count
            //            }
            //            else{
            //                return 0
            //            }
        }else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        //        let padding = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NotificationTableViewCell
        cell.subjectLabel?.text = self.modelNotificationsData!.arrayNotifications[indexPath.row].category
        // cell.subjectLabel.alignmentRectInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        cell.descriptionLabel?.text = self.modelNotificationsData!.arrayNotifications[indexPath.row].subject
        
        let status = self.modelNotificationsData!.arrayNotifications[indexPath.row].unread
        
        if status == true {
            cell.subjectLabel.font = UIFont(name: "Arial-BoldMT", size: 15.0)
            cell.descriptionLabel.font = UIFont(name: "Arial-BoldMT", size: 11.0)
            cell.dateLabel.font = UIFont(name: "Arial-BoldMT", size: 10.0)
            cell.subjectLabel.textColor=UIColor.black
            cell.descriptionLabel.textColor=UIColor.black
            cell.dateLabel.textColor=UIColor.black
        }
        else
        {
            cell.subjectLabel.font = UIFont(name: "ArialMT", size: 15.0)
            cell.descriptionLabel.font = UIFont(name: "ArialMT", size: 11.0)
            cell.dateLabel.font = UIFont(name: "ArialMT", size: 10.0)
            cell.subjectLabel.textColor=UIColor.darkGray
            cell.descriptionLabel.textColor=UIColor.darkGray
            cell.dateLabel.textColor=UIColor.darkGray
        }
        
        let myDate = self.modelNotificationsData!.arrayNotifications[indexPath.row].createdAt
        
        let TimeStamp = GEN_Obj.ConvertDateFormater(myDate, Old_Format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ", New_Format: "dd MMM,yy hh:mm a")
        cell.dateLabel.text = TimeStamp
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        Notification_id = self.modelNotificationsData!.arrayNotifications[indexPath.row].ID
        
        CallUpdateNotificationAPI()
        
        subLabel = self.modelNotificationsData!.arrayNotifications[indexPath.row].subject
        
        descLabel = self.modelNotificationsData!.arrayNotifications[indexPath.row].description
        
        noticeable_type = self.modelNotificationsData?.arrayNotifications[indexPath.row].noticeable_type
        
        noticeable_id = self.modelNotificationsData?.arrayNotifications[indexPath.row].noticeable_id
        
        imageLbl = self.modelNotificationsData?.arrayNotifications[indexPath.row].category
        
        
        
        
        //        StringCategorySubject = self.modelNotificationsData?.arrayNotifications[indexPath.row].category
        //        StringNumber = self.modelNotificationsData?.arrayNotifications[indexPath.row].ID
        //        //StringImg = self.modelNotificationsData?.arrayNotifications[inde
        //        StringComplaintID = self.modelNotificationsData?.arrayNotifications[indexPath.row].ID
        //        StringState = self.modelNotificationsData?.arrayNotifications[indexPath.row].
        //        OpenORClosed
        //        FromWhere
        
        
        if( noticeable_type == "Utility" || (noticeable_type == nil && noticeable_id == nil)){
            print("aaaaaaaaaaaaaaaaaa")
            
            self.performSegue(withIdentifier: "NotificationDetail", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "complaint_details", sender: self)
        }
        
        //        NotificationCatagory = self.modelNotificationsData!.category
        //        print("name of catagory-->\(NotificationCatagory)")
        
        // print("\(ResponceDic.valueForKeyPath("data.notifications")?.valueForKey("category"))")
        // print("Array of catagory by index-->\(ResponceArray.objectAtIndex(indexPath.section))")
        //        let
        //        _ = tableView.indexPathForSelectedRow!
        //        if let _ = tableView.cellForRow(at: indexPath) {
        //
        //        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "NotificationDetail") {
            let vc = segue.destination as! NotificationDetailController
            vc.stringPass = subLabel
            vc.stringPass2 = descLabel
            vc.stringPass3 = NotificationCatagory
        }
        if (segue.identifier == "complaint_details"){
            let detailVC = segue.destination as! HelpDeskChatController
            
            // detailVC.notificationFlag = true
            detailVC.StringComplaintID = noticeable_id
            
            //  detailVC.StringComplaintID =
            //            detailVC.StringCategorySubject = subCategory
            //            detailVC.StringNumber = number
            detailVC.StringImg = imageLbl
            //            detailVC.StringComplaintID = complaintId
            //            detailVC.StringState = subCategoryState
            detailVC.OpenORClosed = "open"
            detailVC.FromWhere = "Else"
            
            
            
            
        }
    }
    
    // MARK: - Navigation
    @IBAction func BackBtnTapped(_ sender: AnyObject)
    {
        if((self.FromDashboard)?.length > 0)
        {
            self.FromDashboard = ""
            _ = self.navigationController?.popViewController(animated: true)
        }
        else
        {
            toggleLeft()
        }
    }
    
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: Overlay View functions
    
    func displayLoader() {
        self.overLayView.isHidden = false;
        self.activityIndicator.isHidden = false;
        self.noDataLbl.isHidden = true;
        self.noDataButton.isHidden = true;
    }
    
    func displayNoData() {
        self.overLayView.isHidden = false;
        self.activityIndicator.isHidden = true;
        self.noDataLbl.isHidden = false;
        self.noDataButton.isHidden = false;
    }
    
    func hideOverlayView() {
        self.overLayView.isHidden = true;
    }
    
}
