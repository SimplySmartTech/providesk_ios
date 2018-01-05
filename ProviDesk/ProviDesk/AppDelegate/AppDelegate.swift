//
//  AppDelegate.swift
//  ProviDesk
//
//  Created by Omkar Awate on 19/09/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import AWSCore
import AWSCognito
import SlideMenuControllerSwift
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UIGestureRecognizerDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var helpResponceDic : JSON = JSON(0)
    
    var WS_Obj : WebServiceClass = WebServiceClass()
    var isUpdateNeededFlag : Bool? = false
    var isCheckUpdateAPICallNeeded : Bool? = true
    //checking pivotal integration
    var window1: UIWindow?
    //    var videoPlayer: MPMoviePlayerController!
    var navigationController:UINavigationController!
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    // Save Help Desk - values
    // Save Notification - values
    var notificationResponceDic : JSON = JSON(0)
    var sensorResponceDic : JSON = JSON(0)


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.loadScreens(self)
        self.registerForPushNotifications(application: application)
        
        AWSLogger.default().logLevel = .verbose
        
        AWSCognitoCredentialsProvider.initialize()
        
        
        
        self.window?.makeKeyAndVisible()
        self.window!.backgroundColor = UIColor.white
        
        
        //AWS Configuration
        
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: AWSConstant.AWS_UNIQEID)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
//        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
//        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
//        application.registerUserNotificationSettings(pushNotificationSettings)
//        application.registerForRemoteNotifications()
        
        return true
    }

