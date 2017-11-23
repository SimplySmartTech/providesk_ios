//
//  NotificationDetailController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 09/11/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import PKHUD
import Localize_Swift

class NotificationDetailController: UIViewController {
    
    @IBOutlet weak var notificationDetailLbl: UILabel!
    @IBOutlet weak var Notif_NavigationLbl: UILabel!
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var meterIconBtn: UIButton!
    @IBOutlet weak var meterIconLbl: UILabel!
    
    var stringPass: String!
    var stringPass2: String!
    var stringPass3: String!
    
    var faicon  = [String: UniChar]()
    var WS_Obj : WebServiceClass = WebServiceClass()
    var ResponceDic=NSDictionary()
    var ResponceArray=NSArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setText()
        
        subjectLabel.text=stringPass
        descriptionLabel.text=stringPass2
        descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        descriptionLabel.numberOfLines = 0
        _ = [descriptionLabel .sizeToFit()]
        
        setMenuItemUnicode()
        meterIconLbl.font = UIFont(name:"botsworth", size: 50)!
        meterIconLbl.text = String(format: "%C",faicon["Meter"]!)
        
        if stringPass3 == nil {
            meterIconBtn.isHidden = true
            meterIconLbl.isHidden = true
            Notif_NavigationLbl.isHidden = true
        }
        
        notificationDetailLbl.text = GeneralMethodClass.getSelectedFlatDisplayName()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Localized Text
    
    func setText(){
        //        notificationDetailLbl.text = "Notifications".localized();
        Notif_NavigationLbl.text = "Click here for more detail".localized();
    }
    func setMenuItemUnicode(){
        faicon["Meter"] = 0xe621
    }
    
    // MARK: - Navigation
    @IBAction func backTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
        // self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func meterIconTapped(_ sender: AnyObject)
    {
        print(stringPass3)
        if (stringPass3 == "Electricity")
        {
            self.performSegue(withIdentifier: "Notif2Electricity", sender: self)
        }
        else if(stringPass3 == "Water")
        {
            self.performSegue(withIdentifier: "Notif2Water", sender: self)
        }
        else if(stringPass3 == "Ewallet")
        {
            self.performSegue(withIdentifier: "Notif2eWallet", sender: self)
        }
        else if(stringPass3 == "Helpdesk")
        {
            self.performSegue(withIdentifier: "Notif2HelpDesk", sender: self)
        }
        else if(stringPass3 == "Shopping")
        {
        }
        else if(stringPass3 == "DTH")
        {
        }
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        if(segue.identifier == "Notif2eWallet")
//        {
//            let vc = segue.destination as! eWalletController
//            vc.FromDashboard = "YES"
//        }
//        else if(segue.identifier == "Notif2Electricity")
//        {
//            let vc = segue.destination as! ElectricityController
//            vc.FromDashboard = "YES"
//        }
//        else if(segue.identifier == "Notif2Water")
//        {
//            let vc = segue.destination as! WaterController
//            vc.FromDashboard = "YES"
//        }
//        else if(segue.identifier == "Notif2HelpDesk")
//        {
//            let vc = segue.destination as! HelpDeskController
//            vc.FromDashboard = "YES"
//        }
//    }
    /*
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

