//
//  LeftMenuController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 20/09/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import Localize_Swift
import SwiftyJSON
import SlideMenuControllerSwift
import SDWebImage


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


class LeftMenuController: UIViewController ,UITableViewDelegate,UITableViewDataSource, SlideMenuControllerDelegate {
    @IBOutlet weak var menuTableView: UITableView!
//    @IBOutlet weak var companyLogoImage: UIImageView!
    @IBOutlet weak var profilePicButton: UIButton!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var loggedInUserLbl: UILabel!
    @IBOutlet var lblFlatNo: UILabel? = UILabel()
    @IBOutlet var btnSwitchList: UIButton? = UIButton()
    @IBOutlet weak var arrowImage: UIImageView!
//    @IBOutlet weak var menuItemImage: UILabel!
    var WS_Obj : WebServiceClass = WebServiceClass()
    
    var menuArray: Array<String> = []
    var faicon  = [String: UniChar]()
    //var myFlatsArray: NSMutableArray? = NSMutableArray()
    var myFlatsArray: Array<String> = []
    var myFlatsDisplayNameDict : NSMutableDictionary? = NSMutableDictionary()
    var dictionaryEnabledPolicies : NSMutableDictionary? = NSMutableDictionary()
    
    var OperationArray: Array<String> = []
    var VisibleList: NSString? = NSString()  //FlatNoList or MainOptionList
    var SelectedView: NSString? = NSString()  //FlatNoList or MainOptionList
    var Dictionary: NSDictionary? = NSDictionary()
    
//    var sensorcontroller: UIViewController!
//    var electricitycontroller: UINavigationController!
//    var watercontroller: UINavigationController!
//    var eWalletcontroller: UIViewController!
    var helpdeskController: UIViewController!
//    var plannercontroller: UIViewController!
    var notificationcontroller: UIViewController!
    var profilecontroller: UIViewController!
    
    let availableLanguages = Localize.availableLanguages()
    var actionSheet: UIAlertController!
    
    var isTownnShipLogin = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let policyData = GeneralMethodClass.getUserData()!["policy"] as! NSDictionary
        isTownnShipLogin = (policyData["company_type"] ?? "township") as? String != "industrial"
        
        menuTableView.tableFooterView = UIView(frame: .zero)
        
        
        self.profilePicButton.layer.cornerRadius = 0.5 * self.profilePicButton.bounds.size.width
        self.profilePicButton.clipsToBounds = true
        self.loggedInUserLbl.text  = GeneralMethodClass.Get_Current_UserName() as String
        
        self.companyName.text = GeneralMethodClass.Get_Current_companyName() as String
        
        //        if GeneralMethodClass.Get_Current_company_logoURL() != nil {
        //            let imageUrl = GeneralMethodClass.Get_Current_company_logoURL() as String
        //            self.companyLogoImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "bot_icon_gold.png"))
        //        }
        let imageUrl = ""
//        self.companyLogoImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "bot_icon_gold.png"))
        setBackgroundImage()
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuArray = menu()
        OperationArray = menuArray
        
        SelectedView = "Home"
        
        setMenuItemUnicode()
        setupSidePanelView()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let SensorController = storyboard.instantiateViewController(withIdentifier: "HelpDesk") as! HelpDeskController_V2
//        self.sensorcontroller = UINavigationController(rootViewController: SensorController)
        
                let HelpDeskControl = storyboard.instantiateViewController(withIdentifier: "HelpDesk") as! HelpDeskController_V2
                self.helpdeskController = UINavigationController(rootViewController: HelpDeskControl)
        
                let NotificationControl = storyboard.instantiateViewController(withIdentifier: "Notification") as! NotificationController
                self.notificationcontroller = UINavigationController(rootViewController: NotificationControl)
        
