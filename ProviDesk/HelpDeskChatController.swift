//
//  HelpDeskChatController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 09/10/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//


import UIKit
import PKHUD
//import Cloudinary
import BSImagePicker
import Photos
import SwiftyJSON
import AWSS3
import SDWebImage

class HelpDeskChatController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var msgTextfield: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var CategoryImgLbl: UILabel!
    @IBOutlet weak var CategorySubjectLbl: UILabel!
    @IBOutlet weak var HomeImgLbl: UILabel!
    @IBOutlet weak var FlatIdLbl: UILabel?
    @IBOutlet weak var SubjectNumberLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var stateImgLbl: UILabel!
    @IBOutlet weak var sendBtnLbl: UILabel!
    @IBOutlet weak var ChatBottomView: UIView!
    //    @IBOutlet weak var AttachmentScrollView: UIScrollView!
    @IBOutlet weak var chatListView: UIView!
    @IBOutlet weak var headerViewOutlet: UIView!
    @IBOutlet weak var viewOnTop1: UIView!
    @IBOutlet weak var viewOnTop2: UIView!
    
    
    @IBOutlet weak var overLayView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var noDataButton: UIButton!
    @IBOutlet weak var activityIndicatorData: UIActivityIndicatorView!
    @IBOutlet weak var BtnAddMoreAssets: UIButton!
    @IBOutlet weak var BtnSaveAssets: UIButton!
    
    var WS_Obj : WebServiceClass = WebServiceClass()
    var GEN_Obj : GeneralMethodClass = GeneralMethodClass()
    var StringCategorySubject:String!
    var StringNumber:String!
    var StringState:String!
    var StringImg:String!
    var StringComplaintID:String!
    var OpenORClosed:String!
    var FromWhere:String!
    
    var originalX:CGFloat!
    var originalY:CGFloat!
    var originalWidth:CGFloat!
    var originalHeight:CGFloat!
    
    var gotLabel: UILabel!
    var gotPriority: String!
    var gotShortName: String!
    
    var imageData: Data = Data()
    
    var chatBottomOriginalY:CGFloat!
    
    var profilePicture: UIImage!
    var selectedImageView: UIImageView!
    
    var imageVC: ImageViewViewController = ImageViewViewController()
    
    
    var faicon  = [String: UniChar]()
    var ResponceDic = JSON(0)
    var ResponceArray : Array<JSON> = Array()
    //    var AssetURLsArray : NSMutableArray = NSMutableArray()
    var NewAssets2Upload=NSMutableArray()
    
    //    let clouder = CLCloudinary()
    //    let CloudinarySettingsDict = NSMutableDictionary()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0)
        
        //        self.CategoryImgLbl = self.gotLabel
        
        viewOnTop2.layer.backgroundColor = UIColor.white.cgColor
        viewOnTop2.layer.borderColor = UIColor.gray.cgColor
        viewOnTop2.layer.borderWidth = 0.0
        viewOnTop2.layer.masksToBounds = false
        viewOnTop2.layer.shadowOffset = CGSize(width: 0, height: -2)
        viewOnTop2.layer.shadowOpacity = 0.15
        viewOnTop2.layer.shadowRadius = 0.0
        
        if gotShortName != nil && gotPriority != nil{
            self.CategoryImgLbl.layer.masksToBounds = true
            self.CategoryImgLbl.layer.cornerRadius = 0.5 * self.CategoryImgLbl.bounds.size.width
            self.CategoryImgLbl.font = UIFont(name: "Arial", size: 12)
            self.CategoryImgLbl.textColor = UIColor.white
            self.CategoryImgLbl.backgroundColor = getPriorityColor(priority: self.gotPriority!)
            self.CategoryImgLbl.text = self.gotShortName
        }
        
        self.headerViewOutlet.layer.zPosition = 1
        self.viewOnTop1.layer.zPosition = 1
        self.viewOnTop2.layer.zPosition = 1
        
        self.msgTextfield.autocorrectionType = .no
        
        
        
        originalX = self.chatListView.frame.origin.x
        originalY = self.chatListView.frame.origin.y
        originalWidth = self.chatListView.frame.width
        originalHeight = self.chatListView.frame.height
        
        chatBottomOriginalY = self.ChatBottomView.frame.origin.y
        self.tableView.frame.size.height += 53
        
        BtnAddMoreAssets.backgroundColor = UIColor.white
        //        BtnAddMoreAssets.setTitle("+", for: UIControlState())
        //        BtnAddMoreAssets.setTitleColor(UIColor.red, for: UIControlState())
        //        BtnAddMoreAssets.layer.borderColor = UIColor.red.cgColor
        //        BtnAddMoreAssets.layer.borderWidth = 1.0
        BtnSaveAssets.isHidden = true
        
        //        clouder?.config().setValue("mixtape", forKey: "cloud_name")
        
        self.ChatBottomView.frame.origin.y += 53
        
        //        if (self.OpenORClosed != nil) {
        //            if(self.OpenORClosed == "open")
        //            {
        //                self.ChatBottomView.isHidden = false
        //                self.ChatBottomView.frame.origin.y += 53
        //                self.tableView.frame.size.height += 53
        //                //            self.AttachmentScrollView.isHidden = true
        //            }
        //            else if(OpenORClosed == "close")
        //            {
        //                self.ChatBottomView.isHidden = true
        //                self.tableView.frame.size.height += 95
        //            }
        //        }
        
        CategorySubjectLbl.text = StringCategorySubject
        SubjectNumberLbl.text = StringNumber
        stateLbl.text = StringState
        
        
        
        sendBtn.layer.cornerRadius = 0.5 * sendBtn.bounds.size.width
        self.msgTextfield.delegate = self
        msgTextfield.attributedPlaceholder =  NSAttributedString(string: "Type a message".localized(), attributes: [NSForegroundColorAttributeName: UIColor .lightGray])
        
        //self.AssetURLsArray .addObject("Add Button")
        
        NotificationCenter.default.addObserver(self, selector: #selector(HelpDeskChatController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(HelpDeskChatController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if GeneralMethodClass.isConnectedToNetwork() == true{
            print("Internet connection OK")
            self.hideOverlayView()
        }
        else
        {
            print("Internet connection FAILED")
            self.displayNoData()
            self.noDataLbl.text="Please check your internet connection.".localized()
        }
        
        setMenuItemUnicode()
        setImageToLabel()
        setText()
        headerLbl.text = GeneralMethodClass.getSelectedFlatDisplayName()
        CallHelpDeskChatHistoryAPI()
        //        CallCloudinaryAPI()
        
        //  let flatno = NSUserDefaults.standardUserDefaults().valueForKey("mySelectedFlatNo") as? String
        FlatIdLbl!.text = ""
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Localized Text
    
    func setText()
    {
        //        headerLbl.text = "Complaint detail".localized();
        BtnSaveAssets.setTitle("Save Photos".localized(), for: UIControlState.normal)
        
    }
    
    func setImageToLabel(){
        
        //       self.CategoryImgLbl.layer.masksToBounds = true
        //        self.CategoryImgLbl.layer.cornerRadius = 0.5 * self.CategoryImgLbl.bounds.size.width
        //        self.CategoryImgLbl.font = UIFont(name: "Arial", size: 15)
        //        self.CategoryImgLbl.textColor = UIColor.white
        //        self.CategoryImgLbl.backgroundColor = getPriorityColor(priority: self.gotPriority!)
        //        self.CategoryImgLbl.text = self.gotShortName
        //
        //        CategoryImgLbl.font = UIFont(name: "botsworth", size: 30)
        //
        //        HomeImgLbl.font = UIFont(name: "botsworth", size: 30)
        //        HomeImgLbl.text = String(format: "%C",faicon["Home"]!)
        //        HomeImgLbl.textColor = UIColor.red
        //
        //        stateImgLbl.font = UIFont(name: "botsworth", size: 15)
        //        stateImgLbl.text = String(format: "%C",faicon["hourglass"]!)
        //        stateImgLbl.textColor = UIColor.black
        
        sendBtnLbl.font = UIFont(name: "botsworth", size: 18)
        sendBtnLbl.text = String(format: "%C", faicon["icon_send"]!)
        sendBtnLbl.textColor = UIColor.white
        
        //        CategoryImgLbl.textColor = UIColor.red
        
        //        if(StringImg == "Electrical"){
        //            CategoryImgLbl.text = String(format: "%C",faicon["Electricity"]!)
        //        }
        //        else if(StringImg == "Civilwork"){
        //            CategoryImgLbl.text = String(format: "%C",faicon["Civil Work"]!)
        //        }
        //        else if(StringImg == "Water"){
        //            CategoryImgLbl.text = String(format: "%C",faicon["Water"]!)
        //        }
        //        else if(StringImg == "Cable TV"){
        //            CategoryImgLbl.text = String(format: "%C",faicon["Cable TV"]!)
        //        }
        //        else if(StringImg == "Citizen’s Billing"){
        //            CategoryImgLbl.text = String(format: "%C",faicon["Billing"]!)
        //        }
        //        else if(StringImg == "Infra Complaint"){
        //            CategoryImgLbl.text = String(format: "%C",faicon["Infra"]!)
        //        }
        //        else if(StringImg == "IT"){
        //            CategoryImgLbl.text = String(format: "%C",faicon["IT"]!)
        //        }
        //        else{
        //            CategoryImgLbl.text = String(format: "%C",faicon["Others"]!)
        //        }
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
    // MARK: - Save Attachments Images
    
    //    @IBAction func SaveAssetClicked(_ sender: UIButton)
    //    {
    //        sender.isUserInteractionEnabled = false
    //
    //                for index in 0 ..< self.AssetURLsArray.count
    //                {
    //                    if((type(of:self.AssetURLsArray[index]) == type(of: UIImage())) && (!NewAssets2Upload.contains(self.AssetURLsArray[index]))) {
    //                        NewAssets2Upload .add(self.AssetURLsArray[index])
    //                    }
    //                }
    //                if(NewAssets2Upload.count>0)
    //                {
    //                    HUD.show(.progress)
    //                    self.CallUploadImage(NewAssets2Upload.object(at: 0) as! UIImage)
    //                }
    //    }
    
    // MARK: - Add Attachments Images
    
    @IBAction func chooseAttachmentTapped(_ sender: AnyObject)
    {
        let actionSheet = UIAlertController(title: nil, message: "Select Options".localized(), preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let CameraAction = UIAlertAction(title: "Camera".localized(), style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) -> Void in
            self.openCamera(alert)
        })
        
        let GalleryAction = UIAlertAction(title: "Gallery".localized(), style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) -> Void in
            let btn = UIButton()
            //            self.openGallary(btn)
            self.openLibrary(alert)
            
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        
        actionSheet.addAction(CameraAction)
        actionSheet.addAction(GalleryAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Camera Selection
    
    @IBAction func openCamera(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    @IBAction func openLibrary(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            print("Chosen Library")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true,completion: nil)
            
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!)
    {
        //        self.AssetURLsArray.add(image)
        // self.AssetURLsArray.insertObject(image, atIndex: self.AssetURLsArray.count-1)
        if picker.sourceType == .camera{
            self.displayLoader()
            CallUploadImage(image)
            self.dismiss(animated: true, completion: nil);
        }
        else
            if picker.sourceType == .photoLibrary{
                self.displayLoader()
                CallUploadImage(image)
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Gallery Selection
    
    //        func openGallary(_ sender: UIButton) {
    //            var selAsset: PHAsset!
    //            var selectedImage: UIImage!
    //            let vc = BSImagePickerViewController()
    //            vc.maxNumberOfSelections = 1
    //
    //            bs_presentImagePickerController(vc, animated: true,
    //                select: { (asset: PHAsset) -> Void in
    //                    print("Selected")
    //                    selAsset = asset
    ////                    self.CallUploadImage(self.getAssetThumbnail(asset) as UIImage)
    //
    //                }, deselect: { (asset: PHAsset) -> Void in
    //                    print("Deselected")
    //                }, cancel: { (assets: [PHAsset]) -> Void in
    //                    print("Cancel")
    //                }, finish: { (assets: [PHAsset]) -> Void in
    //                    print("Finish")
    //                    self.dismiss(animated: true, completion: nil)
    //                    if selAsset != nil{
    //                    selectedImage = self.getAssetThumbnail(selAsset) as UIImage
    //                        DispatchQueue.main.async {
    //                            self.displayLoader()
    //                            self.CallUploadImage(selectedImage)
    //                        }
    //
    //
    //                    }
    //
    //                }, completion: nil)
    //
    //        }
    //        func getAssetThumbnail(_ asset: PHAsset) -> UIImage {
    //            let manager = PHImageManager.default()
    //            let option = PHImageRequestOptions()
    //            var thumbnail = UIImage()
    //            option.isSynchronous = true
    //            //CGSize(width: 300,height: 300)
    //            manager.requestImage(for: asset, targetSize: CGSize(width: 500,height: 500), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
    //                thumbnail = result!
    //            })
    //            return thumbnail
    //        }
    // MARK: - Attachment Dynamic View
    
    //    func CreateAttachmentView()
    //    {
    //        if(self.AssetURLsArray.count>0 && self.AttachmentScrollView.isHidden == true)
    //        {
    //            self.ChatBottomView.frame.origin.y -= 53
    //            self.tableView.frame.size.height -= 53
    //            self.AttachmentScrollView.isHidden = false
    //        }
    //
    //        var xPosition = 10 as CGFloat
    //        let yPosition = 5 as CGFloat
    //
    //        for view in AttachmentScrollView.subviews
    //        {
    //            if(view .isKind(of: UIButton.self) || view .isKind(of: UIImageView.self))
    //            {
    //                view.removeFromSuperview()
    //            }
    //        }
    //
    //        for index in 0 ..< self.AssetURLsArray.count
    //        {
    //            let ImgView = UIImageView(frame: CGRect(x: xPosition, y: yPosition, width: 40, height: 40))
    //            AttachmentScrollView.addSubview(ImgView)
    //            ImgView.tag = index
    //            let PlaceholderImg = UIImage(named: "Placeholder") as UIImage?
    //            ImgView.image = PlaceholderImg
    //            if(type(of:self.AssetURLsArray[index]) == type(of: UIImage()))
    //            {
    //                let imageCustomUserBtn = self.AssetURLsArray.object(at: index) as! UIImage
    //                ImgView.image = imageCustomUserBtn
    //                BtnSaveAssets.isHidden = false
    //            }
    //            else
    //            {
    //                let temp = (self.AssetURLsArray[index] as! JSON)["image"].string
    //                let url = URL(string: temp!)
    //                DispatchQueue.global(qos: .background).async {
    //                    let data = try? Data(contentsOf: url!)
    //                    DispatchQueue.main.async(execute: {
    //                        if(data != nil)
    //                        {
    //                           ImgView.image = UIImage(data: data!)
    //                        }
    //                    });
    //                }
    //            }
    //            xPosition += 50
    //        }
    //        AttachmentScrollView.contentSize = CGSize(width: xPosition+50,height: 50)
    //    }
    
    //    MARK: - API Calls
    //    func CallCloudinaryAPI(){
    //
    //        let urlString = NSString(format: "api/cloudinary/credentials") as String
    //        WS_Obj.WebAPI_WithOut_Body(urlString, RequestType: "GET"){(responce) in
    //            DispatchQueue.main.async(execute: {
    //
    //                if(responce["Error"] != JSON.null)
    //                {
    //                    //                    let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
    //                    //                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
    //                    //                    self.presentViewController(alert, animated: true, completion: nil)
    //                }
    //                else  if(responce["message"] == JSON.null)
    //                {
    //                    let ResponceDic = responce
    //                    print(ResponceDic)
    //
    //                    if(ResponceDic.count>0)
    //                    {
    //                        let api_key = ResponceDic["api_key"].string
    //                        let signature = ResponceDic["signature"].string
    //                        let timestamp = ResponceDic["timestamp"].string
    //
    //                        self.CloudinarySettingsDict.setValue(signature, forKey: "signature")
    //                        self.CloudinarySettingsDict.setValue(timestamp, forKey: "timestamp")
    //                        self.CloudinarySettingsDict.setValue(api_key, forKey: "api_key")
    //                        print(self.CloudinarySettingsDict)
    //                    }
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
    
    func CallHelpDeskChatHistoryAPI(){
        
        self.displayLoader()
        let urlString = String(format: "cms/complaints/%@",StringComplaintID)
        WS_Obj.WebAPI_WithOut_Body(urlString, RequestType: "GET"){(responce) in
            
            DispatchQueue.main.async(execute: {
                
                self.hideOverlayView()
                if(responce["Error"] != JSON.null)
                {
                    //                        let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                    //                        alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
                    //                        self.presentViewController(alert, animated: true, completion: nil)
                }
                else if(responce["message"] == JSON.null)
                {
                    self.ResponceDic = responce
                    let xxx = self.ResponceDic["data"]["complaint"]["sorted_activities"].array
                    self.ResponceArray = xxx!
                    
                    let xxx11 = self.ResponceDic["data"]["complaint"]["sorted_activities"].arrayValue
                    
                    self.setProfilePic(array: self.ResponceArray)
                    
                    let xxx1 = self.ResponceDic["data"]["complaint"]["unit_info"].string
                    self.FlatIdLbl?.text = xxx1!
                    
                    let assm_state = self.ResponceDic["data"]["complaint"]["aasm_state"].string
                    
                    self.stateLbl?.text = assm_state
                    
                    print("ASSM \(assm_state)")
                    
                    let xxx2 = self.ResponceDic["data"]["complaint"]["number"].int
                    self.SubjectNumberLbl?.text = (NSString(format: "#%d", xxx2!)) as String
                    
                    self.gotPriority = self.ResponceDic["data"]["complaint"]["priority"].stringValue
                    self.gotShortName = self.ResponceDic["data"]["complaint"]["category_short_name"].stringValue
                    //                    self.OpenORClosed = assm_state
                    
                    //                        if self.OpenORClosed == nil{
                    if(assm_state == "open")
                    {
                        print("Open complaint")
                        self.ChatBottomView.isHidden = false
                        //                                self.ChatBottomView.frame.origin.y += 53
                        //                                self.tableView.frame.size.height += 53
                        //            self.AttachmentScrollView.isHidden = true
                    }
                    else if(assm_state == "closed")
                    {
                        print("Closed")
                        self.ChatBottomView.isHidden = true
                        //                                self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0)
                        self.tableView.frame.size.height += 50
                    }
                    //                        }
                    
                    self.CategoryImgLbl.layer.masksToBounds = true
                    self.CategoryImgLbl.layer.cornerRadius = 0.5 * self.CategoryImgLbl.bounds.size.width
                    self.CategoryImgLbl.font = UIFont(name: "Arial", size: 12)
                    self.CategoryImgLbl.textColor = UIColor.white
                    self.CategoryImgLbl.backgroundColor = self.getPriorityColor(priority: self.gotPriority!)
                    self.CategoryImgLbl.text = self.gotShortName
                    
                    self.CategoryImgLbl.text = self.ResponceDic["data"]["complaint"]["category_short_name"].string
                    
                    self.tableView.reloadData()
                    self.tableViewScrollToBottom(true)
                    
                    
                    //                    let assets = self.ResponceDic["data"]["complaint"]["assets"].array
                    //                    if((assets?.count)!>0)
                    //                    {
                    //                        for asset in assets!
                    //                        {
                    //                            self.AssetURLsArray.add(asset)
                    //                        }
                    //                    }
                    //                    // print(self.AssetURLsArray)
                    //                    self.CreateAttachmentView()
                }
                else
                {
                    self.displayNoData()
                    self.noDataLbl.text = "No data found.".localized()
                }
            })
        }
    }
    
    func CallHelpDeskChatSelfCommentAPI(){
        
//        HUD.show(.progress)
        let selfComment = msgTextfield.text! as String
        let urlString = String(format: "cms/complaints/%@/activity",StringComplaintID)
        let imageURL = "http://s3.amazonaws.com/xrbia-township/mobile/JPEG_20170508_150802.jpg"
        let body = String(format: "activity[text]=%@",selfComment)
        
        WS_Obj.WebAPI_With_Body(urlString, Body: body, RequestType: "POST"){(responce) in
            
            DispatchQueue.main.async(execute: {
                
                PKHUD.sharedHUD.hide(animated: false) { success in
                }
                
                if(responce["Error"] != JSON.null)
                {}
                else
                {
                    self.ResponceDic = responce
                    print(self.ResponceDic)
                    
                    let xxx = self.ResponceDic["activity"]
                    if((xxx.dictionary?.count)! > 0)
                    {
                        self.ResponceArray.append(xxx)
                    }
                    
                    self.tableView.reloadData()
                    self.tableViewScrollToBottom(true)
                }
            })
        }
    }
    
    
    func CallHelpDeskChatSelfImageAPI(url: String){
        
        HUD.show(.progress)
        //        let selfComment = msgTextfield.text! as String
        let urlString = String(format: "cms/complaints/%@/activity",StringComplaintID)
        //        let imageURL = "http://s3.amazonaws.com/xrbia-township/mobile/JPEG_20170508_150802.jpg"
        let body = String(format: "activity[image_url]=%@",url)
        
        
        WS_Obj.WebAPI_With_Body(urlString, Body: body, RequestType: "POST"){(responce) in
            
            DispatchQueue.main.async(execute: {
                
                PKHUD.sharedHUD.hide(animated: false) { success in
                }
                
                if(responce["Error"] != JSON.null)
                {}
                else
                {
                    self.ResponceDic = responce
                    print("Received response\(self.ResponceDic)")
                    
                    let xxx = self.ResponceDic["activity"]
                    if((xxx.dictionary?.count)! > 0)
                    {
                        self.ResponceArray.append(xxx)
                        //                        self.ResponceArray.removeAll()
                        //                        self.ResponceArray = self.ResponceDic["data"]["complaint"]["sorted_activities"].array!
                    }
                    
                    self.tableView.reloadData()
                    self.tableViewScrollToBottom(true)
                }
            })
        }
    }
    
    
    
    func CallUploadImage(_ image: UIImage){
        
        //            DispatchQueue.main.async {
        //                self.displayLoader()
        
        let now = NSDate()
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US_POSIX")
        format.dateFormat = "yyyyMMdd_HHmmss"
        print ("Formateed date:\(format.string(from: now as Date))")
        let ext = "jpg"
        var imageNameString: String = "JPEG_"+format.string(from: now as Date)+"."+ext
        print ("image nme date:\(imageNameString)")
        
        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent(imageNameString)
        let imageData: NSData = self.compressImage(image: image) //UIImageJPEGRepresentation(image, 0.7) as! NSData
        imageData.write(toFile: path as String, atomically: true)
        
        // once the image is saved we can use the path to create a local fileurl
        let url:NSURL = NSURL(fileURLWithPath: path as String)
        
        let S3BucketName = AWSConstant.AWS_BUCKETID
        
        print("Image URL : \(url)")
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = url as URL
        
        uploadRequest?.key = "mobile/"+imageNameString
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType = "image/"+ext
        //            uploadRequest?.contentLength = image.size as! NSNumber
        uploadRequest?.acl = AWSS3ObjectCannedACL.publicRead
        
        let transferManager = AWSS3TransferManager.default()
        print(S3BucketName)
        print(uploadRequest?.key! as Any)
        let str = "http://s3.amazonaws.com/\(S3BucketName)/\(uploadRequest?.key as! String)"
        print(str)
        let s3URL = NSURL(string: str)!
        print("Image will be uploaded to :\(s3URL))")
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            // Do something with the response
            self.hideOverlayView()
            if let error = task.error{
                print("Upload Error: \(error)")
            }
            if task.result != nil {
                let s3URL = NSURL(string: "http://s3.amazonaws.com/\(S3BucketName)/\(uploadRequest?.key as! String)")!
                print("Uploaded to:\n\(s3URL)")
                //                                        self.hideOverlayView()
                self.CallHelpDeskChatSelfImageAPI(url: s3URL.absoluteString!)
                
            }
            else {
                print("Unexpected empty result.")
            }
            //                                    print("Uploaded image URL:\(s3U)")
            
            return nil
        })
        //        }
        
        //            uploader.upload(selectedImage, options: settingsDict,
        //                withCompletion: { (dataDictionary: [AnyHashable: Any]?, errorResult:String?, code:Int, context: Any?) -> Void in
        //
        //                    DispatchQueue.main.async(execute: {
        //
        //                        if(dataDictionary != nil)
        //                        {
        //                            let dict = dataDictionary as NSDictionary? ?? [:]
        //                            print(dict)
        //                            if(dict.object(forKey: "secure_url") != nil)
        //                            {
        //                                self.CallSaveAssetsChanges(dict.value(forKey: "secure_url") as! String)
        //                            }
        //
        //                            if(self.NewAssets2Upload.count>1)
        //                            {
        //                                self.NewAssets2Upload .removeObject(at: 0)
        //                                let image = self.NewAssets2Upload.object(at: 0) as! UIImage
        //                                self.CallUploadImage(image)
        //                            }
        //                            else
        //                            {
        //                                PKHUD.sharedHUD.hide(animated: false) { success in
        //                                }
        //                                self.NewAssets2Upload .removeAllObjects()
        //                            }
        //                        }
        //                        else
        //                        {
        //                            self.BtnSaveAssets.isUserInteractionEnabled = true
        //                            self.BtnSaveAssets.isHidden = true
        //
        //                            PKHUD.sharedHUD.hide(animated: false) { success in
        //                            }
        //                            print(errorResult ?? "")
        //                            let alert = UIAlertController(title: "Alert".localized(), message: "Please check your internet connection.".localized() , preferredStyle: UIAlertControllerStyle.alert)
        //                            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
        //                            self.present(alert, animated: true, completion: nil)
        //                        }
        //                    })
        //                },
        //                andProgress: { (bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, context:Any?) -> Void in
        //                    print("Upload progress: \((totalBytesWritten * 100)/totalBytesExpectedToWrite) %");
        //                }
        //            )
    }
    
    func CallSaveAssetsChanges(_ AssetURL: String)
    {
        let urlString = String(format: "/cms/complaints/%@/add_asset",StringComplaintID)
        let body = String(format: "asset[image]=%@",AssetURL)
        WS_Obj.WebAPI_With_Body(urlString, Body: body, RequestType: "POST"){(responce) in
            
            DispatchQueue.main.async(execute: {
                print(responce)
            })
        }
    }
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.view.endEditing(true)
        return true
    }
    
    
    func keyboardWillShow(_ sender: Notification) {
        //        self.view.frame.origin.y = -220
        
        let info:NSDictionary = sender.userInfo! as NSDictionary
        
        var actualKeyboardHeight: CGRect = info.object(forKey: UIKeyboardFrameEndUserInfoKey) as! CGRect
        
        actualKeyboardHeight = (self.view.window?.convert(actualKeyboardHeight, to: self.view))!
        
        print("Keyboard Height is : \(actualKeyboardHeight.size.height)")
        
        if let keyboardSize = ((sender as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.chatListView.frame = CGRect(x: self.originalX , y: self.originalY, width:self.originalWidth , height: self.originalHeight - keyboardSize.height )
        }
        
    }
    
    func keyboardWillHide(_ sender: Notification) {
        if let keyboardSize = ((sender as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("greater ")
            self.chatListView.frame = CGRect(x: self.originalX , y: self.originalY, width:self.originalWidth , height: self.originalHeight)
        }
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var xxx:CGFloat!
        xxx = self.DecideHeightOfPost(self.ResponceArray, index:(indexPath as NSIndexPath).row) as CGFloat
        return xxx+10
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.ResponceArray.count > 0){
            return ResponceArray.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        var image: UIImage!
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HelpdeskChatTableViewCell
        cell = self.DrawChatPost(self.ResponceArray, index: (indexPath as NSIndexPath).row, PostCell: cell)
        var aString: String = "--"
        if (self.ResponceArray[indexPath.row]["text"].string != nil){
            aString = self.ResponceArray[indexPath.row]["text"].string!
        }
        
        cell.userImageView.image = nil
        
        var trimmedString = aString.trimmingCharacters(in: CharacterSet.whitespaces)
        if(trimmedString.characters.count >= 4)
        {
            let index1 = trimmedString.characters.index(trimmedString.endIndex, offsetBy: -4)
            let substring = trimmedString.substring(from: index1)
            
            if substring.lowercased().range(of: "<br>") != nil
            {
                let substring = trimmedString.substring(to: index1)
                trimmedString = substring
            }
        }
        
        trimmedString = trimmedString.replacingOccurrences(of: "<br>", with: ", ")
        
        cell.userMsgLbl.lineBreakMode = .byWordWrapping
        //        cell.userMsgLbl.font = UIFont(name: "Arial", size: 12)
        cell.userMsgLbl.numberOfLines = 10
        cell.userMsgLbl?.text = trimmedString
        cell.userMsgLbl.numberOfLines = 0
        if self.ResponceArray[indexPath.row]["resource_type"].stringValue == "User"{
            if self.ResponceArray[indexPath.row]["resource"]["profile_photo_url"].stringValue != nil{
                //            cell.profilePictureImage.frame = CGRect(x:5, y:0, width:25, height:25)
                //            var url = URL(string: self.ResponceArray[indexPath.row]["resource"]["profile_photo_url"].stringValue)
                //            let data = try? Data(contentsOf: url!)
                //            cell.profilePictureImage.image = UIImage(data: self.imageData)
                
            }
            
        }
        let myDate = self.ResponceArray[indexPath.row]["created_at"].string
        let TimeStamp = GEN_Obj.ConvertDateFormater(myDate!, Old_Format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ", New_Format: "dd MMM,yy hh:mm a")
        cell.datelbl?.text = TimeStamp
        
        var imageUrl = self.ResponceArray[indexPath.row]["image_url"].string
        if  imageUrl != nil{
            if imageUrl != ""{
                
                cell.isUserInteractionEnabled = true
                
//                print("Image Url is : \(String(describing: imageUrl) ?? )")
//                imageUrl = "https://s3.amazonaws.com/xrbia-township/mobile/JPEG_20171123_001200.jpg"
            
//                imageUrl?.insert("s" , at: advance(imageUrl.startIndex, 4))
                if !(imageUrl?.contains("https:"))!{
                    imageUrl = imageUrl?.insert_s(string: "s", ind: 4)
                }
                print("Image Url is : \(String(describing: imageUrl))")
                cell.userImageView.sd_setImage(with: URL(string: imageUrl!), placeholderImage: UIImage(named: "placeholder"))
//                DispatchQueue.main.async {
//                    let url = URL(string: imageUrl!)
//                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//                    cell.userImageView.image = UIImage(data: data!)
//                }
                
                //                            var imageUrl: String = self.ResponceArray[indexPath.row]["image_url"].string!
                //                "https://s3.amazonaws.com/xrbia-township//mobile/1493811770788.jpg"
                
                //                DispatchQueue.main.async {
                //                    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                //                    myActivityIndicator.center =  cell.userImageView.center
                //                    myActivityIndicator.hidesWhenStopped = true
                //                    myActivityIndicator.startAnimating()
                //                    cell.userImageView.addSubview(myActivityIndicator)
                //
                //                    let url = URL(string: imageUrl!)
                //
                //                    DispatchQueue.global().async {
                //
                //                        //                    let url = URL(string:"http://s3.amazonaws.com/xrbia-township/mobile/JPEG_20170508_150802.jpg")
                //                        let data = try? Data(contentsOf: url!)
                //                        let newData = UIImageJPEGRepresentation(UIImage(data:data!)!, 0.5)
                //                        let image = UIImage(data: newData!)!
                //                        cell.userImageView.image = image
                //                        myActivityIndicator.stopAnimating()
                //                        myActivityIndicator.removeFromSuperview()
                //                    }
                //                }
                
                
                
            }
            else {
                print("No image url")
                cell.isUserInteractionEnabled = false
            }
            
        }
        else{
            cell.isUserInteractionEnabled = false
        }
        
        
        return cell
    }
    func tableViewScrollToBottom(_ animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
            
        })
    }
    // MARK: - Calc Comment Post Size
    func DecideHeightOfPost(_ PostArr: Array<JSON>, index: Int) -> CGFloat {
        
        var height:CGFloat?
        
        var aString: String!
        if (PostArr[index]["text"].string != nil){
            aString = PostArr[index]["text"].string!
        }
        else{
            aString = "--"
        }
        
        
        //                if aString == nil {
        //                    aString = "No Text"
        //                }
        var trimmedString = aString.trimmingCharacters(in: CharacterSet.whitespaces)
        trimmedString = aString.replacingOccurrences(of: "<br>", with: ", ")
        if(trimmedString.characters.count >= 4)
        {
            let index1 = trimmedString.characters.index(trimmedString.endIndex, offsetBy: -4)
            let substring = trimmedString.substring(from: index1)
            
            if substring.lowercased().range(of: "<br>") != nil
            {
                //print("exists")
                let substring = trimmedString.substring(to: index1)
                trimmedString = substring
            }
        }
        trimmedString = trimmedString.replacingOccurrences(of: "<br>", with: ", ")
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        var label: UITextView!
        
        if ((screenWidth==320))
        {
            label = UITextView(frame:CGRect(x:0, y:0, width:140, height:0))
        }
        else if (screenWidth==375)
        {
            label = UITextView(frame:CGRect(x:0, y:0, width:170, height:0))
        }
        else if (screenWidth==414)
        {
            label = UITextView(frame:CGRect(x:0, y:0, width:195, height:0))
        }
        
        label.isScrollEnabled = true
        label.font = UIFont(name: "botsworth", size: 13)
        label.text = trimmedString
        label.sizeToFit()
        label.isScrollEnabled = false
        
        height = (label.frame.size.height-10)+(35)
        if ( PostArr[index]["image_url"].string != nil ){
            if(PostArr[index]["image_url"].string != ""){
                height = height! + 150.0
            }
        }
        
        //-10 to remove space added by extra line at end
        //+21 to add date label height
        
        return height!
        
    }
    
    
    
    
    
    func DrawChatPost(_ PostArr: Array<JSON>, index: Int, PostCell: HelpdeskChatTableViewCell) -> HelpdeskChatTableViewCell {
        
        var xxx:CGFloat!
        xxx = self.DecideHeightOfPost(self.ResponceArray, index:index) as CGFloat
        let str = self.ResponceArray[index]["resource_type"].string
        
        let profilePhotoUrl = self.ResponceArray[index]["resource"]["profile_photo_url"].string
        print(str ?? "")
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        var maxLblY: CGFloat = 12.0
        
        let userViewWidth: CGFloat = (screenWidth) * 2/3
        let contentWidth: CGFloat = userViewWidth - 28
        
        //        PostCell.userMsgView.frame = CGRect(x: 20 , y: 10, width: PostCell.frame.width - 40, height: xxx - 21)
        
        print("Width of Window: \(PostCell.frame.width)")
        print("Width of Window: \(screenWidth)")
        
        if (self.ResponceArray[index]["image_url"].string != nil ) {
            if self.ResponceArray[index]["image_url"].string != ""{
                //                xxx = 300.0 + xxx
                maxLblY = PostCell.userImageView.frame.maxY + 10
                PostCell.userImageView.frame = CGRect(x: 12, y: 19, width: contentWidth , height: 160)
                PostCell.userImageView.layer.cornerRadius = 0.5
                
            }
            
        }
        
        
        
        
        if(str=="Resident")// || str=="Resident")
        {
            PostCell.userMsgView.backgroundColor = UIColor(red: 180/255.0, green: 221/255.0, blue: 174/255.0, alpha: 1)
            
            //            PostCell.userMsgView.layer.contents = UIImage(named: "chatGreen")?.cgImage
            
            //            PostCell.userMsgView.backgroundColor = UIColor(red: 115, green: 202, blue: 113, alpha: 1.0)
            
            PostCell.usernameLbl.frame = CGRect(x: 6, y: 6, width: 60, height: 10)
            PostCell.usernameLbl.text = "You"
            
            PostCell.userMsgView.frame = CGRect(x:100, y:0, width:userViewWidth , height:xxx)
            PostCell.userMsgLbl.frame = CGRect(x:10, y:maxLblY , width:contentWidth, height:xxx-21)
            PostCell.userMsgLbl.font = UIFont(name: "Arial", size: 15)
            PostCell.userMsgLbl.textAlignment = .left
            PostCell.datelbl.textAlignment = .right
            PostCell.datelbl.frame = CGRect(x:10, y:xxx-21, width:contentWidth, height:21)
            PostCell.profilePictureImage.image = nil
            PostCell.profilePictureImage.isHidden = true
            //            PostCell.layoutMargins = nil
            
            //            if ((screenWidth==320))
            //            {
            //                PostCell.userMsgView.frame = CGRect(x:100, y:0, width:200, height:xxx)
            //                PostCell.userMsgLbl.frame = CGRect(x:5, y:maxLblY, width:180, height:xxx-21)
            //                PostCell.datelbl.frame = CGRect(x:5, y:xxx-21, width:180, height:21)
            //            }
            //            else if (screenWidth==375)
            //            {
            //                PostCell.userMsgView.frame = CGRect(x:130, y:0, width:230, height:xxx)
            //                PostCell.userMsgLbl.frame = CGRect(x:5, y:maxLblY, width:210, height:xxx-21)
            //                PostCell.datelbl.frame = CGRect(x:5, y:xxx-21, width:210, height:21)
            //            }
            //            else if (screenWidth==414)
            //            {
            //                PostCell.userMsgView.frame = CGRect(x:155, y:0, width:300, height:xxx)
            //                PostCell.userMsgLbl.frame = CGRect(x:5, y:maxLblY, width:280, height:xxx-21)
            //                PostCell.datelbl.frame = CGRect(x:5, y:xxx-21, width:280, height:21)
            //            }
        }
        else if(str=="User")
        {
            PostCell.userMsgView.backgroundColor = UIColor(red: 231/255.0, green: 231/255.0, blue: 231/255.0, alpha: 1)
            
            //            PostCell.userMsgView.layer.contents = UIImage(named: "chatGray")?.cgImage
            
            //            PostCell.userMsgView.backgroundColor = UIColor(red: 238, green: 238, blue: 238, alpha: 1.0)
            
            PostCell.usernameLbl.frame = CGRect(x: 6, y: 6, width: 60, height: 10)
            PostCell.usernameLbl.text = PostArr[index][]["resource"]["name"].stringValue
            
            PostCell.userMsgView.frame = CGRect(x:40, y:0, width:userViewWidth, height:xxx)
            PostCell.userMsgLbl.font = UIFont(name: "Arial", size: 15)
            PostCell.userMsgLbl.textAlignment = .left
            PostCell.datelbl.textAlignment = .right
            PostCell.userMsgLbl.frame = CGRect(x:10, y:maxLblY , width:contentWidth, height:xxx-21)
            PostCell.datelbl.frame = CGRect(x:10, y:xxx-21, width:contentWidth, height:21)
            PostCell.profilePictureImage.isHidden = false
            PostCell.profilePictureImage.frame = CGRect(x:6, y: 10 , width:30, height:30)
            PostCell.profilePictureImage.layer.cornerRadius = 0.5 * PostCell.profilePictureImage.bounds.size.width
            PostCell.profilePictureImage.clipsToBounds = true
            PostCell.profilePictureImage.layer.masksToBounds = true
            PostCell.profilePictureImage.layer.borderWidth = 1
            //            PostCell.profilePictureImage.contentMode = UIViewContentMode.scaleAspectFit
            var imageUrl = PostArr[index]["resource"]["profile_photo_url"].string
            PostCell.profilePictureImage.sd_setImage(with: URL(string: imageUrl!), placeholderImage: UIImage(named: "profile"))
            
            //            image = self.ResponceArray[index]["resource"]["profile_photo_url"].string
            //            PostCell.layoutMargins = nil
            
            //            if ((screenWidth==320))
            //            {
            //                PostCell.userMsgView.frame = CGRect(x:5, y:0, width:200, height:xxx)
            //                PostCell.userMsgLbl.frame = CGRect(x:10, y:maxLblY, width:180, height:xxx-21)
            //                PostCell.datelbl.frame = CGRect(x:10, y:xxx-21, width:180, height:21)
            //            }
            //            else if (screenWidth==375)
            //            {
            //                PostCell.userMsgView.frame = CGRect(x:5, y:0, width:250, height:xxx)
            //                PostCell.userMsgLbl.frame = CGRect(x:10, y:maxLblY, width:230, height:xxx-21)
            //                PostCell.datelbl.frame = CGRect(x:10, y:xxx-21, width:230, height:21)
            //            }
            //            else if (screenWidth==414)
            //            {
            //                PostCell.userMsgView.frame = CGRect(x:5, y:0, width:330, height:xxx)
            //                PostCell.userMsgLbl.frame = CGRect(x:10, y:maxLblY, width:310, height:xxx-21)
            //                PostCell.datelbl.frame = CGRect(x:10, y:xxx-21, width:310, height:21)
            //            }
        }
            
        else if (str == nil){
            PostCell.userMsgView.backgroundColor = UIColor(red: 244/255.0, green: 245/255.0, blue: 186/255.0, alpha: 1)
            PostCell.usernameLbl.text = ""
            
            PostCell.userMsgView.frame = CGRect(x: 20 , y: 5, width: screenWidth - 40, height: xxx - 10)
            PostCell.userMsgLbl.frame = CGRect(x:5, y: 12 , width:PostCell.userMsgView.frame.width - 10, height:40)
            PostCell.userMsgLbl.textAlignment = .center
            PostCell.userMsgLbl.font = UIFont(name: "Arial", size: 12)
            PostCell.datelbl.frame = CGRect(x:5, y:5, width:PostCell.userMsgView.frame.width - 10, height:10)
            PostCell.datelbl.textAlignment = .center
            PostCell.profilePictureImage.image = nil
            PostCell.profilePictureImage.isHidden = true
            print("In Width of Window: \(PostCell.userMsgView.frame.width)")
        }
        
        PostCell.userMsgView.layer.cornerRadius = 5.0
        
        return PostCell
    }
    
    // MARK: - Navigation
    
    @IBAction func SendTapped(_ sender: AnyObject) {
        
        msgTextfield.resignFirstResponder()
        
        let trimmedString = msgTextfield.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if (trimmedString == "")
        {
            // print("textfield is empty")
            
            let alert = UIAlertController(title: "Alert".localized(), message: "Please enter your comment.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            print("textfield contain data")
            CallHelpDeskChatSelfCommentAPI()
            //            CallHelpDeskChatSelfImageAPI()
            self.msgTextfield.text = ""
            self.tableView.reloadData()
        }
    }
    
    @IBAction func BackTapped(_ sender: AnyObject) {
        print("BackTapped")
        
        if(FromWhere == "OpenClosedList" || FromWhere == "Else")
        {
            _ = self.navigationController?.popViewController(animated: true)
        }
            //        else if(FromWhere == "Else")
        else
            if (FromWhere == "notification"){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                // call didFinishLaunchWithOptions ... why?
                appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
                
                //            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                //
                //            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoard") as! DashBoardController
                ////            nextViewController.FromDashboard = "NO"
                ////            nextViewController.notificationFlag = "YES"
                //            self.present(nextViewController, animated:true, completion:nil)
            }
            else
            {
                for i in 0 ..< self.navigationController!.viewControllers.count
                {
                    if(self.navigationController?.viewControllers[i].isKind(of: HelpDeskController_V2.self) == true)
                    {
                        _ = self.navigationController?.popToViewController(self.navigationController!.viewControllers[i] as! HelpDeskController_V2, animated: true)
                        break;
                    }
                }
                
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
        self.overLayView.isHidden = true;
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
            color = UIColor(red:0.26, green:0.55, blue:0.79, alpha:1.0)
            break
        default:
            color = UIColor.black
            
        }
        return color
    }
    
    
    func compressImage(image:UIImage) -> NSData {
        // Reducing file size to a 10th
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        var maxHeight : CGFloat = 1136.0
        var maxWidth : CGFloat = 640.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        var maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
                compressionQuality = 1;
            }
        }
        
        var rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight )//(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.draw(in: rect)
        var img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img!, compressionQuality);
        UIGraphicsEndImageContext();
        
        return imageData as! NSData;
    }
    
    func setProfilePic(array : Array<JSON>) {
        var i = 0
        for responce in array{
            print("resource_type Ooooo\(responce[i]["resource_type"].stringValue)")
            if responce["resource_type"].stringValue == "User" && responce["resource_type"].stringValue != nil{
                if responce["resource"]["profile_photo_url"].stringValue != ""{
                    //                                cell.profilePictureImage.frame = CGRect(x:5, y:0, width:25, height:25)
                    let url = URL(string: responce["resource"]["profile_photo_url"].stringValue)
                    
                    print("Profile pic\(responce["resource"]["profile_photo_url"].stringValue)")
                    self.imageData = try! Data(contentsOf: url!)
                    //                                self.profilePicture = UIImage(data: data!)
                    break
                    //                                cell.profilePictureImage.image = UIImage(data: data!)// Error here
                    
                }
                
            }
            i = i + 1
        }
    }
    
    func reloadViewData(notification : Notification) {
        print("reloadViewData called")
        print("From helpdeskchat\(notification)")
        //        CallHelpDeskChatHistoryAPI()
        
        let newNotificationData = JSON(notification.userInfo)["aps"]["data"]["activity"].dictionary
        print("newNotificationData : \(newNotificationData)")
        self.ResponceArray.append(JSON(newNotificationData))
        self.tableView.reloadData()
        self.tableViewScrollToBottom(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(HelpDeskChatController.reloadViewData), name: NSNotification.Name(rawValue: "ChatDetail"), object: nil)
    }
    
    
    //    - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
    //    {
    //    BOOL shouldReceiveTouch = YES;
    //
    //    if (gestureRecognizer == tap) {
    //    shouldReceiveTouch = (touch.view == yourImageView);
    //    }
    //    return shouldReceiveTouch;
    //    }
    
    
    
    //    func tap(){
    //        print("Tapped")
    //         imageVC.dismiss(animated: true, completion: nil)
    //
    //    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Row Selected")
        let imageUrl = self.ResponceArray[indexPath.row]["image_url"].string
        let currentCell = tableView.cellForRow(at: indexPath) as! HelpdeskChatTableViewCell
        
        if  imageUrl != nil{
            if imageUrl != ""{
                
                self.selectedImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
                self.selectedImageView.image = currentCell.userImageView.image
                self.selectedImageView.isHidden = true
                self.view.addSubview(self.selectedImageView)
                self.performSegue(withIdentifier: "showImage", sender: self)
                //                imageVC = ImageViewViewController()
                //                imageVC.view.backgroundColor = UIColor.red
                //
                //                let screenRect: CGRect = UIScreen.main.bounds
                //                let screenWidth = screenRect.size.width
                //                let screenHeight = screenRect.size.height
                //                imageVC.view.frame = CGRect(x: 0, y: 50, width: screenWidth, height: screenHeight - 45)
                //                let scrollView = UIScrollView(frame: imageVC.view.frame)
                //                let imageView = UIImageView(frame: imageVC.view.frame)
                //
                //                imageView.image = currentCell.userImageView.image
                //
                //                scrollView.addSubview(imageView)
                //                imageVC.view.addSubview(scrollView)
                //                imageView.isUserInteractionEnabled = true
                //
                //                self.present(imageVC, animated: true, completion: nil)
                
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage"{
            let destinationVC = segue.destination as! ImageViewViewController
            destinationVC.selectedImage = self.selectedImageView.image
        }
    }
    
    
    
    
}
extension String {
    func insert_s(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}
