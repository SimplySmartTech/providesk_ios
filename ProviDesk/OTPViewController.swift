//
//  OTPViewController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 22/09/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import PKHUD


class OTPViewController: UIViewController, UITextFieldDelegate  {
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    @IBOutlet weak var mobileNoLbl: UILabel!
    
    var subdomain = ""
    var residentID = ""
    var mobileNumber = ""


    
    var dashboardcontroller: UIViewController!
    
    var WS_Obj : WebServiceClass = WebServiceClass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("In OTPViewController")
        textField1.addTarget(self, action: #selector(self.textfieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        textField2.addTarget(self, action: #selector(self.textfieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        textField3.addTarget(self, action: #selector(self.textfieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        textField4.addTarget(self, action: #selector(self.textfieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        textField5.addTarget(self, action: #selector(self.textfieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        textField6.addTarget(self, action: #selector(self.textfieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        
        
        self.mobileNoLbl.text = "We've sent an OTP to " + self.mobileNumber

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField1.becomeFirstResponder()
        
    }
    func textfieldDidChange(textField: UITextField)  {
        let text = textField.text
        if text?.utf16.count == 1 {
            switch textField {
            case textField1 : textField2.becomeFirstResponder()
            case textField2 : textField3.becomeFirstResponder()
            case textField3 : textField4.becomeFirstResponder()
            case textField4 : textField5.becomeFirstResponder()
            case textField5 : textField6.becomeFirstResponder()
            case textField6 : textField6.resignFirstResponder()
            default:
                break
            }
        }
        else{
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignFirstResponder()
    }
    
    @IBAction func validateOTPTapped(_ sender: Any) {
        
        if (!self.textField1.hasText || !self.textField2.hasText || !self.textField3.hasText || !self.textField4.hasText || !self.textField5.hasText || !self.textField6.hasText){
            let errorString = "Fields can not be blank"
            self.showAlert(msg: errorString)
        }
        else{
            HUD.show(.progress)
            let otpString1 = self.textField1.text
            let otpString2 = self.textField2.text
            let otpString3 = self.textField3.text
            let otpString4 = self.textField4.text
            let otpString5 = self.textField5.text
            let otpString6 = self.textField6.text
            let otpString = otpString1! + otpString2! + otpString3! + otpString4! + otpString5! + otpString6!
            
            
            print("Otp string is : \(otpString)")
            validateOTPCall(otp: otpString)
        }
    }
    
    func validateOTPCall(otp: String)  {
        
        self.residentID = UserDefaults.standard.object(forKey: "residentID") as! String
        print("Resident ID is : \(self.residentID)")
        
        let apiName = "/api/residents/\(self.residentID)/verify_otp"
        //        }
        //        self.viewActivityLogin.isHidden = false
        let Body = String(format: "otp_code=%@",otp)
        print("Body is : \(Body)")
        
        WS_Obj.WebAPI_With_Body(apiName, Body:Body, RequestType:"POST"){(response) in
//            var receivedData: NSDictionary = NSDictionary()
//            receivedData = response as NSDictionary
            PKHUD.sharedHUD.hide(animated: false)
            print("Login Response \(response)")
            let dictionary = response.dictionaryObject! as NSDictionary

            if(dictionary.value(forKey: "status") as! Int == 200){
                print("response is true 200")
                UserDefaults.standard.set("Yes", forKey: "autoLogIn")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "HelpDesk") as! HelpDeskController_V2
                let mainViewCon = UINavigationController(rootViewController: mainViewController)
                let leftViewController = storyboard.instantiateViewController(withIdentifier: "leftMenu") as! LeftMenuController
                let slideMenuController = SlideMenuController(mainViewController:mainViewCon,leftMenuViewController:leftViewController)
                self.view.window?.rootViewController = slideMenuController
       
//                self.performSegue(withIdentifier: "otpVerified", sender: self)
            }
            else{
                let errorString = "Invalid OTP. Please Enter valid OTP"
                self.clearAllTextFields()
               self.showAlert(msg: errorString)
            }



        }
        
        
//
//        WS_Obj.WebAPI_WithOut_Body(apiName , RequestType: "POST"){(responce) in
//            print("Response OTP : \(responce) " )
//            DispatchQueue.main.async(execute: {
//
//                print("Response OTP : \(responce) " )
//
//                self.performSegue(withIdentifier: "otpScreen", sender: self)
//            })
//        }
    
        
        
    }
    
    func clearAllTextFields(){
        self.textField1.text = ""
        self.textField2.text = ""
        self.textField3.text = ""
        self.textField4.text = ""
        self.textField5.text = ""
        self.textField6.text = ""
        self.textField1.becomeFirstResponder()
        
    }
    
    func showAlert(msg: String)  {
        let alert = UIAlertController(title: "Alert".localized(), message: msg.localized(), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func resendOTP(_ sender: Any) {
        HUD.show(.progress)
        let apiName : String
        
      
        apiName = "/api/residents/\(self.residentID)/send_otp"
  
        
        
        WS_Obj.WebAPI_WithOut_Body(apiName , RequestType: "GET"){(responce) in
            print("Response OTP : \(responce) " )
            DispatchQueue.main.async(execute: {
                self.clearAllTextFields()
                PKHUD.sharedHUD.hide(animated: false)
                print("Response OTP : \(responce) " )
                
//                self.performSegue(withIdentifier: "otpScreen", sender: self)
            })
        }
    }
   

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    

}