        let ProfileControl = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        self.profilecontroller = UINavigationController(rootViewController: ProfileControl)
        //
        //        let ElectricityControl = storyboard.instantiateViewController(withIdentifier: "Electricity") as! ElectricityController
        //        self.electricitycontroller = UINavigationController(rootViewController: ElectricityControl)
        //
        //        let WaterControl = storyboard.instantiateViewController(withIdentifier: "Water") as! WaterController
        //        self.watercontroller = UINavigationController(rootViewController: WaterControl)
        //
        //        let eWalletControl = storyboard.instantiateViewController(withIdentifier: "eWallet") as! eWalletController
        //        self.eWalletcontroller = UINavigationController(rootViewController: eWalletControl)
        //
        //        let PlannerControl = storyboard.instantiateViewController(withIdentifier: "Planner") as! PlannerController
        //        self.plannercontroller = UINavigationController(rootViewController: PlannerControl)
        
        let Dictionary = GeneralMethodClass.getUserData()
        if(Dictionary != nil)
        {
            //            if GeneralMethodClass.isCurrentLoginForIndustrial() {
            myFlatsArray = Dictionary!.value(forKeyPath: "data.resident.sites.name") as! NSArray as! [String]
            //            }
            //            }
            //            else {
            //                myFlatsArray = Dictionary!.value(forKeyPath: "data.user.units.name") as! NSArray as! [String]
            //            }
            myFlatsDisplayNameDict=(UserDefaults.standard.value(forKey: "FlatDisplayDict") as! NSMutableDictionary)
        }
        
        //        myFlatsArray.append("Sign Out")
        
        let flatno = UserDefaults.standard.value(forKey: "mySelectedFlatNo") as? NSString
        if(flatno?.length>0){
            lblFlatNo?.text = myFlatsDisplayNameDict?.value(forKey: flatno as! String) as? String
        }else{
            lblFlatNo?.text=""
        }
        
