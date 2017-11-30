//
//  LoginViewController.swift
//  BotsWorth
//
//  Created by SimplySmart Technologies Private Limited on 26/03/16.
//  Copyright © 2015 SimplySmart Technologies Private Limited
//

import UIKit
import SlideMenuControllerSwift
import PKHUD
//import Localize_Swift
import Dispatch

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


class LoginViewController: UIViewController,UITextFieldDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource {
    
    //Picker datasource function
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if( self.arrayCompanies.count != 0){
        return self.arrayCompanies.count
        }
        else
        {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        isDisplayingSelectCompany = true
        if (self.arrayCompanies.count != 0){
            return (arrayCompanies[row] as! NSDictionary)["name"] as? String
        }
        else{
            return nil
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectCompanyTextField.text = (arrayCompanies[row] as! NSDictionary)["name"] as? String
        subdomain = ((arrayCompanies[row] as! NSDictionary)["subdomain"] as? String)!
        selctedNumber = row
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    @IBOutlet weak var loginBtn: UIButton!
//    @IBOutlet weak var clickHereBtn: UIButton!
//    @IBOutlet weak var forgotPswdLbl: UILabel!
//    
//    @IBOutlet weak var logInBgImg: UIImageView!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var btnSelectCompany: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var viewLoginContent: UIView!
    @IBOutlet weak var viewCompanyList: UIView!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var viewActivityLogin: UIView!
    @IBOutlet weak var selectCompanyTextField: UITextField!
    
    let selectCompanyPicker = UIPickerView()
    
    var selctedNumber = 0

    
    var activityIndicator = UIActivityIndicatorView()
    var WS_Obj : WebServiceClass = WebServiceClass()
    var arrayCompanies : NSArray = NSArray()
    var isDisplayingCompanyList : Bool = false
    var isDisplayingSelectCompany : Bool = false
    var subdomain = ""
    var residentID = ""
    var activationStatus = 0
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //Setting up pickerview
        self.selectCompanyPicker.delegate = self as UIPickerViewDelegate
        
        let toolBarSelectCompany = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBarSelectCompany.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBarSelectCompany.barStyle = UIBarStyle.blackTranslucent
        
        toolBarSelectCompany.tintColor = UIColor.white
        
        toolBarSelectCompany.backgroundColor = UIColor.black
        
        
        let doneButtonSelectCompany = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Pick your category"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBarSelectCompany.setItems([flexSpace,textBtn,flexSpace,doneButtonSelectCompany], animated: true)
        
        selectCompanyTextField.inputAccessoryView = toolBarSelectCompany
        
        
        
        self.selectCompanyTextField.inputView = selectCompanyPicker
        
        
        
        
        
//        self.setText()
        
        self.navigationController?.isNavigationBarHidden = true
//        btnLogIn.layer.cornerRadius = 6
//        viewActivityLogin.layer.cornerRadius = 6
        
        let imageView = UIImageView()
        let userImg = UIImage(named: "bw_login_user_icon")
        imageView.image = userImg
        imageView.frame = CGRect(x: 0, y: 0, width: 20+10, height: 19);
        imageView.contentMode = UIViewContentMode.scaleAspectFit
//        txtUserName.leftView = imageView;
        txtUserName.tag=1
//        txtUserName.leftViewMode = UITextFieldViewMode.always
//        txtUserName.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        let imageView2=UIImageView()
        let pswrdImg = UIImage(named: "bw_login_lock_icon")
        imageView2.image = pswrdImg
        imageView2.frame = CGRect(x: 0, y: 0, width: 20+10, height: 19);
        imageView2.contentMode = UIViewContentMode.scaleAspectFit
//        txtPassword.leftView = imageView2
//        txtPassword.leftViewMode=UITextFieldViewMode.always
//        txtPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        
        //        let defaults = UserDefaults.standard
        let savedVersion1 = UserDefaults.standard.string(forKey: "Version")
        print("savedVersion1\(savedVersion1)")
        
        let savedVersion = UserDefaults.standard.string(forKey: "lastVersionUpdated")
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as Any
        
        let stringVersion = currentVersion as! String
        
        print("current vrsion:\(stringVersion)")
        if savedVersion != nil {
            if stringVersion  != savedVersion{
                //                self.logout()
                UserDefaults.standard.set(currentVersion, forKey: "lastVersionUpdated")
            }
            
        }
        else
        {
            UserDefaults.standard.set(currentVersion, forKey: "lastVersionUpdated")
        }
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Localized Text
    
//    func setText(){
//        forgotPswdLbl.text = "Forgot your password?".localized();
//        loginBtn.setTitle("Login".localized(), for: UIControlState.normal)
//        clickHereBtn.setTitle("click here".localized(), for: UIControlState.normal)
//    }
    
    //  MARK: - Login Methods
    
    @IBAction func logInTapped(_ sender: AnyObject) {
        txtPassword.resignFirstResponder();
        txtUserName.resignFirstResponder();
        if txtUserName.text=="" || txtPassword.text==""{
            let alert = UIAlertController(title: "Alert".localized(), message: "Please enter username & password.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            if GeneralMethodClass.isConnectedToNetwork() == true {
                print("Internet connection OK")
                self.CallLoginAPIWithSubDomain(subdomain)
            } else {
                print("Internet connection FAILED")
                let alert = UIAlertController(title: "Connection error".localized(), message: "Please check your internet connection.".localized(), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        print("LogIn Button Tapped")
    }
    
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        //        if self.categoryTextField.text == nil{
        //            self.selectedNumber = 0
        //        }
        self.selectCompanyTextField.text = (arrayCompanies[selctedNumber] as! NSDictionary)["name"] as? String
        self.selectCompanyTextField.resignFirstResponder()
        isDisplayingSelectCompany = false
//        categoryTextField.resignFirstResponder()
//        subCategoryTextField.resignFirstResponder()
//        self.subCategoryTextField.text = ""
//        unitTextField.resignFirstResponder()
//        self.selectedCategory = self.categoryTextField.text
//        self.subCategoryNameArray = NSMutableArray()
//        self.subCategoryPicker.reloadAllComponents()
//        reloadSubCategory(selectedCategoryText: selectedCategory)
//        self.subCategoryPicker.reloadAllComponents()
        
        
        
    }
    
    func CallLoginAPIWithSubDomain(_ subdomain : String )
    {
        HUD.show(.progress)
        let UUIDValue = UIDevice.current.identifierForVendor!.uuidString
        let notificationToken = UserDefaults.standard.string(forKey: "Push_Notificaiton_Token") ?? ""
        print("notification token is: Omkar " + notificationToken)
        
        print("UUID: \(UUIDValue)")
        
        let apiName : String
//        subdomain = "pro-demo"
        if subdomain.characters.count > 0 {
            apiName = "api/sessions/sign_in?subdomain=pro-demo" //+ subdomain
        } else {
            if isDisplayingSelectCompany {
                displaySelectCompanyAlert()
                return
            }
            apiName = "api/sessions/sign_in"
        }
        
        print("API Name = \(apiName)")
//        self.viewActivityLogin.isHidden = false
        let Body = String(format: "{\"session\":{\"login\":\"%@\",\"password\":\"%@\",\"device_id\":\"%@\",\"notification_token\":\"%@\",\"os_type\":\"ios\"}}",txtUserName.text!,txtPassword.text!,UUIDValue, notificationToken)
        
        print("Body is : \(Body)")
        
        WS_Obj.WebAPI_For_Login(apiName, Body:Body, RequestType:"POST"){(response) in
            var receivedData: NSDictionary = NSDictionary()
            PKHUD.sharedHUD.hide(animated: false)
            receivedData = response as NSDictionary
            print("Login Response \(receivedData)")
//            self.viewActivityLogin.isHidden = true
            
            if (receivedData .object(forKey: "Error") != nil)
            {
                DispatchQueue.main.async(execute: {
                    
//                    PKHUD.sharedHUD.hide(animated: false) { success in
//
//                        //                        let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
//                        //                        alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
//                        //                        self.presentViewController(alert, animated: true, completion: nil)
//                    }
                })
            }
            else if (receivedData .object(forKey: "company_list") != nil)
            {
                self.arrayCompanies = receivedData.object(forKey: "company_list") as! NSArray;
                self.displaySelectCompany()
            }
            else if (((receivedData .object(forKey: "message")! as AnyObject).isEqual(to: "Signed in successfully.")))
            {
                DispatchQueue.main.async(execute: {
                    
                    //                    print("Recieved data is" , receivedData)
                    
                    let defaults = UserDefaults.standard
                    
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as Any
                    
                    UserDefaults.standard.set(currentVersion, forKey: "lastVersionUpdated")
                    
                    
                    var jsonData : Data?
                    jsonData = GeneralMethodClass.jsonToNSData(receivedData)
                    
                    UserDefaults.standard.set(jsonData, forKey: "UserData")
                    UserDefaults.standard.synchronize()
                    
                    var keyLoginType = "units"
                    if GeneralMethodClass.isCurrentLoginForIndustrial() {
                        keyLoginType = "sites"
                    }
//                    self.appDelegate.isCheckUpdateAPICallNeeded = false
                    if (((receivedData.value(forKeyPath: String(format: "data.resident.%@", keyLoginType)) as? NSArray)?.count) != nil) {
                        let dict = NSMutableDictionary()
                        for i in 0 ..< (receivedData.value(forKeyPath: String(format: "data.resident.%@", keyLoginType)) as! NSArray).count
                        {
                            let value = ((((receivedData.value(forKeyPath: String(format: "data.resident.%@", keyLoginType)) as? NSArray)?.object(at: i))! as AnyObject).value(forKey: "info")) as! String
                            let key = ((((receivedData.value(forKeyPath: String(format: "data.resident.%@", keyLoginType)) as? NSArray)?.object(at: i))! as AnyObject).value(forKey: "name")) as! String
                            dict.setObject(value, forKey: key as NSCopying)
                        }
                        print(dict)
                        UserDefaults.standard.set(dict, forKey: "FlatDisplayDict")
                    }
                    
                    let FlatsArray = receivedData.value(forKeyPath: String(format: "data.resident.%@.name", keyLoginType)) as? NSArray
                    //  let DisplayFlatsArray = receivedData.valueForKeyPath("data.resident.units.info") as? NSArray
                    
                    self.residentID = receivedData.value(forKeyPath: String(format: "data.resident.id")) as! String
                    print("resident ID is  : \(self.residentID)")
                    
                    UserDefaults.standard.set(self.residentID, forKey: "residentID")
                    
                    if(FlatsArray?.count>0){
                        let Str = FlatsArray?.object(at: 0) as? String
                        UserDefaults.standard.set(Str, forKey: "mySelectedFlatNo")
                    }
                    
                    let auth_tokenString = receivedData.value(forKeyPath: "data.resident.auth_token") as! String
                    UserDefaults.standard.set(auth_tokenString, forKey: "Authorization_token")
                    
                    let email_user = receivedData.value(forKeyPath: "data.resident.email") as! String
                    UserDefaults.standard.set(email_user, forKey: "User_Email")
                    
                    let api_keyArray = receivedData.value(forKeyPath: "data.resident.api_key") as! String
                    UserDefaults.standard.set(api_keyArray, forKey: "X-Api-Key")
                    
                    let subdomainLoggedIn = receivedData.value(forKeyPath: "subdomain") as! String
                    UserDefaults.standard.set(subdomainLoggedIn, forKey: "SubDomain")
                    let version = receivedData.value(forKeyPath: "version") as! NSInteger
                    UserDefaults.standard.set(String.init(format:"%d", version), forKey: "Version")
                    
                    let siteID = ((((receivedData.value(forKeyPath: String(format: "data.resident.sites", keyLoginType)) as? NSArray)?.object(at: 0))! as AnyObject).value(forKey: "id")) as! String
                    
                    self.activationStatus = receivedData.value(forKeyPath: "data.resident.active") as! Int
                    
                    print("Site ID : \(siteID)")
                    
                    UserDefaults.standard.set(siteID, forKey: "SiteID")
                    
                    UserDefaults.standard.synchronize()
                    
                    
                    self.Push2DashBoard()
                })
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Alert".localized(), message: "Please enter correct username & password.".localized(), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    // MARK: - Navigation
    
    func Push2DashBoard ()
    {
        print("In Push2DashBoard")
        if activationStatus == 0{
        let apiName : String
//        if subdomain.characters.count > 0 {
//            apiName = "api/sessions/sign_in?subdomain=" + subdomain
//        } else {
//            if isDisplayingSelectCompany {
//                displaySelectCompanyAlert()
//                return
//            }
            apiName = "/api/residents/\(self.residentID)/send_otp"
//        }
        //        self.viewActivityLogin.isHidden = false
//        let Body = String(format: "")
        
        
        WS_Obj.WebAPI_WithOut_Body(apiName , RequestType: "GET"){(responce) in
            print("Response OTP : \(responce) " )
            DispatchQueue.main.async(execute: {
                
                print("Response OTP : \(responce) " )
                
                self.performSegue(withIdentifier: "otpScreen", sender: self)
            })
        }
        }
        else{
 
        let langStr = Locale.current.languageCode
        if langStr == "hi" {
            UserDefaults.standard.set("Hindi", forKey: "mySelectedLanguage")
        } else {
            UserDefaults.standard.set("English", forKey: "mySelectedLanguage")
        }
        UserDefaults.standard.set("Yes", forKey: "autoLogIn")
        UserDefaults.standard.synchronize()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "HelpDesk") as! HelpDeskController_V2
        let mainViewCon = UINavigationController(rootViewController: mainViewController)
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "leftMenu") as! LeftMenuController
        let slideMenuController = SlideMenuController(mainViewController:mainViewCon,leftMenuViewController:leftViewController)
        self.view.window?.rootViewController = slideMenuController
//        let firstLogin = UserDefaults.standard.string(forKey: "FirstLogIn")
//        if firstLogin == "NO"{
//
//        }
//        else
//        {
//            var changePasswordController: UIViewController!
//            let PasswordControl = storyboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordViewController
//            changePasswordController = UINavigationController(rootViewController: PasswordControl)
//            //push to Change Password
//            slideMenuController.changeMainViewController(changePasswordController, close: true)
//        }
        
        }
        
        
    }
    
    // MARK: - Textfield Delegates
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if isDisplayingSelectCompany {
            hideSelectCompany()
        }
        
        guard let text = textField.text else { return true }
        if(txtUserName == textField)
        {
            let newLength = text.utf16.count + string.utf16.count - range.length
            return newLength <= 10 // Bool
        }
        else
        {
            let newLength = text.utf16.count + string.utf16.count - range.length
            return newLength <= 6 // Bool
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField == self.txtUserName{
            self.txtPassword .becomeFirstResponder()
        }
        else {
            self.txtPassword .resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Company List functions
    
    func displaySelectCompany() {
        
        self.viewCompanyList.layer.zPosition = 1;
//        self.btnLogIn.layer.zPosition = 2
        
        isDisplayingSelectCompany = true
//        viewLoginContent.transform = CGAffineTransform(translationX: 0, y: 50 )
        scrollView.frame = CGRect(x: 20, y: 161, width: self.scrollView.frame.width, height: 170)
        viewCompanyList.isHidden = false
        if arrayCompanies.count < 3 {
            tableView.frame = CGRect(x: 0, y: 40, width: tableView.frame.width, height: CGFloat(arrayCompanies.count * 40))
        } else {
            tableView.frame = CGRect(x: 0, y: 40, width: tableView.frame.width, height: 120)
        }
        tableView.reloadData()
        print(self.arrayCompanies)
    }
    
    func hideSelectCompany() {
        isDisplayingSelectCompany = false
        subdomain = ""
//        btnSelectCompany.setTitle("Select Company", for: UIControlState.normal)
//        viewLoginContent.transform = CGAffineTransform.identity
        scrollView.frame = CGRect(x: 20, y: 161, width: self.scrollView.frame.width, height: 120)
        viewCompanyList.isHidden = true
    }
    
    func displaySelectCompanyAlert() {
        let alert = UIAlertController(title: "Alert".localized(), message: "Please select a company.".localized(), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func toggleDisplayCompanyList() {
        isDisplayingCompanyList = !isDisplayingCompanyList
        if isDisplayingCompanyList {
            displayCompanyList()
        } else {
            hideCompanyList()
        }
    }
    
    // MARK: - Table View functions
    
    func displayCompanyList() {
        scrollView.frame = CGRect(x: 20, y: 161, width: self.scrollView.frame.width, height: 320)
        viewCompanyList.frame = CGRect(x: 15, y: 115, width: viewCompanyList.frame.width, height: 168)
    }
    
    func hideCompanyList() {
        scrollView.frame = CGRect(x: 20, y: 161, width: self.scrollView.frame.width, height: 170)
        viewCompanyList.frame = CGRect(x: 15, y: 115, width: viewCompanyList.frame.width, height: 40)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCompanies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CompanySelectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CompanyCell")! as! CompanySelectionTableViewCell
        cell.lblCompany.text = (arrayCompanies[(indexPath as NSIndexPath).row] as! NSDictionary)["name"] as? String
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleDisplayCompanyList()
//        btnSelectCompany.setTitle((arrayCompanies[(indexPath as NSIndexPath).row] as! NSDictionary)["name"] as? String, for: UIControlState())
        subdomain = ((arrayCompanies[(indexPath as NSIndexPath).row] as! NSDictionary)["subdomain"] as? String)!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignFirstResponder()
    }
    
    /*
     MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
