//
//  HelpDeskHistoryViewController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 23/11/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import SwiftyJSON

class HelpDeskHistoryViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var noDataButton: UIButton!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var tableView_Resolved: UITableView!
    @IBOutlet weak var overLayView: UIView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    
    
    var WS_Obj : WebServiceClass = WebServiceClass()
    var ResolvedAPIPageNo:Int!
    var ResolvedAPI_Total:Int!
    var faicon  = [String: UniChar]()
    var tempStr:String?
    
    
    var subCategory:String!
    var number:String!
    var state:String!
    var imageLbl:String!
    var FlatIDString:String!
    var complaintId:String!
    var subCategoryState:String!
    var OpenORClosed:String!  = "close"
    
    
    var selectedPriority: String!
    var selectedShortName: String!
    
    var refreshControl: UIRefreshControl!
    
    
    var resolvedComplaints : ModelComplaintsData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLoader()
        
        
        self.tableView_Resolved.dataSource = self
        self.tableView_Resolved.delegate = self
        
        ResolvedAPIPageNo = 1
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading..")
        refreshControl.addTarget(self, action: #selector(pullToRefreshTableView), for:UIControlEvents.valueChanged)
        tableView_Resolved.addSubview(refreshControl)
        
        //        self.hideOverlayView()
        setMenuItemUnicode()
        
        self.tableView_Resolved.tableFooterView = UIView(frame: .zero)
        
        self.ResolvedAPIPageNo = 1
        
        CallHelpDeskResolvedAPI()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func pullToRefreshTableView()  {
        CallHelpDeskResolvedAPIUpdate()
        //            self.refreshControl?.endRefreshing()
    }
    
    func CallHelpDeskResolvedAPI(){
        
        let urlString = NSString(format: "cms/complaints?page=%d&state=Resolved",self.ResolvedAPIPageNo) as String
        
        //        let urlString = NSString(format: "cms/complaints?page=%d&state=Pending",self.ResolvedAPIPageNo) as String
        
        WS_Obj.WebAPI_WithOut_Body(urlString, RequestType: "GET"){(responce) in
            
            DispatchQueue.main.async(execute: {
                print("History response recieved")
                
                if(responce["Error"] != JSON.null)
                {
                    print("Json Error in History")
                    
                    //                    let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                    //                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
                    //                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else if(responce["message"] == JSON.null){
                    print("History response with message")
                    
                    print ("Array count is : \(String(describing: self.resolvedComplaints?.arrayComplaints.count))")
                    
                    if ((responce["data"]["complaints"].array?.count)! > 0)
                    {
                        if self.ResolvedAPIPageNo > 1 {
                            var gotData = ModelComplaintsData.init(withData: responce)
                            self.resolvedComplaints?.arrayComplaints = (self.resolvedComplaints?.arrayComplaints)! + gotData.arrayComplaints
                        }
                        else{
                            self.resolvedComplaints = ModelComplaintsData.init(withData: responce)
                        }
                        
                    }
                    
                    if (responce["data"]["total"] != JSON.null)
                    {
                        self.ResolvedAPI_Total = responce["data"]["total"].int
                        print("Total is : \(self.ResolvedAPI_Total)")
                    }
                    
                    if (self.resolvedComplaints?.arrayComplaints.count == 0 || self.resolvedComplaints?.arrayComplaints.count == nil)
                    {
                        print("Omkar : No data ")
                        self.displayNoData()
                        self.noDataLbl.text="No data found.".localized()
                        
                    }
                    //                    else
                    //                    {
                    //                        print("In last else")
                    //                        self.hideOverlayView()
                    //                    }
                    self.tableView_Resolved.reloadData()
                    print("Removing refresh")
                    self.refreshControl?.endRefreshing()
                }
                else
                {
                    let alert = UIAlertController(title: "Alert".localized(), message: "Login token expired, Please login again.".localized(), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    
    func CallHelpDeskResolvedAPIUpdate(){
        self.ResolvedAPIPageNo = 1
        
        let urlString = NSString(format: "cms/complaints?page=%d&state=Resolved",self.ResolvedAPIPageNo) as String
        
        //        let urlString = NSString(format: "cms/complaints?page=%d&state=Pending",self.ResolvedAPIPageNo) as String
        WS_Obj.WebAPI_WithOut_Body(urlString, RequestType: "GET"){(responce) in
            
            DispatchQueue.main.async(execute: {
                print("History response recieved")
                
                if(responce["Error"] != JSON.null)
                {
                    print("Json Error in History")
                    
                    //                    let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                    //                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.Default, handler: nil))
                    //                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else if(responce["message"] == JSON.null){
                    print("History response with message")
                    
                    print ("Array count is : \(String(describing: self.resolvedComplaints?.arrayComplaints.count))")
                    
                    if ((responce["data"]["complaints"].array?.count)! > 0)
                    {
                        //                        self.resolvedComplaints?.arrayComplaints.removeAll()
                        self.resolvedComplaints = ModelComplaintsData.init(withData:responce)
                        self.hideOverlayView()
                        
                    }
                    
                    if (responce["data"]["total"] != JSON.null)
                    {
                        self.ResolvedAPI_Total = responce["data"]["total"].int
                    }
                    
                    if (self.resolvedComplaints?.arrayComplaints.count == 0 || self.resolvedComplaints?.arrayComplaints.count == nil)
                    {
                        print("Omkar : No data ")
                        self.displayNoData()
                        self.noDataLbl.text="No data found.".localized()
                        
                    }
                    //                    else
                    //                    {
                    //                        print("In last else")
                    //                        self.hideOverlayView()
                    //                    }
                    self.tableView_Resolved.reloadData()
                    print("Removing refresh")
                    self.refreshControl?.endRefreshing()
                }
                else
                {
                    let alert = UIAlertController(title: "Alert".localized(), message: "Login token expired, Please login again.".localized(), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.resolvedComplaints?.arrayComplaints.count ?? 0
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        self.hideOverlayView()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_history") as! HelpDeskTableViewCell
        
        cell.titleLabel?.text = self.resolvedComplaints?.arrayComplaints[indexPath.row].subCategoryName
        cell.titleLabel.font = UIFont(name: "Arial", size: 15.0)
        
        cell.descriptionLabel?.text = self.resolvedComplaints?.arrayComplaints[indexPath.row].description.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        cell.descriptionLabel.font = UIFont(name: "Arial", size: 13.0)
        
        var str:Int?
        
        str = self.resolvedComplaints?.arrayComplaints[indexPath.row].number
        cell.countLabel?.text=NSString(format: "# %d", str!) as String
        
        //        cell.imageLabel?.font = UIFont(name: "botsworth", size: 30)
        
        var priority = self.resolvedComplaints?.arrayComplaints[indexPath.row].priority
        
        cell.imageLabel.layer.masksToBounds = true
        cell.imageLabel.layer.cornerRadius = 0.5 * cell.imageLabel.bounds.size.width
        cell.imageLabel.font = UIFont(name: "Arial", size: 15)
        cell.imageLabel.textColor = UIColor.white
        cell.imageLabel.backgroundColor = getPriorityColor(priority: priority!)
        cell.imageLabel.text = self.resolvedComplaints?.arrayComplaints[indexPath.row].category_short_name
        
        tempStr = self.resolvedComplaints?.arrayComplaints[indexPath.row].complaintCategoryName
        //        if(tempStr == "Electrical") {
        //            cell.imageLabel?.text = String(format: "%C",faicon["Electricity"]!)
        //        }
        //        else if(tempStr == "Civilwork") {
        //            cell.imageLabel?.text = String(format: "%C",faicon["Civil Work"]!)
        //        }
        //        else if(tempStr == "Water") {
        //            cell.imageLabel?.text = String(format: "%C",faicon["Water"]!)
        //        }
        //        else if(tempStr == "Cable TV") {
        //            cell.imageLabel?.text = String(format: "%C",faicon["Cable TV"]!)
        //        }
        //        else if(tempStr == "Citizen’s Billing") {
        //            cell.imageLabel?.text = String(format: "%C",faicon["Billing"]!)
        //        }
        //        else if(tempStr == "Infra Complaint") {
        //            cell.imageLabel?.text = String(format: "%C",faicon["Infra"]!)
        //        }
        //        else if(tempStr == "IT") {
        //            cell.imageLabel?.text = String(format: "%C",faicon["IT"]!)
        //        }
        //        else{
        //            cell.imageLabel?.text = String(format: "%C",faicon["Others"]!)
        //        }
        
        cell.ComplaintIDLbl?.text = self.resolvedComplaints?.arrayComplaints[indexPath.row].id
        cell.statusLbl?.text = self.resolvedComplaints?.arrayComplaints[indexPath.row].aasmState
        
        return cell
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.CallHelpDeskResolvedAPI()
    }
    
    @IBAction func BackTapped(_ sender: AnyObject){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        let lastElement = (self.resolvedComplaints?.arrayComplaints.count)! - 1
        if indexPath.row == lastElement && ResolvedAPI_Total > (self.resolvedComplaints?.arrayComplaints.count)!{
            // handle your logic here to get more items, add it to dataSource and reload tableview
            
            ResolvedAPIPageNo = ResolvedAPIPageNo+1
            self.CallHelpDeskResolvedAPI()
        }
        
        
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
    
    func hideOverlayView() {
        self.overLayView.isHidden = true;
        print("Overlay vies is hidden")
    }
    
    func displayNoData() {
        self.overLayView.isHidden = false;
        self.ActivityIndicator.isHidden = true;
        self.noDataLbl.isHidden = false;
        self.noDataButton.isHidden = false;
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
        
        self.selectedPriority = self.resolvedComplaints?.arrayComplaints[indexPath.row].priority
        self.selectedShortName  = self.resolvedComplaints?.arrayComplaints[indexPath.row].category_short_name
        
        stateStr = self.resolvedComplaints?.arrayComplaints[indexPath.row].aasmState
        FlatIDString = self.resolvedComplaints?.arrayComplaints[indexPath.row].unitInfo
        
        
        //        if(closeBtnView.backgroundColor == UIColor.red)
        //        {
        //            self.performSegue(withIdentifier: "HelpDeskChat", sender: self)
        //        }
        //        else
        //        {
        
        self.performSegue(withIdentifier: "closed_chat", sender: self)
        
        //      }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        var state:String!
        if(segue.identifier == "closed_chat") {
            let chatVC = segue.destination as! HelpDeskChatController
            
            chatVC.StringCategorySubject = subCategory
            chatVC.StringNumber = number
            chatVC.StringImg = imageLbl
            chatVC.StringComplaintID = complaintId
            chatVC.StringState = subCategoryState
            chatVC.OpenORClosed = OpenORClosed as String
            chatVC.gotShortName = self.selectedShortName
            chatVC.gotPriority = self.selectedPriority
            chatVC.FromWhere = "OpenClosedList"
            
        }
    }
    
    func displayLoader() {
        self.overLayView.isHidden = false;
        self.ActivityIndicator.isHidden = false;
        self.noDataLbl.isHidden = true;
        self.noDataButton.isHidden = true;
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
    
    //Segua : closed_chat
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

