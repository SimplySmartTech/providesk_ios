//
//  HelpDeskNewComplaintViewController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 16/11/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import PKHUD
import Localize_Swift
import BSImagePicker
import Photos
import SwiftyJSON
import AWSS3


class HelpDeskNewComplaintViewController: UIViewController,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    let iPhones = ["iPhone 6s", "iPhone 6s Plus", "iPhone SE"]
    
    let colors = ["Gold", "Rose Gold", "Silver", "Space Gray"]
    
    let units = ["1", "2", "3", "4"]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var subCategoryTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var complaintRadioButton: UIButton!
    @IBOutlet weak var discriptionTextArea: UITextView!
    @IBOutlet weak var subCategoryView: UIView!
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var requestRadioButton: UIButton!
    //    var selectedRadioButton: String?
    @IBOutlet weak var createComplaintButton: UIButton!
    
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var imageAssetView: UIView!
    @IBOutlet weak var createButtonView: UIView!
    @IBOutlet weak var unitDiscriptionView: UIView!
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var WS_Obj : WebServiceClass = WebServiceClass()
    
    var categoryDisctionary: JSON = JSON(0)
    var Category : Array<JSON> = Array()
    
    var subCategory : Array<JSON> = Array()
    
    var ComplaintDict = JSON(0)
    var CategoryDic : JSON!
    
    var SelectedFlatNo:String?
    
    let categoryPicker = UIPickerView()
    let subCategoryPicker = UIPickerView()
    let unitPicker = UIPickerView()
    
    var onRadioButton: UIImage = UIImage(named:"green_radio_on")!
    var offRadiButton: UIImage = UIImage(named: "green_radio_off")!
    
    var AssetArray=NSMutableArray()
    var AssetURLArray=NSMutableArray()
    
    var assetURLCount: Int = 0
    
    var myFlatsArray: Array<String> = []
    var myFlatNameArray: Array<String> = []
    var myFlatsIdArray: Array<String> = []
    
    //    var categoryListData: JSON = JSON(0)
    
    //    var categoryDisctionary: JSON!
    
    
    var `Type`:String = "Complaint"
    var selectedCategory: String!
    var selectedSubCategory: String!
    
    var selectedUnit: String!
    
    var selectedNumber: Int = 0
    
    var categorryNameArray: NSMutableArray = NSMutableArray()
    var subCategoryNameArray: NSMutableArray = NSMutableArray()
    
    var categoriesNmaes: NSMutableArray = NSMutableArray()
    
    var actualXSubCat: CGFloat!
    var actualYSubCat: CGFloat!
    var actualWidthSubCat: CGFloat!
    var actualHeightSubCat: CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CallHelpDeskCategoryAPI()
        
        //Get Actual Coordinates of SubCategory View
        
        actualXSubCat = self.subCategoryView.frame.origin.x
        actualYSubCat = self.subCategoryView.frame.origin.y
        actualWidthSubCat = self.subCategoryView.frame.width
        actualHeightSubCat = self.subCategoryView.frame.height
        
        print("Defaults : \(self.categoryDisctionary)")
        //Category Toolbar
        let toolBarCategory = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBarCategory.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBarCategory.barStyle = UIBarStyle.blackTranslucent
        
        toolBarCategory.tintColor = UIColor.white
        
        toolBarCategory.backgroundColor = UIColor.black
        
        
        let doneButtonCategory = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(HelpDeskNewComplaintViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Pick your category"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        //Sub Category tool bar
        
        let toolBarSubCategory = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBarSubCategory.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBarSubCategory.barStyle = UIBarStyle.blackTranslucent
        
        toolBarSubCategory.tintColor = UIColor.white
        
        toolBarSubCategory.backgroundColor = UIColor.black
        
        
        let doneButtonSubCategory = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(HelpDeskNewComplaintViewController.donePressedSubCategory))
        
        let flexSpaceSubCat = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let labelSubCat = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        labelSubCat.font = UIFont(name: "Helvetica", size: 12)
        
        labelSubCat.backgroundColor = UIColor.clear
        
        labelSubCat.textColor = UIColor.white
        
        labelSubCat.text = "Pick your category"
        
        labelSubCat.textAlignment = NSTextAlignment.center
        
        let textBtnSubCat = UIBarButtonItem(customView: label)
        
        
        //toolbar units
        
        let toolBarUnits = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBarUnits.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBarUnits.barStyle = UIBarStyle.blackTranslucent
        
        toolBarUnits.tintColor = UIColor.white
        
        toolBarUnits.backgroundColor = UIColor.black
        
        
        let doneButtonUnits = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(HelpDeskNewComplaintViewController.donePressedUnits))
        
        let flexSpaceUnits = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let labelUnits = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        labelUnits.font = UIFont(name: "Helvetica", size: 12)
        
        labelUnits.backgroundColor = UIColor.clear
        
        labelUnits.textColor = UIColor.white
        
        labelUnits.text = "Pick your category"
        
        labelUnits.textAlignment = NSTextAlignment.center
        
        let textBtnUnits = UIBarButtonItem(customView: label)
        
        
        
        toolBarCategory.setItems([flexSpace,textBtn,flexSpace,doneButtonCategory], animated: true)
        toolBarSubCategory.setItems([flexSpaceSubCat,textBtnSubCat,flexSpaceSubCat,doneButtonSubCategory], animated: true)
        toolBarUnits.setItems([flexSpaceUnits,textBtnUnits,flexSpaceUnits,doneButtonUnits], animated: true)
        categoryTextField.inputAccessoryView = toolBarCategory
        subCategoryTextField.inputAccessoryView = toolBarSubCategory
        unitTextField.inputAccessoryView = toolBarUnits
        
        //        let flatno = UserDefaults.standard.value(forKey: "mySelectedFlatNo") as? NSString
        //        SelectedFlatNo = flatno as? String
        
        
        
        self.categoryPicker.delegate = self as UIPickerViewDelegate
        self.categoryPicker.tag = 1
        
        self.subCategoryPicker.delegate = self as UIPickerViewDelegate
        self.subCategoryPicker.tag = 2
        
        self.unitPicker.delegate = self as UIPickerViewDelegate
        self.unitPicker.tag = 3
        
        self.categoryTextField.inputView = categoryPicker
        self.subCategoryTextField.inputView = subCategoryPicker
        self.unitTextField.inputView = unitPicker
        
        
        
        let Dictionary = GeneralMethodClass.getUserData()
        myFlatsArray = Dictionary!.value(forKeyPath: "data.resident.units.info") as! NSArray as! [String];
        myFlatNameArray = Dictionary!.value(forKeyPath: "data.resident.units.name") as! NSArray as! [String];
        myFlatsIdArray = Dictionary!.value(forKeyPath: "data.resident.units.id") as! NSArray as! [String];
        print("Units Counts : \(myFlatsArray.count)")
        
        self.AssetArray.add(UIImage(named: "AttachmentIcon")!)