//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        print("DEVICE TOKEN = \(deviceToken.base64EncodedData().)")
//        let   tokenString = deviceToken.reduce("", {$0 + String(format: "%02X",    $1)})
//        // kDeviceToken=tokenString
//        print("deviceToken: \(tokenString)")
//    }
    
    private func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Remote notification")
        print(userInfo)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ProviDesk")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func registerForPushNotifications(application: UIApplication) {
        
        let notificationSettings = UIUserNotificationSettings(
            types: [.sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        UserDefaults.standard.set(token, forKey: "Push_Notificaiton_Token")
        UserDefaults.standard.synchronize()
        print("device token\(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    
    func loadScreens(_ sender: AnyObject) {
        
        let name=UserDefaults.standard.string(forKey: "autoLogIn")
        
//        let firstLogin = UserDefaults.standard.string(forKey: "FirstLogIn")
        
        
        if name=="Yes"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "HelpDesk") as! HelpDeskController_V2
            let mainViewCon = UINavigationController(rootViewController: mainViewController)
            let leftViewController = storyboard.instantiateViewController(withIdentifier: "leftMenu") as! LeftMenuController
            let slideMenuController = SlideMenuController(mainViewController:mainViewCon,leftMenuViewController:leftViewController)
            
            self.window?.rootViewController = slideMenuController
            
        
            print("YES-->\(name)")
        }
        else{
            
            let loginView = storyboard.instantiateViewController(withIdentifier: "logInVC") as? LoginViewController
            let mainViewCon = UINavigationController(rootViewController: loginView!)
            self.window?.rootViewController = mainViewCon
            
            print("NO-->\(name)")
        }
    }
    
    
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification \(userInfo)")
//        self.showBanner(userInfo: userInfo)
        let type = JSON(userInfo)["aps"]["code"].stringValue
        if UIApplication.shared.applicationState == UIApplicationState.background || UIApplication.shared.applicationState == UIApplicationState.inactive{
            //            if type == "3" || type == "2" {
            self.goAnotherVC(userInfo: userInfo)
            //            }
            //            else
            //            {
            //                print("Of different type")
            //                let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //
            //                // call didFinishLaunchWithOptions ... why?
            //                appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
            //            }
        }
        else
            if UIApplication.shared.applicationState == UIApplicationState.active{

                print("Application is in active state.")

                //                goAnotherVC(userInfo: userInfo)
                //                self.userInfo1 = userInfo
                //                let tapReco = UITapGestureRecognizer(target: self, action: #selector(goAnotherVC_V2))
                //                tapReco.delegate = self
                //                let alert = JSON(userInfo)["aps"]["alert"].stringValue
                //                //                        print(userInfo)
                //                let banner = Banner(title: "", subtitle: alert, image: UIImage(named: "Icon"), backgroundColor: UIColor.clear)
                ////                banner.addGestureRecognizer(tapReco)
                ////                                banner.didTap(tapReco)
                ////                                        banner.dismissesOnTap = true
                //                banner.show(duration: 3.0)



                //                var topViewController = self.window?.rootViewController!
                //                while (topViewController?.presentedViewController != nil) {
                //                    topViewController = topViewController?.presentedViewController!
                //                }
                //                print("topViewController is : \(topViewController?.description)")
                var vc1: UIViewController = UIViewController()
                if let wd = self.window {
                    var vc = wd.rootViewController
                    print("rootViewController\(vc)")
                    if(vc is SlideMenuController){
                        vc = (vc as! SlideMenuController).mainViewController
                        print("Current VC is : \(vc?.description)")
                        vc1 = (vc as! UINavigationController).visibleViewController!
                        print("Current VC1 is : \(vc1.description)")
                    }
                    if type == "3" {
                        if vc1.isKind(of: HelpDeskChatController.self){
                            //your code
                            print("Dashboard is current viewcontroller")
                            var helpdesk = vc1 as! HelpDeskChatController
                            print("Helpdesk controller complaint id : \(helpdesk.StringComplaintID)")
                            let complaintID = JSON(userInfo)["aps"]["data"]["notification"]["noticeable_id"].stringValue
                            print("complaintID : \(complaintID)")

                            if complaintID == helpdesk.StringComplaintID{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChatDetail"), object: nil, userInfo: userInfo)
                            }
                            else{
//                                self.showBanner(userInfo: userInfo)
                                //                                let alert = JSON(userInfo)["aps"]["alert"].stringValue
                                //                                //                        print(userInfo)
                                //                                let banner = Banner(title: "", subtitle: alert, image: UIImage(named: "Icon"), backgroundColor: UIColor.clear)
                                //                                //                banner.addGestureRecognizer(tapReco)
                                //                                //                                banner.didTap(tapReco)
                                //                                //                                        banner.dismissesOnTap = true
                                //                                banner.show(duration: 3.0)
                            }

                        }

                        else{
//                            self.showBanner(userInfo: userInfo)
                            //                            let alert = JSON(userInfo)["aps"]["alert"].stringValue
                            //                            //                        print(userInfo)
                            //                            let banner = Banner(title: "", subtitle: alert, image: UIImage(named: "Icon"), backgroundColor: UIColor.clear)
                            //                            //                banner.addGestureRecognizer(tapReco)
                            //                            //                                banner.didTap(tapReco)
                            //                            //                                        banner.dismissesOnTap = true
                            //                            banner.show(duration: 3.0)
                        }
                    }else if type == "1" {
                        if vc1.isKind(of: NotificationController.self) {
                            print("Notification is current viewcontroller")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationDetail"), object: nil, userInfo: userInfo)
                        }
                        else{
//                            self.showBanner(userInfo: userInfo)
                            //                            let alert = JSON(userInfo)["aps"]["alert"].stringValue
                            //                            //                        print(userInfo)
                            //                            let banner = Banner(title: "", subtitle: alert, image: UIImage(named: "Icon"), backgroundColor: UIColor.clear)
                            //                            //                banner.addGestureRecognizer(tapReco)
                            //                            //                                banner.didTap(tapReco)
                            //                            //                                        banner.dismissesOnTap = true
                            //                            banner.show(duration: 3.0)
                        }
                    }
                    else if type == "2" {
                        if vc1.isKind(of: HelpDeskController_V2.self) {
                            print("Notification is current viewcontroller")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewComplaint"), object: nil, userInfo: userInfo)
                        }
                        else{
//                            self.showBanner(userInfo: userInfo)
                        }
                    }
                    else{
//                        self.showBanner(userInfo: userInfo)
                        //                        let alert = JSON(userInfo)["aps"]["alert"].stringValue
                        //                        //                        print(userInfo)
                        //                        let banner = Banner(title: "", subtitle: alert, image: UIImage(named: "Icon"), backgroundColor: UIColor.clear)
                        //                        //                banner.addGestureRecognizer(tapReco)
                        //                        //                                banner.didTap(tapReco)
                        //                        //                                        banner.dismissesOnTap = true
                        //                        banner.show(duration: 3.0)
                    }
                }
                else{

//                    self.showBanner(userInfo: userInfo)
                    //                    let alert = JSON(userInfo)["aps"]["alert"].stringValue
                    //                    //                        print(userInfo)
                    //                    let banner = Banner(title: "", subtitle: alert, image: UIImage(named: "Icon"), backgroundColor: UIColor.clear)
                    //                    //                banner.addGestureRecognizer(tapReco)
                    //                    //                                banner.didTap(tapReco)
                    //                    //                                        banner.dismissesOnTap = true
                    //                    banner.show(duration: 3.0)
                }



        }
//                let alert = JSON(userInfo)["aps"]["alert"].stringValue
//                print(userInfo)
//                let banner = Banner(title: "", subtitle: alert, image: UIImage(named: "Icon"), backgroundColor: UIColor.clear)
//                banner.dismissesOnTap = true
//                banner.show(duration: 3.0)
    }
    
    func showBanner(userInfo: [AnyHashable : Any]) {
        let alert = JSON(userInfo)["aps"]["alert"].stringValue
        print(userInfo)
        let banner = Banner(title: "", subtitle: alert, image: UIImage(named: "Icon"), backgroundColor: UIColor.clear)
//                        banner.addGestureRecognizer(tapReco)
//                                        banner.didTap(tapReco)
//                                                banner.dismissesOnTap = true
        banner.show(duration: 3.0)
    }
    
    
    func goAnotherVC(userInfo: [AnyHashable : Any]) {
        
        self.loadScreens(self)
        
        let type = JSON(userInfo)["aps"]["code"].stringValue
        
        if type == "3" || type == "2" {
            
            
            print("In goAnotherVC")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationController = storyboard.instantiateViewController(withIdentifier: "HelpDeskChat") as? HelpDeskChatController
            let data = JSON(userInfo)["aps"]["data"]["notification"].dictionary
            //        print("ID : \(String(describing: data?["id"]))")
            
            destinationController?.StringCategorySubject = JSON(userInfo)["aps"]["category"].stringValue
            destinationController?.StringNumber = data?["id"]?.stringValue
            destinationController?.StringImg = JSON(userInfo)["aps"]["category"].stringValue
            destinationController?.StringComplaintID = data?["noticeable_id"]?.stringValue
            //        destinationController.StringState =
            //        destinationController.OpenORClosed  = "open"
            destinationController?.FromWhere = "notification"
            
            
            //        let navigationController =
            self.window?.rootViewController = destinationController
            print("after goAnotherVC")
        }else
            if type == "1"{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationController = storyboard.instantiateViewController(withIdentifier: "HelpDeskChat") as? NotificationController
                destinationController?.FromDashboard = "YES"
                //            destinationController?.fromWhere = "notification"
                self.window?.rootViewController = destinationController
        }
        
    }
    
    
}

