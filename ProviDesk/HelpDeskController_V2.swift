//
//  SensorsViewController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 20/09/17.
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


class HelpDeskController_V2: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    var FromDashboard: NSString? = NSString()
    @IBOutlet weak var MenuOrBackImg : UIImageView!
    @IBOutlet weak var tableView_Pending: UITableView!
    @IBOutlet weak var tableView_Resolved: UITableView!
    @IBOutlet weak var openBtnView: UIView!
    @IBOutlet weak var openLbl: UILabel!
    @IBOutlet weak var openLblTxt: UILabel!
    @IBOutlet weak var closeBtnView: UIView!
    @IBOutlet weak var closeLbl: UILabel!
    @IBOutlet weak var closeLblTxt: UILabel!
    @IBOutlet weak var addLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var ActivityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var overLayView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var noDataButton: UIButton!
    @IBOutlet weak var activityIndicatorData: UIActivityIndicatorView!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var addBtnView: UIView!
    var faicon  = [String: UniChar]()
    var WS_Obj : WebServiceClass = WebServiceClass()
    
    var openedComplaints : ModelComplaintsData?
    var resolvedComplaints : ModelComplaintsData?
    
    var subCategory:String!
    var number:String!
    var state:String!
    var imageLbl:String!
    var tempStr:String?
    
    var complaintId:String!
    var subCategoryState:String!
    var FlatIDString:String!
    var OpenORClosed: NSString = "open"
    var PendingAPIPageNo:Int!
    var ResolvedAPIPageNo:Int!
    var PendingAPI_Total:Int!
    var ResolvedAPI_Total:Int!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //    var WS_Obj : WebServiceClass = WebServiceClass()
    
    var categoryDisctionary: JSON = JSON(0)
    var Category : Array<JSON> = Array()
    
    //    var categoryDictionary: Array<JSON> = Array()
    
    
    //    var selectedImage: UILabel!
    var selectedPriority: String!
    var selectedShortName: String!
    
    var refreshControl: UIRefreshControl!
    
    var notificationFlag: NSString? = NSString()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        self.tableView_Pending.dataSource = self
        self.tableView_Pending.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading..")
        refreshControl.addTarget(self, action: #selector(pullToRefreshTableView), for:UIControlEvents.valueChanged)
        tableView_Pending.addSubview(refreshControl)
        
        
        DispatchQueue.main.async(execute: {
            //            if(self.isOverlayHide == false){
            self.displayLoader()
            //            }
        })
        
        
        self.navigationController?.navigationBar.isHidden=true
        tableView_Pending.tableFooterView = UIView(frame: CGRect.zero)
        //        tableView_Resolved.tableFooterView = UIView(frame: CGRect.zero)
        //        self.tableView_Resolved.isHidden = true
        self.tableView_Pending.isHidden = false
        //        self.view .bringSubview(toFront: tableView_Pending)
        
        self.addBtnView.layer.zPosition = 1
        self.view.bringSubview(toFront: addBtnView)
        // self.addBtnView.bringSubview(toFront: addBtn)
        
        //        self.addBtn.frame = CGRect(x: addBtn.frame.origin.x, y: addBtn.frame.origin.y, width: (addBtn.frame.width / 2.0), height: (addBtn.frame.height/2.0))
        //        self.addLbl.frame = CGRect(x: addLbl.frame.origin.x, y: addLbl.frame.origin.y, width: (addLbl.frame.width / 2.0), height: (addLbl.frame.height/2.0))
        
        self.addBtn.layer.cornerRadius = 0.5 * addBtn.bounds.size.width
        self.addBtn.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 156.0, blue: 106.0, alpha: 0.0)
        //self.addLbl.layer.cornerRadius = 0.5 * addLbl.bounds.size.width
        
        NotificationCenter.default.addObserver(self, selector: #selector(HelpDeskController_V2.setText), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        
        
        
//        if((self.FromDashboard)?.length > 0)
//        {
//            MenuOrBackImg.image = UIImage(named: "BackImg")
//        }
//        else
//        {
//
//        MenuOrBackImg.image = UIImage(named: "Menu_Icon")
//        }
        
        setMenuItemUnicode()
        setImageToLabel()
        setText()
        
        self.hideOverlayView()
        OpenORClosed = "open"
        PendingAPIPageNo = 1
        ResolvedAPIPageNo = 1
        
        print("Category HelpDesk: \(self.categoryDisctionary)")
        if GeneralMethodClass.isConnectedToNetwork() == true {
            CallHelpDeskPendingAPI()
            
            CallHelpDeskCategoryAPI()
            
            
            let myFlatsDisplayNameDict=(UserDefaults.standard.value(forKey: "FlatDisplayDict") as! NSMutableDictionary)
            // print(myFlatsDisplayNameDict)
            let flatno = UserDefaults.standard.value(forKey: "mySelectedFlatNo") as? NSString
            if(flatno?.length>0){
                headerLbl?.text = myFlatsDisplayNameDict.value(forKey: flatno as! String) as? String
            }else{
                headerLbl?.text=""
            }
        }
        else{
            displayNoData()
            self.noDataLbl.text = "Please check your internet connection".localized()
            let alert = UIAlertController(title: "Connection error".localized(), message: "Please check your internet connection.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pullToRefreshTableView()  {
        
        CallHelpDeskPendingAPIUpdate()
        //            self.refreshControl?.endRefreshing()
    }
    
    func reloadViewData(notification : Notification) {
        print("reloadViewData called")
        print("From helpdeskchat\(notification)")
        //        CallHelpDeskChatHistoryAPI()
        
        let newNotificationData = JSON(notification.userInfo)["aps"]["data"]["notification"].dictionary
        
        
        DispatchQueue.main.async(execute: {
            self.CallHelpDeskPendingAPIUpdate()
        })
        
        
        self.tableView_Pending.reloadData()
        
    }
    
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        if let testSelected = tableView_Pending.indexPathForSelectedRow {
            tableView_Pending.deselectRow(at: testSelected, animated: true)
        }
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HelpDeskController_V2.reloadViewData), name: NSNotification.Name(rawValue: "NewComplaint"), object: nil)
        
        //        if GeneralMethodClass.isConnectedToNetwork() == true{
        //
        //            DispatchQueue.main.async(execute: {
        //                self.displayLoader()
        //            })
        //
        //            self.PendingAPIPageNo = 1
        //            self.openedComplaints?.arrayComplaints.removeAll()
        //            tableView_Pending.reloadData()
        //            CallHelpDeskPendingAPI()
        //
        ////            self.ResolvedAPIPageNo = 1
        //////            self.resolvedComplaints?.arrayComplaints.removeAll()
        //////            tableView_Resolved.reloadData()
        ////            CallHelpDeskResolvedAPI()
        //        }
        //        else
        //        {
        //            print("Internet connection FAILED")
        //            self.displayNoData()
        //            self.noDataLbl.text="Please check your internet connection.".localized()
        //        }
    }
    
    func setImageToLabel(){
        //        openLbl.font = UIFont(name: "botsworth", size: 18)
        //        openLbl.text = String(format: "%C",faicon["Unlock"]!)
        //        openLbl.textColor = UIColor.white
        //        closeLbl.font = UIFont(name: "botsworth", size: 18)
        //        closeLbl.text = String(format: "%C",faicon["Lock"]!)
        //        closeLbl.textColor = UIColor.white
        //        addLbl.font = UIFont(name: "botsworth", size: 40)
        //        addLbl.text = String(format: "%C",faicon["Add"]!)
        //        addLbl.textColor = UIColor.white
        // addLbl.backgroundColor = UIColor.red
    }
    
    func setMenuItemUnicode(){
        faicon["Lock"] = 0xe615
        faicon["Unlock"] = 0xe61d
        faicon["Add"] = 0xe60c
        faicon["Electricity"]=0xe602
        faicon["Civil Work"]=0xe611
        faicon["Water"]=0xe60b
        faicon["Cable TV"]=0xe604
        faicon["Billing"]=0xe60d
        faicon["Infra"]=0xe613
        faicon["IT"]=0xe612
        faicon["Others"]=0xe616
    }
    
    //    MARK: HelpDesk API Call
    
    func CallHelpDeskPendingAPI(){
        
        
        
        let urlString = NSString(format: "cms/complaints?page=%d&state=Pending",self.PendingAPIPageNo) as String
        WS_Obj.WebAPI_WithOut_Body(urlString, RequestType: "GET"){(responce) in
            
            DispatchQueue.main.async(execute: {
                
                self.hideOverlayView()
                
                if(responce["Error"] != JSON.null)
                {
                    //                    let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                    //                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
                    //                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else if(responce["message"] == JSON.null){
                    print("Omkar.... Open Response Received")
                    if(responce["data"]["complaints"].array?.count > 0)
                    {
                        if self.PendingAPIPageNo > 1 {
                            var gotData = ModelComplaintsData.init(withData: responce)
                            self.openedComplaints?.arrayComplaints = (self.openedComplaints?.arrayComplaints)! + gotData.arrayComplaints
                        }
                        else{
                            self.openedComplaints = ModelComplaintsData.init(withData: responce)
                        }
                    }
                    if(responce["data"]["total"] != JSON.null)
                    {
                        self.PendingAPI_Total = responce["data"]["total"].int
                    }
                    
                    if (self.openedComplaints?.arrayComplaints.count == 0 || self.openedComplaints?.arrayComplaints.count == nil)
                    {
                        
                        self.displayNoData()
                        self.noDataLbl.text="No data found.".localized()
                        
                    }
                    //                    else
                    //                    {
                    //                        self.hideOverlayView()
                    //                    }
                    
                    self.tableView_Pending.reloadData()
                }
                else{
                    let alert = UIAlertController(title: "Alert".localized(), message: "Login token expired, Please login again.".localized(), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    func CallHelpDeskPendingAPIUpdate(){
        
        self.PendingAPIPageNo = 1
        let urlString = NSString(format: "cms/complaints?page=%d&state=Pending",self.PendingAPIPageNo) as String
        WS_Obj.WebAPI_WithOut_Body(urlString, RequestType: "GET"){(responce) in
            
            DispatchQueue.main.async(execute: {
                
                self.hideOverlayView()
                
                if(responce["Error"] != JSON.null)
                {
                    //                    let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                    //                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
                    //                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else if(responce["message"] == JSON.null){
                    print("Omkar.... Open Response Received")
                    if(responce["data"]["complaints"].array?.count > 0)
                    {
                        self.openedComplaints = ModelComplaintsData.init(withData: responce)
                    }
                    if(responce["data"]["total"] != JSON.null)
                    {
                        self.PendingAPI_Total = responce["data"]["total"].int
                    }
                    
                    if (self.openedComplaints?.arrayComplaints.count == 0 || self.openedComplaints?.arrayComplaints.count == nil)
                    {
                        
                        self.displayNoData()
                        self.noDataLbl.text="No data found.".localized()
                        
                    }
                    //                    else
                    //                    {
                    //                        self.hideOverlayView()
                    //                    }
                    
                    self.tableView_Pending.reloadData()
                    print("Removing refresh")
                    self.refreshControl?.endRefreshing()
                    
                }
                else{
                    let alert = UIAlertController(title: "Alert".localized(), message: "Login token expired, Please login again.".localized(), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    
    //    func CallHelpDeskResolvedAPI(){
    //
    //        let urlString = NSString(format: "cms/complaints?page=%d&state=Resolved",self.ResolvedAPIPageNo) as String
    //        WS_Obj.WebAPI_WithOut_Body(urlString, RequestType: "GET"){(responce) in
    //
    //            DispatchQueue.main.async(execute: {
    //                self.hideOverlayView()
    //
    //                if(responce["Error"] != JSON.null)
    //                {
    //
    //                    //                    let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
    //                    //                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
    //                    //                    self.presentViewController(alert, animated: true, completion: nil)
    //                }
    //                else if(responce["message"] == JSON.null){
    //
    //                    print("Omkar.... Closed Response Received")
    //
    //                    if (responce["data"]["complaints"].array?.count > 0)
    //                    {
    //                        self.resolvedComplaints = ModelComplaintsData.init(withData:responce)
    //                    }
    //
    //                    if (responce["data"]["total"] != JSON.null)
    //                    {
    //                        self.ResolvedAPI_Total = responce["data"]["total"].int
    //                    }
    //
    //                    if (self.resolvedComplaints?.arrayComplaints.count == 0)
    //                    {
    //                        self.displayNoData()
    //                        self.noDataLbl.text="No data found.".localized()
    //
    //                    }
    //                    else
    //                    {
    //                        self.hideOverlayView()
    //                    }
    //                    self.CallHelpDeskPendingAPI()
    //                    self.tableView_Pending.reloadData()
    //                }
    //                else
    //                {
    //                    let alert = UIAlertController(title: "Alert".localized(), message: "Login token expired, Please login again.".localized(), preferredStyle: UIAlertControllerStyle.alert)
    //                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
    //                    self.present(alert, animated: true, completion: nil)
    //                }
    //            })
    //        }
    //    }
    
    
    //    MARK: - Tableview Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView_Pending == tableView)
        {
            return self.openedComplaints?.arrayComplaints.count ?? 0
        }
        else  if(tableView_Resolved == tableView)
        {
            return self.resolvedComplaints?.arrayComplaints.count ?? 0
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //        if(tableView_Pending == tableView)
        //        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HelpDeskTableViewCell
        
        cell.titleLabel?.text = self.openedComplaints?.arrayComplaints[indexPath.row].subCategoryName
        cell.titleLabel.font = UIFont(name: "Arial", size: 15.0)
        
        cell.descriptionLabel?.text = self.openedComplaints?.arrayComplaints[indexPath.row].description.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        cell.descriptionLabel.font = UIFont(name: "Arial", size: 13.0)
        
        
        //proiority and category Initial
        var priority = self.openedComplaints?.arrayComplaints[indexPath.row].priority
        
        var str:Int?
        str = self.openedComplaints?.arrayComplaints[indexPath.row].number
        cell.countLabel?.text=NSString(format: "# %d", str!) as String
        
        //            cell.imageLabel?.font = UIFont(name: "botsworth", size: 30)
        tempStr = self.openedComplaints?.arrayComplaints[indexPath.row].complaintCategoryName
        
        
        
        cell.imageLabel.layer.masksToBounds = true
        cell.imageLabel.layer.cornerRadius = 0.5 * cell.imageLabel.bounds.size.width
        cell.imageLabel.font = UIFont(name: "Arial", size: 15)
        cell.imageLabel.textColor = UIColor.white
        cell.imageLabel.backgroundColor = getPriorityColor(priority: priority!)
        cell.imageLabel.text = self.openedComplaints?.arrayComplaints[indexPath.row].category_short_name
        
        //            if(tempStr == "Electrical"){
        //                cell.imageLabel.backgroundColor = getPriorityColor()
        //                cell.imageLabel.text = "CL"
        //            }
        //            else if(tempStr == "Civilwork"){
        //                cell.imageLabel.backgroundColor = UIColor.red
        //                cell.imageLabel.text = "CL"
        //            }
        //            else if(tempStr == "Water"){
        //                cell.imageLabel.backgroundColor = UIColor.red
        //                cell.imageLabel.text = "CL"
        //            }
        //            else if(tempStr == "Cable TV"){
        //                cell.imageLabel.backgroundColor = UIColor.red
        //                cell.imageLabel.text = "CL"
        //            }
        //            else if(tempStr == "Citizen’s Billing"){
        //                cell.imageLabel.backgroundColor = UIColor.red
        //                cell.imageLabel.text = "CL"
        //            }
        //            else if(tempStr == "Infra Complaint"){
        //                cell.imageLabel.backgroundColor = UIColor.red
        //                cell.imageLabel.text = "CL"
        //            }
        //            else if(tempStr == "IT"){
        //                cell.imageLabel.backgroundColor = UIColor.red
        //                cell.imageLabel.text = "CL"
        //            }
        //            else{
        //                cell.imageLabel.backgroundColor = UIColor.red
        //                cell.imageLabel.text = "CL"
        //            }
        
        cell.ComplaintIDLbl?.text = self.openedComplaints?.arrayComplaints[indexPath.row].id
        cell.statusLbl?.text = self.openedComplaints?.arrayComplaints[indexPath.row].aasmState
        
        return cell
        //        }
        //        else
        //        {
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HelpDeskTableViewCell
        //
        //            cell.titleLabel?.text = self.resolvedComplaints?.arrayComplaints[indexPath.row].subCategoryName
        //            cell.titleLabel.font = UIFont(name: "Arial-BoldMT", size: 15.0)
        //
        //            cell.descriptionLabel?.text = self.resolvedComplaints?.arrayComplaints[indexPath.row].description
        //            cell.descriptionLabel.font = UIFont(name: "Arial-BoldMT", size: 13.0)
        //
        //            var str:Int?
        //
        //            str = self.resolvedComplaints?.arrayComplaints[indexPath.row].number
        //            cell.countLabel?.text=NSString(format: "# %d", str!) as String
        //
        //            cell.imageLabel?.font = UIFont(name: "botsworth", size: 30)
        //
        //            tempStr = self.resolvedComplaints?.arrayComplaints[indexPath.row].complaintCategoryName
        //            if(tempStr == "Electrical") {
        //                cell.imageLabel?.text = String(format: "%C",faicon["Electricity"]!)
        //            }
        //            else if(tempStr == "Civilwork") {
        //                cell.imageLabel?.text = String(format: "%C",faicon["Civil Work"]!)
        //            }
        //            else if(tempStr == "Water") {
        //                cell.imageLabel?.text = String(format: "%C",faicon["Water"]!)
        //            }
        //            else if(tempStr == "Cable TV") {
        //                cell.imageLabel?.text = String(format: "%C",faicon["Cable TV"]!)
        //            }
        //            else if(tempStr == "Citizen’s Billing") {
        //                cell.imageLabel?.text = String(format: "%C",faicon["Billing"]!)
        //            }
        //            else if(tempStr == "Infra Complaint") {
        //                cell.imageLabel?.text = String(format: "%C",faicon["Infra"]!)
        //            }
        //            else if(tempStr == "IT") {
        //                cell.imageLabel?.text = String(format: "%C",faicon["IT"]!)
        //            }
        //            else{
        //                cell.imageLabel?.text = String(format: "%C",faicon["Others"]!)
        //            }
        //
        //            cell.ComplaintIDLbl?.text = self.resolvedComplaints?.arrayComplaints[indexPath.row].id
        //            cell.statusLbl?.text = self.resolvedComplaints?.arrayComplaints[indexPath.row].aasmState
        //
        //            return cell
        //        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        if(OpenORClosed == "open")
        //        {
        //            print(self.PendingAPI_Total)
        //            print(self.openedArr.count)
        
        //            if(indexPath.row + 1 == self.openedComplaints?.arrayComplaints.count ?? 0 )
        //            {
        ////                DispatchQueue.main.async(execute: {
        ////                    self.displayLoader()
        ////                })
        //                PendingAPIPageNo = PendingAPIPageNo+1
        //                self.CallHelpDeskPendingAPIUpdate()
        //
        //            }
        
        let lastElement = (self.openedComplaints?.arrayComplaints.count)! - 1
        if indexPath.row == lastElement && PendingAPI_Total > self.openedComplaints?.arrayComplaints.count {
            // handle your logic here to get more items, add it to dataSource and reload tableview
            
            PendingAPIPageNo = PendingAPIPageNo+1
            self.CallHelpDeskPendingAPI()
        }
        
        //        }
        //        else if(OpenORClosed == "close")
        //        {
        //            if(self.resolvedComplaints?.arrayComplaints.count ?? 0 - 1 == (indexPath as NSIndexPath).row && self.ResolvedAPI_Total > self.resolvedComplaints?.arrayComplaints.count ?? 0)
        //            {
        //                DispatchQueue.main.async(execute: {
        //                    self.displayLoader()
        //                })
        //                ResolvedAPIPageNo = ResolvedAPIPageNo+1
        //                self.CallHelpDeskResolvedAPI()
        //            }
        //        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var stateStr:String?
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath) as! HelpDeskTableViewCell!
        
        subCategory = currentCell?.titleLabel.text
        number = currentCell?.countLabel.text
        complaintId = currentCell?.ComplaintIDLbl.text
        subCategoryState = currentCell?.statusLbl.text
        
        
        var temp:String!
        if(currentCell?.imageLabel?.text == String(format: "%C",faicon["Electricity"]!)){
            temp = "Electrical"
        }
        else if(currentCell?.imageLabel?.text == String(format: "%C",faicon["Civil Work"]!)){
            temp = "Civilwork"
        }
        else if(currentCell?.imageLabel?.text == String(format: "%C",faicon["Water"]!)){
            temp = "Water"
        }
        else if(currentCell?.imageLabel?.text == String(format: "%C",faicon["Cable TV"]!)){
            temp = "Cabletv"
        }
        else if(currentCell?.imageLabel?.text == String(format: "%C",faicon["Billing"]!)){
            temp = "Billing"
        }
        else if(currentCell?.imageLabel?.text == String(format: "%C",faicon["Infra"]!)){
            temp = "Infra"
        }
        else if(currentCell?.imageLabel?.text == String(format: "%C",faicon["IT"]!)){
            temp = "IT"
        }
        else{
            temp = "Others"
        }
        imageLbl = temp
        
        //        selectedImage = currentCell?.imageLabel!
        self.selectedPriority = self.openedComplaints?.arrayComplaints[indexPath.row].priority
        self.selectedShortName  = self.openedComplaints?.arrayComplaints[indexPath.row].category_short_name
        
        
        if(tableView_Pending == tableView)
        {
            FlatIDString = self.openedComplaints?.arrayComplaints[indexPath.row].unitInfo
            stateStr = self.openedComplaints?.arrayComplaints[indexPath.row].aasmState
        }
        else
        {
            stateStr = self.resolvedComplaints?.arrayComplaints[indexPath.row].aasmState
            FlatIDString = self.resolvedComplaints?.arrayComplaints[indexPath.row].unitInfo
        }
        
        //        if(closeBtnView.backgroundColor == UIColor.red)
        //        {
        //            self.performSegue(withIdentifier: "HelpDeskChat", sender: self)
        //        }
        //        else
        //        {
        if(stateStr=="resolved")
        {
            self.performSegue(withIdentifier: "HelpDeskFeedback", sender: self)
        }
        else
        {
            self.performSegue(withIdentifier: "HelpDeskChat", sender: self)
        }
        //      }
    }
    
    
    // MARK: Localized Text
    
    func setText()
    {
        // headerLbl.text = "Helpdesk".localized();
        //        openLblTxt.text = "Open".localized();
        //        closeLblTxt.text = "Closed".localized();
        //openLblTxt.setTitle("Open".localized(), forState: UIControlState.Normal)
        //closeLblTxt.setTitle("Closed".localized(), forState: UIControlState.Normal)
    }
    
    // MARK: - Navigation
    @IBAction func AddTapped(_ sender: AnyObject) {
        //        self.performSegue(withIdentifier: "Go2HelpDeskCategory", sender: nil)
        
        self.performSegue(withIdentifier: "new_Complaint", sender: nil)
    }
    
    @IBAction func openBtnTapped(_ sender: AnyObject) {
        OpenORClosed = "open"
        
        if GeneralMethodClass.isConnectedToNetwork() == true{
            self.hideOverlayView()
            if self.openedComplaints?.arrayComplaints.count == 0{
                self.displayNoData()
                self.noDataLbl.text="No data found.".localized()
                
            }else
            {
                self.hideOverlayView()
                self.tableView_Resolved.isHidden = true
                self.tableView_Pending.isHidden = false
                //                self.view .bringSubview(toFront: tableView_Pending)
            }
        }
        else
        {
            print("Internet connection FAILED")
            self.displayNoData()
            self.noDataLbl.text="Please check your internet connection.".localized()
        }
        
        
        //        openBtnView.backgroundColor = UIColor.red
        //        closeBtnView.backgroundColor = UIColor.lightGray
        self.tableView_Pending.reloadData()
    }
    
    @IBAction func closeBtnTapped(_ sender: AnyObject) {
        
        OpenORClosed = "close"
        closeBtnView.backgroundColor = UIColor.red
        openBtnView.backgroundColor = UIColor.lightGray
        
        if GeneralMethodClass.isConnectedToNetwork() == true{
            self.hideOverlayView()
            if self.resolvedComplaints?.arrayComplaints.count == 0{
                self.displayNoData()
                self.noDataLbl.text="No data found.".localized()
                
            }else
            {
                self.hideOverlayView()
                self.tableView_Resolved.isHidden = false
                self.tableView_Pending.isHidden = true
                //                self.view .bringSubview(toFront: tableView_Resolved)
            }
        }
        else
        {
            print("Internet connection FAILED")
            self.displayNoData()
            self.noDataLbl.text="Please check your internet connection.".localized()
        }
        
        self.tableView_Resolved.reloadData()
    }
    
    
    // MARK: - Navigation
    @IBAction func BackBtnTapped(_ sender: AnyObject)
    {
        print("Back button tapped")
//        if((self.FromDashboard)?.length > 0)
//        {
//            if self.notificationFlag == "YES"
//            {
//                print("From Notification")
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//
//                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoard") as! DashBoardController
//                //                nextViewController.FromDashboard = "YES"
//                self.present(nextViewController, animated:true, completion:nil)
//            }
//            else
//            {
//                print("Not Notification")
//                self.FromDashboard = ""
//                _ = self.navigationController?.popViewController(animated: true)
//            }
//        }
//        else
//        {
            toggleLeft()
//        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        var state:String!
        if(segue.identifier == "HelpDeskChat") {
            let chatVC = segue.destination as! HelpDeskChatController

            chatVC.StringCategorySubject = subCategory
            chatVC.StringNumber = number
            chatVC.StringImg = imageLbl
            chatVC.StringComplaintID = complaintId
            chatVC.StringState = subCategoryState
            chatVC.OpenORClosed = OpenORClosed as String
            chatVC.gotPriority = self.selectedPriority
            chatVC.gotShortName = self.selectedShortName
            //            chatVC.notificationFlag = false
            chatVC.FromWhere = "OpenClosedList"

        }
//        else if(segue.identifier == "HelpDeskFeedback"){
//            let feedBackVC = segue.destination as! FeedbackController
//
//            feedBackVC.StringCategorySubject = subCategory
//            feedBackVC.StringNumber = number
//            feedBackVC.StringState = subCategoryState
//            feedBackVC.StringComplaintID = complaintId
//            feedBackVC.StringFlatID = FlatIDString
//        }
//        else if(segue.identifier == "Go2HelpDeskCategory"){
//
//        }
//        else if(segue.identifier == "view_history"){
//            let historyVC = segue.destination as! HelpDeskHistoryViewController
//
//            historyVC.resolvedComplaints = self.resolvedComplaints
//        }
//        else if(segue.identifier == "new_Complaint"){
//            print("Calling new_complaint")
//            let newComplaintVC = segue.destination as! HelpDeskNewComplaintViewController
//            newComplaintVC.categoryDisctionary = self.categoryDisctionary
//        }
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
        self.activityIndicatorData.isHidden = false;
        self.noDataLbl.isHidden = true;
        self.noDataButton.isHidden = true;
    }
    
    func displayNoData() {
        self.overLayView.isHidden = false;
        self.activityIndicatorData.isHidden = true;
        self.noDataLbl.isHidden = false;
        self.noDataButton.isHidden = false;
    }
    
    func hideOverlayView() {
        print("hide overlay called")
        self.overLayView.isHidden = true;
    }
    
    @IBAction func histroryTapped(_ sender: Any) {
//        self.performSegue(withIdentifier: "view_history", sender: self)
    }
    
    func getPriorityColor(priority: String) -> UIColor {
        var color: UIColor!
        switch priority {
        case "Regular":
            color = UIColor(red:0.26, green:0.55, blue:0.79, alpha:1.0)
            break
        case "High":
            color = UIColor(red:0.85, green:0.33, blue:0.31, alpha:1.0)
            break
        case "Medium":
            color = UIColor(red:0.94, green:0.68, blue:0.31, alpha:1.0)
            break
        case "Low":
            color = UIColor(red:0.142, green:0.142, blue:0.142, alpha:0.5)
            break
        default:
            color = UIColor.black
            
        }
        return color
    }
    
    
    func CallHelpDeskCategoryAPI(){
        self.hideOverlayView()
        let urlString = NSString(format: "cms/categories") as String
        
        WS_Obj.WebAPI_WithOut_Body_V2(urlString, RequestType: "GET"){(responce) in
            
            DispatchQueue.main.async(execute: {
                
                
                if(responce["message"] == JSON.null){
                    self.categoryDisctionary = responce
                    self.appDelegate.helpResponceDic = self.categoryDisctionary
                    print(self.categoryDisctionary)
                    self.Category = self.categoryDisctionary["categories"].array!
                    
                    DispatchQueue.main.async(execute: {
                        
                        if (self.Category.count==0){
                            //                            self.displayNoData()
                            //                            self.noDataLbl.text = "No data found.".localized()
                            print("No data foud")
                        }else{
                            //                            self.hideOverlayView()
                            print("Category Data: \(self.categoryDisctionary)")
                            print("count:\(self.Category.count)")
                        }
                        //                        self.collectionView.reloadData()
                    })
                }
                else{
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "Alert".localized(), message: "Login token expired, Please login again.".localized(), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            })
        }
    }
    
    
    
    //    func circularLayer(view: UIView) -> CALayer {
    //        let circlePath2 = UIBezierPath(arcCenter: CGPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y, radius: CGFloat(30), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
    //
    //        let shapeLayer2 = CAShapeLayer()
    //        shapeLayer2.path = circlePath2.cgPath
    //
    //        //change the fill color
    //        shapeLayer2.fillColor = UIColor.clear.cgColor
    //        //you can change the stroke color
    //        shapeLayer2.strokeColor = UIColor.black.cgColor
    //        //you can change the line width
    //        shapeLayer2.lineWidth = 1.0
    //
    //        return shapeLayer2
    //    }
    
}