//        setData()
        CreateAttachmentView()
        
        //        self.subCategoryButton.inputView = subCategoryPicker
        //        self.unitButton.inputView = unitPicker
        
        //        self.headerView.layer.zPosition = 1
        // Do any additional setup after loading the view.
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        //
        //        self.scrollView.isScrollEnabled = true
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 {
            
            return self.categorryNameArray.count
            //            return iPhones.count
            
        }
        
        if pickerView.tag == 2 {
            
            return self.subCategoryNameArray.count
            //            return colors.count
            
        }
        if pickerView.tag == 3 {
            
            return myFlatsArray.count
            
        }
        
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            
            return self.categorryNameArray[row] as? String
            
        }
        
        if pickerView.tag == 2 {
            print("Subcategory title setting")
            return self.subCategoryNameArray[row] as? String
            
            
        }
        if pickerView.tag == 3 {
            pickerView.selectedRow(inComponent: 0)
            return myFlatsArray[row]
            
        }
        
        return nil
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            
            categoryTextField.text = self.categorryNameArray[row] as? String
            self.selectedNumber = row
            
        }
        
        if pickerView.tag == 2 {
            
            subCategoryTextField.text = self.subCategoryNameArray[row] as? String
            
        }
        if pickerView.tag == 3 {
            
            unitTextField.text = myFlatsArray[row]
            self.selectedUnit = myFlatNameArray[row]
            
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        //        if self.categoryTextField.text == nil{
        //            self.selectedNumber = 0
        //        }
        self.categoryTextField.text = self.categorryNameArray[self.selectedNumber] as! String
        categoryTextField.resignFirstResponder()
        subCategoryTextField.resignFirstResponder()
        self.subCategoryTextField.text = ""
        unitTextField.resignFirstResponder()
        self.selectedCategory = self.categoryTextField.text
        self.subCategoryNameArray = NSMutableArray()
        self.subCategoryPicker.reloadAllComponents()
        reloadSubCategory(selectedCategoryText: selectedCategory)
        self.subCategoryPicker.reloadAllComponents()
        
        
        
    }
    
    func donePressedSubCategory(_ sender: UIBarButtonItem) {
        if self.subCategoryTextField.text != nil {
            
            categoryTextField.resignFirstResponder()
            subCategoryTextField.resignFirstResponder()
            unitTextField.resignFirstResponder()
            self.selectedSubCategory = self.subCategoryTextField.text
            //        reloadSubCategory(selectedCategoryText: selectedCategory)
            self.subCategoryPicker.reloadAllComponents()
            
        }
        else{
            //            categoryTextField.resignFirstResponder()
            //            subCategoryTextField.resignFirstResponder()
            //            unitTextField.resignFirstResponder()
            self.selectedSubCategory = ""
            //        reloadSubCategory(selectedCategoryText: selectedCategory)
            //            self.subCategoryPicker.reloadAllComponents()
        }
        
        
    }
    
    func donePressedUnits(_ sender: UIBarButtonItem) {
        if self.unitTextField.text != nil{
            categoryTextField.resignFirstResponder()
            subCategoryTextField.resignFirstResponder()
            unitTextField.resignFirstResponder()
            self.unitTextField.text = self.myFlatsArray[0]
            self.selectedUnit = myFlatNameArray[0]
            //            self.selectedUnit = self.unitTextField.text
            //        reloadSubCategory(selectedCategoryText: selectedCategory)
            self.subCategoryPicker.reloadAllComponents()
        }
        
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        
        categoryTextField.text = nil
        categoryTextField.placeholder = "Select Category"
        categoryTextField.resignFirstResponder()
    }
    
    @IBAction func complaintSelected(_ sender: Any) {
        self.complaintRadioButton.setImage(onRadioButton, for: .normal)
        self.requestRadioButton.setImage(offRadiButton, for: .normal)
        self.Type = "Complaint"
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func requestSelected(_ sender: Any) {
        self.complaintRadioButton.setImage(offRadiButton, for: .normal)
        self.requestRadioButton.setImage(onRadioButton, for: .normal)
        self.Type = "Request"
    }
    
    @IBAction func createNewComplaintTapped(_ sender: Any) {
        
        let trimmedString = discriptionTextArea.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        let unitSelected = self.unitTextField.text
        
        if (trimmedString == "" || trimmedString == "Type a message"){
            print("textfield is empty")
            let alert = UIAlertController(title: "Alert".localized(),message: "Please fill the description first.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (unitSelected == "" || unitSelected == "Select Unit" ){
            let alert = UIAlertController(title: "Alert".localized(),message: "Please select unit first.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (self.AssetArray.count == 1 && discriptionTextArea != nil)
        {
            //            if selectedRadioButton == "Request"{
            //                self.lblSubCategory.text = "--"
            //            }
            //            print("no image found!")
            HUD.show(.progress)
            self.CallCreateAPI()
        }
        else if(self.AssetArray.count > 1 && discriptionTextArea != nil)
        {
            //            if Type == "Request"{
            //                self.lblSubCategory.text = "--"
            //            }
            
            HUD.show(.progress)
            let image = self.AssetArray.object(at: 0) as! UIImage
            self.assetURLCount = self.AssetURLArray.count
            self.uploadImage(image)
            
            
        }
        
    }
    
    
    func CallHelpDeskCategoryAPI(){
        
        let urlString = NSString(format: "cms/categories") as String
        
        WS_Obj.WebAPI_WithOut_Body_V2(urlString, RequestType: "GET"){(responce) in
            
            DispatchQueue.main.async(execute: {
                
                
                if(responce["message"] == JSON.null){
                    self.categoryDisctionary = responce
                    self.appDelegate.helpResponceDic = self.categoryDisctionary
                    print(self.categoryDisctionary)
                    self.Category = self.categoryDisctionary["categories"].array!
                    
                    self.setData()
                    
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
    
    func setData()  {
        print("got\(self.categoryDisctionary)")
        self.Category = categoryDisctionary["categories"].array!
        for category in self.Category{
            print("Hello")
            print("Category name:\(category["name"].stringValue)")
            var nameValue: String = category["name"].stringValue
            self.categorryNameArray.add(nameValue)
        }
        
        self.categoryPicker.reloadAllComponents()
    }
    
    
    
    
    func reloadSubCategory(selectedCategoryText: String)  {
        self.subCategory = Array()
        print("Selected number is\(self.selectedNumber)")
        if self.selectedNumber == nil {
            self.selectedNumber = 0
        }
        self.subCategory = categoryDisctionary["categories"][self.selectedNumber]["sub_categories"].array!
        for subCategory in self.subCategory{
            print("Hello")
            print("SubCategory name:\(subCategory["name"].stringValue)")
            var nameValue: String = subCategory["name"].stringValue
            self.subCategoryNameArray.add(nameValue)
        }
        if self.subCategoryNameArray.count == 0 {
            
            
            self.subCategoryView.isHidden = true
            self.dropDownView.frame = CGRect(x: self.dropDownView.frame.origin.x, y: self.dropDownView.frame.origin.y, width: self.dropDownView.frame.width, height: self.dropDownView.frame.height - actualHeightSubCat)
            self.unitDiscriptionView.frame = CGRect(x: actualXSubCat, y: actualYSubCat, width: actualWidthSubCat, height: self.unitDiscriptionView.frame.height)
            self.scrollView.frame = CGRect(x: self.scrollView.frame.origin.x, y: self.scrollView.frame.origin.y, width: self.scrollView.frame.width , height: self.scrollView.frame.height)
            self.imageAssetView.frame = CGRect(x: self.imageAssetView.frame.origin.x, y: self.imageAssetView.frame.origin.y - actualHeightSubCat, width: self.imageAssetView.frame.width, height: self.imageAssetView.frame.height)
            self.createButtonView.frame = CGRect(x: self.createButtonView.frame.origin.x, y: self.createButtonView.frame.origin.y - actualHeightSubCat, width: self.createButtonView.frame.width, height: self.createButtonView.frame.height)
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: 680 - actualHeightSubCat)
            
        }else{
            if self.subCategoryView.isHidden{
                self.subCategoryView.isHidden = false
                self.dropDownView.frame = CGRect(x: self.dropDownView.frame.origin.x, y: self.dropDownView.frame.origin.y, width: self.dropDownView.frame.width, height: self.dropDownView.frame.height + actualHeightSubCat)
                self.unitDiscriptionView.frame = CGRect(x: actualXSubCat, y: actualYSubCat + actualHeightSubCat, width: actualWidthSubCat, height: self.unitDiscriptionView.frame.height)
                self.scrollView.frame = CGRect(x: self.scrollView.frame.origin.x, y: self.scrollView.frame.origin.y, width: self.scrollView.frame.width , height: self.scrollView.frame.height)
                self.imageAssetView.frame = CGRect(x: self.imageAssetView.frame.origin.x, y: self.imageAssetView.frame.origin.y + actualHeightSubCat, width: self.imageAssetView.frame.width, height: self.imageAssetView.frame.height)
                self.createButtonView.frame = CGRect(x: self.createButtonView.frame.origin.x, y: self.createButtonView.frame.origin.y + actualHeightSubCat, width: self.createButtonView.frame.width, height: self.createButtonView.frame.height)
                self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: 680 )
            }
            subCategoryPicker.reloadAllComponents()
        }
        
    }
    
    
    
    func CreateAttachmentView()
    {
        var xPosition = 10 as CGFloat
        var yPosition = 5 as CGFloat
        
        for view in imageScrollView.subviews
        {
            if(view .isKind(of: UIButton.self) || view .isKind(of: UIImageView.self))
            {
                view.removeFromSuperview()
            }
        }
        
        for index in 0 ..< self.AssetArray.count
        {
            if(index%4 == 0 && index != 0)
            {
                xPosition = 10
                yPosition += 50
            }
            let ImgView = UIImageView(frame: CGRect(x: xPosition, y: yPosition, width: 40, height: 40))
            imageScrollView.addSubview(ImgView)
            ImgView.tag = index
            
            if(index != self.AssetArray.count-1)
            {
                let imageCustomUserBtn = self.AssetArray.object(at: index) as! UIImage;
                ImgView.image = imageCustomUserBtn
                
                let btn = UIButton(frame: CGRect(x: xPosition+30, y: yPosition-5, width: 16, height: 16))
                btn.backgroundColor = UIColor.red
                btn.setTitle("-", for: UIControlState())
                btn.setTitleColor(UIColor.white, for: UIControlState())
                btn.layer.cornerRadius = 8.0
                btn.addTarget(self, action: #selector(self.DeleteAttachmentImage(_:)), for:.touchUpInside)
                imageScrollView.addSubview(btn)
                btn.tag = index
            }
            else
            {
                let btn = UIButton(frame: CGRect(x: xPosition, y: yPosition, width: 40, height: 40))
                btn.addTarget(self, action: #selector(self.chooseAttachmentTapped(_:)), for:.touchUpInside)
                imageScrollView.addSubview(btn)
                btn.tag = index
                if(self.AssetArray.count-1 == 0){
                    let imageCustomUserBtn = self.AssetArray.object(at: index) as! UIImage;
                    ImgView.image = imageCustomUserBtn
                    btn.backgroundColor = UIColor.clear
                }else{
                    let imageCustomUserBtn = UIImage(named: "") as UIImage?
                    ImgView.image = imageCustomUserBtn
                    btn.backgroundColor = UIColor.white
                    btn.setTitle("+", for: UIControlState())
                    btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
                    btn.setTitleColor(UIColor.red, for: UIControlState())
                    btn.layer.borderColor = UIColor.red.cgColor
                    btn.layer.borderWidth = 1.0
                }
            }
            xPosition += 50
        }
        imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width, height: yPosition+50)
    }
    
    func DeleteAttachmentImage(_ sender: UIButton!) {
        let btnsendtag: UIButton = sender
        print(btnsendtag.tag)
        
        self.AssetArray.removeObject(at: btnsendtag.tag)
        print(self.AssetArray)
        CreateAttachmentView()
    }
    
    
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
            self.openGallary(btn)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        
        actionSheet.addAction(CameraAction)
        actionSheet.addAction(GalleryAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    func openGallary(_ sender: UIButton) {
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 1000

        bs_presentImagePickerController(vc, animated: true,
                                        select: { (asset: PHAsset) -> Void in
                                            print("Selected")

        }, deselect: { (asset: PHAsset) -> Void in
            print("Deselected")
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel")
        }, finish: { (assets: [PHAsset]) -> Void in
            print("Finish")

            print(assets.count)
            for asset in assets
            {
                let image = self.getAssetThumbnail(asset) as UIImage
                self.AssetArray.insert(image, at: self.AssetArray.count-1)

            }
            DispatchQueue.main.async(execute: {

                print(self.AssetArray.count)
                self.CreateAttachmentView()
                print("asset array count is \(self.AssetArray.count)")
            })

        }, completion: nil)
    }
    func getAssetThumbnail(_ asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        //CGSize(width: 300,height: 300)
        manager.requestImage(for: asset, targetSize: CGSize(width: 500,height: 500), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    
    @IBAction func openCamera(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    func CallCreateAPI(){
        
        //        print(self.AssetURLArray)
        //        print(SelectedFlatNo)
        
        let flat_uuid = GeneralMethodClass.Get_selected_Flat_id(selectedUnit! as NSString) as String
        let urlString = NSString(format: "cms/complaints") as String
        let Resident_id = GeneralMethodClass.Get_Current_Resident_id() as String
        let category_id = self.Category[selectedNumber]["id"].string
        print("Flat ID : \(flat_uuid)")
        
        let sub_category_id = GeneralMethodClass.Get_SubCategory_id(self.Category[selectedNumber]["sub_categories"].array!, SelectedSubCategory:subCategoryTextField.text! as String)
        
        var body:String!
        
        if (self.AssetURLArray.count == 0)
        {
            body = String(format:"complaint[description]=%@&complaint[priority]=Regular&complaint[of_type]=%@&complaint[unit_id]=%@&complaint[resident_id]=%@&complaint[category_id]=%@&complaint[sub_category_id]=%@",discriptionTextArea.text!,Type,flat_uuid,Resident_id,category_id!,sub_category_id)
        }
        else
        {
            let CombineAssetURLS = NSMutableString()
            for i in 0 ..< self.AssetURLArray.count
            {
                let temp = self.AssetURLArray.object(at: i) as! String
                print("URL Added : \(temp)")
                CombineAssetURLS.append(NSString(format: "&complaint[assets][]=%@",temp) as String)
            }
            // print(CombineAssetURLS)
            
            body = String(format:"complaint[description]=%@&complaint[priority]=Regular&complaint[of_type]=%@&complaint[unit_id]=%@&complaint[resident_id]=%@&complaint[category_id]=%@&complaint[sub_category_id]=%@%@",discriptionTextArea.text!,Type,flat_uuid,Resident_id,category_id!,sub_category_id,CombineAssetURLS)
            
            // print(body)
            
        }
        
        WS_Obj.WebAPI_With_Body(urlString, Body: body , RequestType: "POST"){(responce) in
            
            DispatchQueue.main.async(execute: {
                
                PKHUD.sharedHUD.hide(animated: false) { success in
                }
                if(responce["Error"] != JSON.null)
                {
                    //                    let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                    //                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
                    //                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else
                {
                    self.ComplaintDict = responce
                    print("Createdunit \(self.ComplaintDict)")
                    self.performSegue(withIdentifier: "new_complaint_chat", sender: nil)
                }
            })
        }
    }
    
    
    func uploadImage(_ image: UIImage){
        
        DispatchQueue.main.async(execute: {
            let selectedImage = self.compressImage(image: image)
            let selectedImageData: Data = NSData(data:UIImageJPEGRepresentation((image), 0.1)!) as Data
            let selectedImageSize:Int = selectedImageData.count
            print("Image Size: %f KB", selectedImageSize / 1024)
            
            //        let uploader:CLUploader = CLUploader(clouder, delegate: self)
            
            //        let settingsDict = self.CloudinarySettingsDict as NSDictionary? as? [AnyHashable : Any] ?? [:]
            
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
                
                
                
                
                if task.result != nil
                {
                    let s3URL = NSURL(string: "http://s3.amazonaws.com/\(S3BucketName)/\(uploadRequest?.key as! String)")!
                    print("Uploaded to:\n\(s3URL)")
                    
                    
                    if(self.AssetArray.count>1)
                    {
                        self.AssetURLArray.add(s3URL.absoluteString)
                        self.AssetArray .removeObject(at: 0)
                        let image = self.AssetArray.object(at: 0) as! UIImage
                        self.CreateAttachmentView()
                        self.uploadImage(image)
                    }
                    else
                    {
                        self.CallCreateAPI()
                    }
                }
                else
                {
                    PKHUD.sharedHUD.hide(animated: false) { success in
                    }
                    print("Unexpected empty result.")
                    
                    let alert = UIAlertController(title: "Alert".localized(), message: "Please check your internet connection.".localized() , preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return nil
            })
            
        })
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!)
    {
        // self.AssetArray .addObject(image)
        self.AssetArray.insert(image, at: self.AssetArray.count-1)
        CreateAttachmentView()
        self.dismiss(animated: true, completion: nil);
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "new_complaint_chat"
        {
            var str:String?
            str = self.Category[selectedNumber]["name"].string
            
            let chatVC = segue.destination as! HelpDeskChatController
            chatVC.StringCategorySubject = subCategoryTextField.text! as String
            chatVC.StringNumber = "#"
            chatVC.StringImg = str
            chatVC.StringComplaintID = self.ComplaintDict["id"].string
            chatVC.StringState = "open"
            chatVC.OpenORClosed  = "open"
            chatVC.FromWhere = "CreateComplaint"
            chatVC.gotPriority = "Regular"
        }
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
    
    
}
