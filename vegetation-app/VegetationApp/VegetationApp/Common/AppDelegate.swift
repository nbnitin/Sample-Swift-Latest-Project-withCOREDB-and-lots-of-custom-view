//
//  AppDelegate.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 26/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CoreData
import Firebase
import FirebaseMessaging
import SDWebImage
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        
        SDWebImageManager.shared().imageCache?.config.maxCacheAge = 60*60*24*7 //1 week

        
        //Firebase
        FirebaseApp.configure()
        
       
//        //clearing cache of sd web image
//        SDImageCache.shared().clearMemory()
//        SDImageCache.shared().clearDisk()
        
            if let user = GetSaveUserDetailsFromUserDefault.getDetials() {
                
                if ( !user.IsDefaultPassword ) {
                    let sb = UIStoryboard(name: "Home", bundle: nil) //Home
                    let vc = sb.instantiateInitialViewController()
                    window?.rootViewController = vc
                    window?.makeKeyAndVisible()
                } else {
                    let sb = UIStoryboard(name: "Main", bundle: nil) //Home
                    let vc = sb.instantiateViewController(withIdentifier: "changePassword") as! ResetPassword
                    vc.oldPassword = UserDefaults.standard.value(forKey:"oldPassword") as! String
                    window?.rootViewController = vc
                    window?.makeKeyAndVisible()
                }
            } else {
                let sb = UIStoryboard(name: "Main", bundle: nil) //Home
                let vc = sb.instantiateInitialViewController()
                window?.rootViewController = vc
                window?.makeKeyAndVisible()
            }
        
        
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        UNUserNotificationCenter.current().delegate = self
        
        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Accept",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Decline",
                                                 options: UNNotificationActionOptions(rawValue: 0))
        // Define the notification type
        if #available(iOS 11.0, *) {
            let meetingInviteCategory =
                UNNotificationCategory(identifier: "WORK_ORDER_INVITATION",
                                       actions: [acceptAction, declineAction],
                                       intentIdentifiers: [],
                                       hiddenPreviewsBodyPlaceholder: "",
                                       options: .customDismissAction)
        
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([meetingInviteCategory])

        }

        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        return true
                    
        
    }
    
    //FCM
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
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
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "VegetationApp")
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

}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option, helps to show notification when app is in foreground
        completionHandler([.alert,.sound,.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo as! [String:AnyObject]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if let messageWorkOrderID = userInfo["Id"]   {
            let moduleType = (userInfo["ModuleType"] as! NSString).integerValue
            let id = (messageWorkOrderID as! NSString).integerValue
            // Perform the task associated with the action.
            switch response.actionIdentifier {
            case "ACCEPT_ACTION":
                NotificationHandler.shared.updateWorkOrder(status: 1,workOrderId: (messageWorkOrderID as! NSString).integerValue,assignTo:-1,completionHandler:{(response,error) in
                    
                    
                    
                })
                break
                
            case "DECLINE_ACTION":
                NotificationHandler.shared.updateWorkOrder(status: -1,workOrderId: (messageWorkOrderID as! NSString).integerValue,assignTo:-1,completionHandler:{(response,error) in
                    
                    
                    
                })
                break
                
                // Handle other actions…
                
            default:
                let navigationController    = self.window?.rootViewController as? UINavigationController
                navigationController?.view.showLoad()
                switch moduleType {
                case ModuleType.HAZARDTREE.rawValue:
                    NotificationHandler.shared.getData(type: moduleType, id: id, completionHandler: {(response,error) in
                        navigationController?.view.hideLoad()

                        if ( error != nil ) {
                            navigationController?.showAlert(str: (error?.localizedDescription)!)
                            return
                        }
                        
                        let hazardTreeData = response as! HazardTreeModel
                        let storyBoard = UIStoryboard.init(name: "HazardTree", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "hazardTreeDetailVC") as! HazardTreeDetailVC
                        vc.hazardTreeData = hazardTreeData
                        //vc.isFromNotification = true
                        navigationController?.visibleViewController?.navigationController?.pushViewController(vc, animated: true)
                    })
                    break
                case ModuleType.CYCLETRIM.rawValue:
                    NotificationHandler.shared.getData(type: moduleType, id: id, completionHandler: {(response,error) in
                        navigationController?.view.hideLoad()

                        if ( error != nil ) {
                            navigationController?.showAlert(str: (error?.localizedDescription)!)
                            return
                        }
                        
                        let cycleTrimData = response as! CycleTrimModel
                        let storyBoard = UIStoryboard.init(name: "CycleTrim", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "cycleTrimDetailVC") as! CycleTrimDetailVC
                        vc.cycleTrimData = cycleTrimData
                        //vc.isFromNotification = true
                        navigationController?.visibleViewController?.navigationController?.pushViewController(vc, animated: true)
                    })
                    break
                case ModuleType.HOTSPOT.rawValue:
                    NotificationHandler.shared.getData(type: moduleType, id: id, completionHandler: {(response,error) in
                        navigationController?.view.hideLoad()

                        if (error != nil) {
                            navigationController?.showAlert(str: (error?.localizedDescription)!)
                            return
                        }
                        
                        let hotSpotData = response as! HotSpotModel
                        let storyBoard = UIStoryboard.init(name: "HotSpot", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "hotSpotDetailVC") as! HotSpotDetailVC
                        vc.hotSpotData = hotSpotData
                        //vc.isFromNotification = true
                        navigationController?.visibleViewController?.navigationController?.pushViewController(vc, animated: true)
                    })
                    break
                    
                default:
                    NotificationHandler.shared.getData(type: moduleType, id: id, completionHandler: {(response,error) in
                        navigationController?.view.hideLoad()
                        
                        if ( error != nil ) {
                            navigationController?.showAlert(str: (error?.localizedDescription)!)
                            return
                        }

                        let workOrderData = response as! WorkOrderModel
                        let storyBoard = UIStoryboard.init(name: "WorkOrder", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "workOrderDetailVC") as! WorkOrderDetailVC
                        vc.workOrderData = workOrderData
                        vc.isFromNotification = true
                        navigationController?.visibleViewController?.navigationController?.pushViewController(vc, animated: true)
                    })
                    break
                }
                
                break
            }
            
        }
       
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "token")
        
//        let dataDict:[String: String] = ["token": fcmToken]
//        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

