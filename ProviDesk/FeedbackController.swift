//
//  FeedbackController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 23/11/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import PKHUD
import Cosmos
import SwiftyJSON

class FeedbackController: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var BtnSubmit: UIButton!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var flatIdLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var stateImgLbl: UILabel!
    @IBOutlet weak var feedBackContentView: UIView!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var msgContentView: UIView!
    
    @IBOutlet weak var feedbackMsgHeaderLbl: UILabel!
    @IBOutlet weak var NotSatisfiedLbl: UILabel!
    @IBOutlet weak var FeedbackMsgTxt: UITextView!
    @IBOutlet weak var FeedbackNotSatisfiedBtn: UIButton!
    @IBOutlet weak var RatingView: CosmosView!
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var originalY: CGFloat!
    
    var WS_Obj : WebServiceClass = WebServiceClass()
    var faicon  = [String: UniChar]()
    var ResponceDic = JSON(0)
    var StringCategorySubject:String!
    var StringNumber:String!
    var StringState:String!
    var StringComplaintID:String!
    var is_resident_satisfied:String!
    var StringFlatID:String!
    var ButtonTap:Bool? = false
    var tempStar:Double = 1.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        self.originalY = self.feedBackContentView.frame.origin.y
        
        //        self.originalY = self.msgContentView.frame.origin.y
        //        msgContentView
        
        self.headerView.layer.zPosition = 1
        //        self.subjectView.layer.zPosition = 2
        
        RatingView.didTouchCosmos = didTouchCosmos
        RatingView.didFinishTouchingCosmos = didFinishTouchingCosmos
        
        messageView.layer.borderColor = UIColor.red.cgColor
        messageView.layer.borderWidth = 1.0
        BtnSubmit.layer.borderColor = UIColor.red.cgColor
        BtnSubmit.layer.borderWidth = 1.0
        
        subjectLbl.text = StringCategorySubject
        numberLbl.text = StringNumber
        stateLbl.text = StringState
        flatIdLbl.text = StringFlatID
        FeedbackNotSatisfiedBtn.setImage(UIImage(named: "checkbox_normal.png"), for: UIControlState())
        FeedbackNotSatisfiedBtn.tag = 101
        
        self.FeedbackMsgTxt.delegate = self
        self.FeedbackMsgTxt.autocorrectionType = UITextAutocorrectionType.no
        self.FeedbackMsgTxt.text = "Please write your comment.".localized()
        self.FeedbackMsgTxt.textColor = UIColor.lightGray
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedbackController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(FeedbackController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        print(StringFlatID)
        //        print(StringCategorySubject)
        //        print(StringNumber)
        //        print(StringState)
        
        setMenuItemUnicode()
        
        stateImgLbl.font = UIFont(name: "botsworth", size: 15)
        stateImgLbl.text = String(format: "%C",faicon["hourglass"]!)
        stateImgLbl.textColor = UIColor.black
        
        if GeneralMethodClass.isConnectedToNetwork() == true{
            setText()
            print("Internet connection OK")
            self.noDataView.isHidden = true
        }
        else
        {
            print("Internet connection FAILED")
            self.noDataView.isHidden = false
            self.noDataLbl.text="Please check your internet connection.".localized()
        }
        
        headerLbl.text = GeneralMethodClass.getSelectedFlatDisplayName()
        
        //        let flatno = NSUserDefaults.standardUserDefaults().valueForKey("mySelectedFlatNo") as? String
        //        flatIdLbl.text = flatno
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(_ sender: Notification) {
        //        self.view.frame.origin.y = -220
        //       var minusY: CGFloat = self.feedBackContentView.frame.maxY - self.FeedbackMsgTxt.frame.maxY
        
        if let keyboardSize = ((sender as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //            self.feedBackContentView.frame.origin.y -= keyboardSize.height
            
            self.feedBackContentView.frame = CGRect(x: self.feedBackContentView.frame.origin.x, y: originalY - keyboardSize.height, width: self.feedBackContentView.frame.width, height: self.feedBackContentView.frame.height)
        }
    }
    
    func keyboardWillHide(_ sender: Notification) {
        if let keyboardSize = ((sender as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //            self.feedBackContentView.frame.origin.y += keyboardSize.height
            
            self.feedBackContentView.frame = CGRect(x: self.feedBackContentView.frame.origin.x, y: originalY, width: self.feedBackContentView.frame.width, height: self.feedBackContentView.frame.height)
        }
    }
    
    // MARK: Localized Text
    func setText(){
        //        headerLbl.text = "Feedback".localized();
        rateLbl.text = "YOUR RATING".localized();
        feedbackMsgHeaderLbl.text = "FEEDBACK".localized();
        NotSatisfiedLbl.text = "NOT SATISFIED".localized();
        BtnSubmit.setTitle("Submit".localized(), for: UIControlState.normal)
    }
    func setMenuItemUnicode(){
        faicon["Electricity"]=0xe602
        faicon["Civil Work"]=0xe611
        faicon["Water"]=0xe60b
        faicon["Cable TV"]=0xe604
        faicon["Billing"]=0xe60d
        faicon["Infra"]=0xe613
        faicon["IT"]=0xe612
        faicon["Others"]=0xe616
        faicon["Home"]=0xe606
        faicon["icon_send"]=0xe619
        faicon["hourglass"]=0xe61c
        
    }
    //  MARK:  CallSubmit/closed feedback
    func CallSubmitFeedback(){
        HUD.show(.progress)
        
        let selfComplaint = FeedbackMsgTxt.text! as String
        var urlString=String()
        var body=String()
        
        // state == Reject, not satified = check , is_resident_satisfied = False
        // state == Closed, not satified = uncheck , is_resident_satisfied = true
        
        urlString = String(format: "cms/complaints/%@/close_complaint",StringComplaintID)
        
        if(ButtonTap == false)
        {
            body = String(format: "complaint[state_action]=Close&complaint[closed_reason]=%@&complaint[is_resident_satisfied]=true&complaint[rating]=%.1f",selfComplaint,self.tempStar)
        }
        else
        {
            body = String(format: "complaint[state_action]=Reject&complaint[closed_reason]=%@&complaint[is_resident_satisfied]=false&complaint[rating]=%.1f",selfComplaint,self.tempStar)
        }
        
        WS_Obj.WebAPI_With_Body(urlString, Body: body, RequestType: "POST"){(responce) in
            DispatchQueue.main.async(execute: {
                
                PKHUD.sharedHUD.hide(animated: false) { success in
                }
                if(responce["Error"] != JSON.null) {
                    DispatchQueue.main.async(execute: {
                        //                        let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                        //                        alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
                        //                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
                else if(responce["message"] == JSON.null) {
                    self.ResponceDic = responce
                    print(self.ResponceDic)
                }
                else{
                    
                    print(responce)
                    var str = "Unknown Exception"
                    if(responce["message"] != JSON.null)
                    {
                        str = responce["message"].string!
                    }
                    let alert = UIAlertController(title: "Alert".localized(), message: str, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default){
                        UIAlertAction in
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(okAction)
                    //                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    //    MARK: TextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (self.FeedbackMsgTxt?.text == "Please write your comment.".localized()){
            self.FeedbackMsgTxt!.text = nil
            self.FeedbackMsgTxt!.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.FeedbackMsgTxt!.text.isEmpty{
            self.FeedbackMsgTxt!.text = "Please write your comment.".localized()
            self.FeedbackMsgTxt!.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        if(text == "\n") {
            FeedbackMsgTxt.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return true
    }
    //  MARK: Select Rating Cosmos library delegate
    fileprivate func didTouchCosmos(_ rating: Double) {
        print("didTouchCosmos")
        print(rating)
    }
    
    fileprivate func didFinishTouchingCosmos(_ rating: Double) {
        print("didFinishTouchingCosmos")
        self.tempStar = rating
        print(self.tempStar)
    }
    
    //  MARK: Check feedback
    @IBAction func FeedbackNotSatisfiedTapped(_ sender: AnyObject) {
        if(ButtonTap==false){
            ButtonTap = true
            self.FeedbackNotSatisfiedBtn.setImage(UIImage(named: "checkbox_selected.png"), for: UIControlState())
        }
        else{
            ButtonTap = false
            self.FeedbackNotSatisfiedBtn.setImage(UIImage(named: "checkbox_normal.png"), for: UIControlState())
        }
    }
    
    // MARK: - Navigation
    @IBAction func submitTapped(_ sender: AnyObject) {
        
        let trimmedString = FeedbackMsgTxt.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if (trimmedString == "" || trimmedString == "Please write your comment.".localized()){
            print("textfield is empty")
            let alert = UIAlertController(title: "Alert".localized(), message: "Please enter your comment.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            print("textfield contain data")
            self.CallSubmitFeedback()
            self.FeedbackMsgTxt.text = ""
        }
    }
    
    @IBAction func BackTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    /*
     
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