        self.slideMenuController()?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setText"), name: LCLLanguageChangeNotification, object: nil)
    }
    
    func leftWillOpen() {
        VisibleList = "FlatNoList"
        self.SwitchList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SwitchList(){
        
        //        var imageArrow = UIImage(named: "bw_button_aero_gray-1")
        //        self.arrowImage.image  = imageArrow
        
        if VisibleList=="FlatNoList"
        {
            VisibleList = "MainOptionList"
            OperationArray = menuArray
            self.arrowImage.image  = UIImage(named: "white-down-arrow")
            //            self.arrowImage.transform  = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            //            self.arrowImage.image  = imageArrow
            
            //            let arrowDown = sideMenuView.viewWithTag(4) as! UILabel
            //            arrowDown.textColor = UIColor.white
            //            arrowDown.font = UIFont(name: "botsworth", size: 20)
            //            arrowDown.text = String(format: "%C",faicon["angle Down"]!)
        }
        else
        {
            VisibleList = "FlatNoList"
            OperationArray = myFlatsArray
            
            //            imageArrow = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            self.arrowImage.image  = UIImage(named: "white-up-arrow")
            //            self.arrowImage.transform  =CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            
            
            //            let arrowDown = sideMenuView.viewWithTag(4) as! UILabel
            //            arrowDown.textColor = UIColor.white
            //            arrowDown.font = UIFont(name: "botsworth", size: 20)
            //            arrowDown.text = String(format: "%C",faicon["angle Up"]!)
        }
        
        menuTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OperationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        let menuItemImage: UILabel = cell.viewWithTag(3) as! UILabel
        let menuItemName: UILabel = cell.viewWithTag(2) as! UILabel
        
        if cell.viewWithTag(500) != nil {
            cell.viewWithTag(500)?.removeFromSuperview()
        }
        
        if VisibleList == "FlatNoList"
        {
            if((indexPath as NSIndexPath).row == OperationArray.count-1)
            {
                menuItemImage.font = UIFont(name:"botsworth", size: 30)
                let Str="Sign Out"
                menuItemImage.text = String(format: "%C",faicon[Str]!)
                menuItemName.text = OperationArray[indexPath.row]
                menuItemName.text = OperationArray[(indexPath as NSIndexPath).row].localized();
                
            }
            else
            {
                menuItemImage.font = UIFont(name:"botsworth", size: 30)
                let Str="Home"
                menuItemImage.text = String(format: "%C",faicon[Str]!)
                menuItemName.text = OperationArray[indexPath.row]
                let xx = OperationArray[(indexPath as NSIndexPath).row]
                print(xx)
                let xyz = myFlatsDisplayNameDict?.value(forKey: xx) as! String
                menuItemName.text = xyz.localized();
            }
        }
        else
        {
            for view in menuItemImage.subviews{
                view.removeFromSuperview()
            }
            menuItemImage.font = UIFont(name:"botsworth", size: 30)
            let Str=String(format:"%@",OperationArray[(indexPath as NSIndexPath).row])
            if(Str == "Choose Language"){
                menuItemImage.text = String(format: "%C",faicon["Planner"]!)
                let imageName = "ChooseLanguage"
                let image = UIImage(named: imageName)
                let imageView = UIImageView(image: image!)
                
                imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                imageView.tag = 500;
                menuItemImage.addSubview(imageView)
                //                menuItemImage.text = ""
            }
            else{
                menuItemImage.text = String(format: "%C",faicon[Str]!)
            }
            menuItemName.text = OperationArray[(indexPath as NSIndexPath).row].localized();
//            menuItemImage.image = UIImage(named: "sensor")
            //menuItemName.text = OperationArray[indexPath.row]
        }
        print("Print option : \(menuItemName.text)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        SelectedView = OperationArray[(indexPath as NSIndexPath).row] as NSString?
        if VisibleList==""
        {
            
            lblFlatNo?.text = myFlatsDisplayNameDict?.value(forKey: OperationArray[(indexPath as NSIndexPath).row] as String) as? String
            
            let Str = OperationArray[(indexPath as NSIndexPath).row]
            UserDefaults.standard.set(Str, forKey: "mySelectedFlatNo")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateFlatNo"), object:Str)
            
            VisibleList = "FlatNoList"
            closeLeft()
            
            if SelectedView == "Home" || SelectedView == "HelpDesk"
            {
                self.slideMenuController()?.changeMainViewController(self.helpdeskController, close: true)
            }
//            else if SelectedView == "Helpdesk"
//            {
//                self.slideMenuController()?.changeMainViewController(self.helpdeskController, close: true)
//            }
            else if SelectedView == "Notification"
            {
                self.slideMenuController()?.changeMainViewController(self.notificationcontroller, close: true)
            }
            //                else if SelectedView == "Electricity"
            //                {
            //                    self.electricitycontroller.popToRootViewController(animated: false)
            //                    self.slideMenuController()?.changeMainViewController(self.electricitycontroller, close: true)
            //                }
            //                else if SelectedView == "Water"
            //                {
            //                    self.watercontroller.popToRootViewController(animated: false)
            //                    self.slideMenuController()?.changeMainViewController(self.watercontroller, close: true)
            //                }
            //                else if SelectedView == "eWallet"
            //                {
            //                    self.slideMenuController()?.changeMainViewController(self.eWalletcontroller, close: true)
            //                }
            //                else if SelectedView == "Planner"
            //                {
            //                    self.slideMenuController()?.changeMainViewController(self.plannercontroller, close: true)
            //                }
            
        }
        else
        {
            VisibleList = "FlatNoList"
            closeLeft()
            
            SelectedView = OperationArray[(indexPath as NSIndexPath).row] as NSString?
            
            if OperationArray[(indexPath as NSIndexPath).row] == "Home" || OperationArray[(indexPath as NSIndexPath).row] == "Helpdesk"
            {
                self.slideMenuController()?.changeMainViewController(self.helpdeskController, close: true)
            }
                            else if OperationArray[(indexPath as NSIndexPath).row]=="Helpdesk"
                            {
                                self.slideMenuController()?.changeMainViewController(self.helpdeskController, close: true)
                            }
                            else if OperationArray[(indexPath as NSIndexPath).row]=="Notification"
                            {
                                self.slideMenuController()?.changeMainViewController(self.notificationcontroller, close: true)
                            }
                //            else if OperationArray[(indexPath as NSIndexPath).row]=="Electricity"
                //            {
                //                self.electricitycontroller.popToRootViewController(animated: false)
                //                self.slideMenuController()?.changeMainViewController(self.electricitycontroller, close: true)
                //            }
                //            else if OperationArray[(indexPath as NSIndexPath).row]=="Water"
                //            {
                //                self.watercontroller.popToRootViewController(animated: false)
                //                self.slideMenuController()?.changeMainViewController(self.watercontroller, close: true)
                //            }
                //            else if OperationArray[(indexPath as NSIndexPath).row]=="eWallet"
                //            {
                //                self.slideMenuController()?.changeMainViewController(self.eWalletcontroller, close: true)
                //            }
                //            else if OperationArray[(indexPath as NSIndexPath).row]=="Planner"
                //            {
                //                self.slideMenuController()?.changeMainViewController(self.plannercontroller, close: true)
                //            }
                //            else if OperationArray[(indexPath as NSIndexPath).row]=="Choose Language"
                //            {
                //                //self.slideMenuController()?.changeMainViewController(self.plannercontroller, close: true)
                //                self.chooseLanguageTapped(UIButton.self)
                //            }
            else if OperationArray[(indexPath as NSIndexPath).row]=="Sign Out"
            {
                let refreshAlert = UIAlertController(title: "Alert".localized(), message: "Are you sure want to logout?".localized(), preferredStyle: UIAlertControllerStyle.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { (action: UIAlertAction!) in
                    self.Logout()
                }))
                refreshAlert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { (action: UIAlertAction!) in
                }))
                present(refreshAlert, animated: true, completion: nil)
            }
//            VisibleList = ""
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func Logout()
    {
        let ApiName = "/api/sessions/sign_out" as String
        WS_Obj.WebAPI_WithOut_Body(ApiName, RequestType:"DELETE"){(response) in
            var receivedData: JSON = JSON(0)
            receivedData = response
            print(receivedData)
        }
        for key in Array(UserDefaults.standard.dictionaryRepresentation().keys){
            if key != "Push_Notificaiton_Token" && key != "v1.4 b0.6 UpdationStatus" {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginView = storyboard.instantiateViewController(withIdentifier: "logInVC") as? LoginViewController
        let mainViewCon = UINavigationController(rootViewController: loginView!)
        self.view.window?.rootViewController = mainViewCon
    }
    
    
    
    func menu() -> Array<String> {
        let policyData = GeneralMethodClass.getUserData()!["policy"] as! NSDictionary
        
        var menuItems = self.getMenuOrder(forPolicies: policyData["menu"] as! [Dictionary<AnyHashable,Any>])
        //add change pwd
        //        menuItems[menuItems.count-1] = "Change Password"
        //        menuItems.append("Sign Out")
        
        
        if !self.isTownnShipLogin {
            menuItems.removeFirst()
        }
        
        return menuItems
    }
    
    func setBackgroundImage() {
        UIGraphicsBeginImageContext(view.frame.size)
        UIImage(named: "bw_login_bg")!.draw(in: self.sideMenuView.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.sideMenuView.backgroundColor = UIColor(patternImage:image)
    }
    
        func setMenuItemUnicode()
        {
            faicon["Home"] = 0xe606
            faicon["Helpdesk"] = 0xe600
            faicon["Notification"] = 0xe607
            faicon["Electricity"] = 0xE602
            faicon["Water"] = 0xE60B
            faicon["eWallet"] = 0xE60A
            faicon["Planner"] = 0xE62A
            faicon["Sign Out"] = 0xF011
            faicon["angle Up"] = 0xF106
            faicon["angle Down"] = 0xf107
            faicon["ProfilePic"] = 0xE61E
            faicon["Sensors"] = 0xe606
        }
    
    func setupSidePanelView() {
        let homeIcon = sideMenuView.viewWithTag(2) as! UILabel
        homeIcon.textColor = UIColor.white
        homeIcon.font = UIFont(name: "botsworth", size: 20)
        //        homeIcon.text = String(format: "%C",faicon["Home"]!)
        
        let arrowDown = sideMenuView.viewWithTag(4) as! UILabel
        arrowDown.textColor = UIColor.white
        arrowDown.font = UIFont(name: "botsworth", size: 20)
        //        arrowDown.text = String(format: "%C",faicon["angle Down"]!)
        //arrowDown.text = String(format: "%C","xF107")
        
        //        let profilePic = sideMenuView.viewWithTag(1) as! UILabel
        //        profilePic.textColor = UIColor.white
        //        profilePic.font = UIFont(name: "botsworth", size: 50)
        //        profilePic.text = String(format: "%C",faicon["ProfilePic"]!)
    }
    
    @IBAction func chooseLanguageTapped(_ sender: AnyObject) {
        actionSheet = UIAlertController(title: nil, message: "Choose Language".localized(), preferredStyle: UIAlertControllerStyle.actionSheet)
        
        print(availableLanguages)
        
        for language in availableLanguages
        {
            if(language != "Base")
            {
                let displayName = Localize.displayNameForLanguage(language)
                let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    Localize.setCurrentLanguage(language)
                    print(language)
                    if(language == "hi-IN")
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateLanguage"), object:"Hindi")
                        UserDefaults .standard.set("Hindi", forKey: "mySelectedLanguage")
                    }
                    else
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateLanguage"), object:"English")
                        UserDefaults .standard.set("English", forKey: "mySelectedLanguage")
                    }
                    UserDefaults .standard.synchronize()
                    
                })
                actionSheet.addAction(languageAction)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK :- policy based functions
    
    func getMenuOrder(forPolicies policies:[Dictionary<AnyHashable,Any>]) -> [String] {
        var menuObjectNameArray: Array<String> = []
        //        menuObjectNameArray.append("Home")
        
        for policy in policies {
            
            if policy["active"] as! Bool == true {
                switch policy["name"] as! String {
                case "electricity":
                    menuObjectNameArray.append("Electricity")
                    break;
                case "water":
                    menuObjectNameArray.append("Water")
                    break
                case "notification":
                    menuObjectNameArray.append("Notification")
                    break
                case "ewallet":
                    menuObjectNameArray.append("eWallet")
                    break;
                case "payment":
                    menuObjectNameArray.append("eWallet")
                    break;
                case "helpdesk":
                    menuObjectNameArray.append("Helpdesk")
                    break
                case "planner":
                    menuObjectNameArray.append("Planner")
                    break
                case "sensors":
                    menuObjectNameArray.append("Sensors")
                    break
                default:
                    break
                }
            }
            
        }
        //        menuObjectNameArray.append("Choose Language")
//        menuObjectNameArray.append("Sensors")
        //        menuObjectNameArray.append("Sign Out")
        
        return menuObjectNameArray
    }
    
    func setupViewForIndustrial() {
        self.btnSwitchList?.isHidden  = true
        let arrowDown = sideMenuView.viewWithTag(4) as! UILabel
        arrowDown.isHidden = true
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        let refreshAlert = UIAlertController(title: "Alert".localized(), message: "Are you sure want to logout?".localized(), preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { (action: UIAlertAction!) in
            self.Logout()
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    @IBAction func profileAction() {
        closeLeft()
        self.slideMenuController()?.changeMainViewController(self.profilecontroller, close: true)
    }
}
