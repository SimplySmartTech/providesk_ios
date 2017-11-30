//
//  ProfileViewController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 27/11/17.
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

class ProfileViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var navTitle: UILabel!
    
    @IBOutlet weak var MenuOrBackImg : UIImageView!
    var dashboardcontroller: UIViewController!
    var userData = [String]()
    var subMenuText = ["Name","Mobile","Email"]
    var faicon  = [String: UniChar]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTable.estimatedRowHeight = 66
        profileTable.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.isHidden=true
        
        
        
        faicon["Phone"] = 0xe60f
        faicon["Profile"] = 0xe61e
        faicon["Mail"] = 0xe607
        
        // Do any additional setup after loading the view.
        self.profileTable.tableFooterView = UIView(frame: CGRect.zero)
        let Dictionary = GeneralMethodClass.getUserData()
        // print(Dictionary)
        if(Dictionary != nil)
        {
            let name = Dictionary!.value(forKeyPath: "data.resident.name") as? String
            let email = Dictionary!.value(forKeyPath: "data.resident.email") as? String
            let phone = Dictionary!.value(forKeyPath: "data.resident.mobile") as? String
            userData = [name!,phone!,email!]
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navTitle.text = "Profile".localized()
        profileTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let DashBoardContrller = storyboard.instantiateViewController(withIdentifier: "HelpDesk") as! HelpDeskController_V2
        self.dashboardcontroller = UINavigationController(rootViewController: DashBoardContrller)
        
        //        _ = self.navigationController?.popViewController(animated: true)
        
        self.slideMenuController()?.changeMainViewController(self.dashboardcontroller, close: true)
        
    }
    //    MARK: - Tableview Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var str : String!
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileTableViewCell
        
        cell.mainTextLabel?.text = userData[indexPath.row]
        str = subMenuText[indexPath.row]
        cell.subTextLabel?.text = str.localized()
        
        
        switch indexPath.row {
        case 0:
            cell.imgView.image = UIImage.init(named: "profile")
            break
        case 1:
            cell.imgView.image = UIImage.init(named: "call")
            break
        case 2:
            cell.imgView.image = UIImage.init(named: "envelope")
            break
        default:
            print("Some other character")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileTableViewCell
        
        var label = cell.mainTextLabel
        label?.numberOfLines = 0
        label?.lineBreakMode = NSLineBreakMode.byWordWrapping
        label?.font = cell.mainTextLabel.font
        label?.text = userData[indexPath.row]
        label?.layoutIfNeeded()
        label?.layoutSubviews()
        label?.sizeToFit()
        //    print((label?.frame.height)! + 25)
        //        if(((label?.frame.height)! + 25)<66){
        return (66+(((label?.frame.height)! + 25)-44))
        //        }
        //        return ((label?.frame.height)! + 25) ;
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
