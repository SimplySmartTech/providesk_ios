//
//  ChangePasswordViewController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 19/12/17.
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

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var changePwd: UIButton!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    var helpdeskController: UIViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var WS_Obj : WebServiceClass = WebServiceClass()
    var subdomain = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=true
        
        activityLoader.isHidden = true
        // Do any additional setup after loading the view.
        
        
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(HideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
    }
    func HideKeyboard() {
        self.view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        currentPassword.text = ""
        newPassword.text = ""
        confirmPassword.text = ""
        self.checkIfFirstLogin()
        self.navTitle.text = "Change Password".localized()
        self.changePwd.setTitle("Submit".localized(), for: UIControlState.normal)
        currentPassword.attributedPlaceholder = NSAttributedString(string: "Current Password".localized(), attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        newPassword.attributedPlaceholder = NSAttributedString(string: "New Password".localized(), attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        confirmPassword.attributedPlaceholder = NSAttributedString(string: "Confirm Password".localized(), attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        currentPassword.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        newPassword.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        confirmPassword.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: Any) {
        
        let firstLogin = UserDefaults.standard.string(forKey: "FirstLogIn")
        if firstLogin == "NO"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let DashBoardContrller = storyboard.instantiateViewController(withIdentifier: "HelpDesk") as! HelpDeskController_V2
            self.helpdeskController = UINavigationController(rootViewController: DashBoardContrller)
            
            self.slideMenuController()?.changeMainViewController(self.helpdeskController, close: true)
        }
        else
        {
            self.alertShow(message: "Please change password for first login")
        }
    }
    func alertShow(message:String) {
        let alert = UIAlertController(title: "Alert".localized(), message: message.localized(), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func checkIfFirstLogin() {
        //        let firstLogin = UserDefaults.standard.string(forKey: "FirstLogIn")
        //        if firstLogin == "NO"{
        backBtn.isEnabled = true
        backImg.isHidden = false
        //        }
        //        else
        //        {
        //            backBtn.isEnabled = false
        //            backImg.isHidden = true
        //        }
    }
    @IBAction func changePasswordAction(_ sender: Any) {
        newPassword.resignFirstResponder();
        confirmPassword.resignFirstResponder();
        currentPassword.resignFirstResponder();
        if (currentPassword.text == "" || currentPassword.text == "" || currentPassword.text == ""){
            self.alertShow(message: "All fields are mandatory")
        }
        else if(currentPassword.text == ""){
            self.alertShow(message: "Please enter Current password")
        }
        else if(newPassword.text == ""){
            self.alertShow(message: "Please enter New password")
        }
        else if(confirmPassword.text == ""){
            self.alertShow(message: "Please enter Confirm password")
        }
        else if(confirmPassword.text != newPassword.text){
            self.alertShow(message: "New password and Confirm password should be same")
        }
        else{
            // Call API
            
            if GeneralMethodClass.isConnectedToNetwork() == true {
                activityLoader.isHidden = false
                self.view.isUserInteractionEnabled = false
                activityLoader.startAnimating()
                print("Internet connection OK")
                let Dictionary = GeneralMethodClass.getUserData()
                var idValue = Dictionary!.value(forKeyPath: String(format:"data.%@.id",GeneralMethodClass.GET_RESPONSE_KEY())) as? String
                let body = String(format: "{\"resident\":{\"current_password\":\"%@\",\"password\":\"%@\",\"password_confirmation\":\"%@\"}}",currentPassword.text!,newPassword.text!,confirmPassword.text!)
                
                
                let urlString = NSString(format: "api/residents/%@/change_password", idValue!) as String
                
                WS_Obj.WebAPI_With_Body(urlString, Body: body, RequestType: "PUT"){(responce) in
                    DispatchQueue.main.async(execute: {
                        
                        if(responce["message"] != JSON.null)
                        {
                            self.activityLoader.isHidden = true
                            self.view.isUserInteractionEnabled = true
                            var message = responce["message"].string!
                            if message.range(of:"success") != nil{
                                // change userdefault
                                
                                let firstLogin = UserDefaults.standard.string(forKey: "FirstLogIn")
                                if firstLogin == "NO"{
                                    self.Logout()
                                }
                                else{
                                    
                                    UserDefaults.standard.set("NO", forKey: "FirstLogIn")
                                    UserDefaults.standard.synchronize()
                                    self.backAction(self)
                                }
                            }
                            else
                            {
                                self.alertShow(message: "Current password is invalid".localized())
                            }
                            print(responce["message"])
                            
                            
                        }
                    })
                }
                
            } else {
                print("Internet connection FAILED")
                let alert = UIAlertController(title: "Connection error".localized(), message: "Please check your internet connection.".localized(), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    // MARK: - Textfield Delegates
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 6 // Bool
        
    }
    
    @IBAction func skipToLogin(_ sender: Any) {
        
        
        UserDefaults.standard.set("NO", forKey: "FirstLogIn")
        UserDefaults.standard.synchronize()
        self.backAction(self)
        
        //        if GeneralMethodClass.isConnectedToNetwork() == true {
        //            activityLoader.isHidden = false
        //            self.view.isUserInteractionEnabled = false
        //            activityLoader.startAnimating()
        //            print("Internet connection OK")
        //            let Dictionary = GeneralMethodClass.getUserData()
        //            var idValue = Dictionary!.value(forKeyPath: "data.resident.id") as? String
        //            let body = String(format: "{\"resident\":{\"current_password\":\"%@\",\"password\":\"%@\",\"password_confirmation\":\"%@\"}}",currentPassword.text!,newPassword.text!,confirmPassword.text!)
        //
        //
        //            let urlString = NSString(format: "api/residents/%@/change_password", idValue!) as String
        //
        //            WS_Obj.WebAPI_With_Body(urlString, Body: body, RequestType: "PUT"){(responce) in
        //                DispatchQueue.main.async(execute: {
        //
        //                    if(responce["message"] != JSON.null)
        //                    {
        //                        self.activityLoader.isHidden = true
        //                        self.view.isUserInteractionEnabled = true
        //                        var message = responce["message"].string!
        //                        if message.range(of:"success") != nil{
        //                            // change userdefault
        //
        //                            let firstLogin = UserDefaults.standard.string(forKey: "FirstLogIn")
        //                            if firstLogin == "NO"{
        //                                self.Logout()
        //                            }
        //                            else{
        //
        //                                UserDefaults.standard.set("NO", forKey: "FirstLogIn")
        //                                UserDefaults.standard.synchronize()
        //                                self.backAction(self)
        //                            }
        //                        }
        //                        else
        //                        {
        //                            self.alertShow(message: "Current password is invalid".localized())
        //                        }
        //                        print(responce["message"])
        //
        //
        //                    }
        //                })
        //            }
        //
        //        } else {
        //            print("Internet connection FAILED")
        //            let alert = UIAlertController(title: "Connection error".localized(), message: "Please check your internet connection.".localized(), preferredStyle: UIAlertControllerStyle.alert)
        //            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
        //            self.present(alert, animated: true, completion: nil)
        //        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField == self.currentPassword{
            self.newPassword .becomeFirstResponder()
        }
        else if textField == self.newPassword
        {
            self.confirmPassword .becomeFirstResponder()
        }
        else
        {
            self.confirmPassword .resignFirstResponder()
        }
        return true
    }
    func Logout()
    {
        let ApiName = "/api/sessions/sign_out" as String
        WS_Obj.WebAPI_WithOut_Body(ApiName, RequestType:"DELETE"){(response) in
            var receivedData: JSON = JSON(0)
            receivedData = response
            print(receivedData)
            
            if (receivedData["message"].stringValue.range(of: "Invalid")) == nil{
                
                for key in Array(UserDefaults.standard.dictionaryRepresentation().keys){
                    if key != "Push_Notificaiton_Token" && key != "v1.4 b0.6 UpdationStatus" && key != "FirstLogIn" {
                        UserDefaults.standard.removeObject(forKey: key)
                    }
                }
                UserDefaults.standard.synchronize()
                
                UserDefaults.standard.set("NO", forKey: "FirstLogIn")
                UserDefaults.standard.synchronize()
                
                self.appDelegate.isUpdateNeededFlag = false
                self.appDelegate.helpResponceDic = JSON(NSNull())
                self.appDelegate.sensorResponceDic = JSON(NSNull())
                self.appDelegate.notificationResponceDic  = JSON(NSNull())
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginView = storyboard.instantiateViewController(withIdentifier: "logInVC") as? LoginViewController
                let mainViewCon = UINavigationController(rootViewController: loginView!)
                self.view.window?.rootViewController = mainViewCon
            }
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

