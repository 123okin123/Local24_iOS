//
//  AppDelegate.swift
//  Local24
//
//  Created by Nikolai Kratz on 21.09.15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Alamofire
import Firebase
import FirebaseRemoteConfig
import UserNotifications
import FirebaseDynamicLinks



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate  {

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        loadDataFromDefaults()
        applyCustomStyles()
        
        FilterManager.shared.setfilter(newfilter: Sortfilter(criterium: .createDate, order: .desc))
        
        
        //NOTIFICATIONS REGISTRATION
        application.applicationIconBadgeNumber = 0
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            FIRMessaging.messaging().remoteMessageDelegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        //ADWORDS CONVERSION TRACKING
        ACTConversionReporter.report(withConversionID: "1059198657", label: "vk-bCOu16WgQwa2I-QM", value: "0.50", isRepeatable: false)
      
        // FIREBASE CONFIG
        FIROptions.default().deepLinkURLScheme = "com.scout24.local24"
        FIRApp.configure()

        // STARTED FROM NOTIFICATION
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            if let stringIndex = notification["tabBarSelectedIndex"] as? String {
                tabBarPreferedIndex = Int(stringIndex)
            }
            if let showAppRating = notification["showAppRating"]?.boolValue {
                if showAppRating {
                    forceShowAppRating = true
                }
            }
        }

        
         // FACEBOOK
         FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    // ---------- NOTIFICATIONS ---------- //
    
    // BACKGROUND iOS 10
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let showAppRating = response.notification.request.content.userInfo["showAppRating"] as? String {
            if showAppRating == "true" {
                forceShowAppRating = true
            }
        }
        completionHandler()
    }
    
    // INAPP iOS 10
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint(notification.request.content.userInfo["tabBarSelectedIndex"] as! String)
    }
    
    // For iOS 10 data message (sent via FCM)
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        
    }
    
    // End ---------- NOTIFICATIONS ---------- //


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        //FACEBOOK
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveDataToDefaults()
    }
 


    // ---------- Dynamic Links iOS 10 App not opened for the first time ---------- //
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let dynamicLinks = FIRDynamicLinks.dynamicLinks() else {
            return false
        }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            
            if let url = dynamiclink?.url {
                FilterManager.shared.setFiltersFromURL(url: url)
                tabBarPreferedIndex = 1
                let storybard = UIStoryboard.init(name: "Main", bundle: nil)
                self.window?.rootViewController = storybard.instantiateInitialViewController()
            }
        }
        return handled
    }

    // End ---------- Dynamic Links iOS 10 App not opened for the first time ---------- //
    
    
    
    // -------- Dynamic Links iOS 8 and App opened for the first time ----------  //
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url, sourceApplication: nil, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let dynamicLink = FIRDynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
        FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
            if let url = dynamicLink?.url {
                FilterManager.shared.setFiltersFromURL(url: url)
                tabBarPreferedIndex = 1
                let storybard = UIStoryboard.init(name: "Main", bundle: nil)
                storybard.instantiateInitialViewController()
                self.window?.rootViewController = storybard.instantiateInitialViewController()
                return true
            }
        return false
    }
    // End -------- Dynamic Links iOS 8 and App opened for the first time ---------- End //
    
    
    
    // ------------------- USER DEFAULTS Important: Consider Old App Versions --------------- //
    
    func loadDataFromDefaults() {
        let defaults = UserDefaults.standard
        geoFilterFromDefaults(defaults: defaults)
        categoryFilterFromDefaults(defaults: defaults)
        viewedRegion.center.latitude = defaults.double(forKey: "viewedRegion.center.latitude")
        viewedRegion.center.longitude = defaults.double(forKey: "viewedRegion.center.longitude")
        viewedRegion.span.latitudeDelta = defaults.double(forKey: "viewedRegion.span.latitudeDelta")
        viewedRegion.span.longitudeDelta = defaults.double(forKey: "viewedRegion.span.longitudeDelta")
        userToken = defaults.string(forKey: "userToken")
    }
    
    func saveDataToDefaults() {
        let defaults = UserDefaults.standard
        geoFiltersToDefaults(defaults: defaults)
        categoryFilterToDefaults(defaults: defaults)
        defaults.set("existingUser", forKey: "existingUser")
        defaults.set(viewedRegion.center.latitude, forKey: "viewedRegion.center.latitude")
        defaults.set(viewedRegion.center.longitude, forKey: "viewedRegion.center.longitude")
        defaults.set(viewedRegion.span.latitudeDelta, forKey: "viewedRegion.span.latitudeDelta")
        defaults.set(viewedRegion.span.longitudeDelta, forKey: "viewedRegion.span.longitudeDelta")
        
        if userToken != nil {
            defaults.set(userToken!, forKey: "userToken")
        } else {
            defaults.removeObject(forKey: "userToken")
        }
    }
    
    private let geoFilterValue = "geoFilterValue"
    func geoFilterFromDefaults(defaults :UserDefaults)  {
        guard let value = defaults.string(forKey: geoFilterValue) else {return}
        let long = defaults.double(forKey: "lon")
        let lat = defaults.double(forKey: "lat")
        let distance = defaults.double(forKey: "distance")
        guard long != 0 else {return }
        guard lat != 0 else {return }
        guard distance != 0 else {return }
        let geofilter = Geofilter(lat: lat, lon: long, distance: distance, value: value)
        FilterManager.shared.setfilter(newfilter: geofilter)
    }
    
    func geoFiltersToDefaults(defaults :UserDefaults) {
        if let geoFilter = FilterManager.shared.getFilter(withName: .geo_distance) as? Geofilter {
            defaults.set(geoFilter.value, forKey: geoFilterValue)
            defaults.set(geoFilter.lon, forKey: "lon")
            defaults.set(geoFilter.lat, forKey: "lat")
            defaults.set(geoFilter.distance, forKey: "distance")
        }
    }
    
    private let catFilterValue = "catFilterValue"
    private let subCatFilterValue = "subCatFilterValue"
    func categoryFilterToDefaults(defaults:UserDefaults) {
        if let catFilter = FilterManager.shared.getFilter(withName: .category) as? Termfilter {
            defaults.set(catFilter.value, forKey: catFilterValue)
            if let subCatFilter = FilterManager.shared.getFilter(withName: .subcategory) as? Termfilter {
                defaults.set(subCatFilter.value, forKey: subCatFilterValue)
            } else {
                defaults.removeObject(forKey: subCatFilterValue)
            }
        } else {
            defaults.removeObject(forKey: catFilterValue)
            defaults.removeObject(forKey: subCatFilterValue)
        }
    }
    
    func categoryFilterFromDefaults(defaults :UserDefaults) {
        if let catValue = defaults.string(forKey: catFilterValue) {
            let filter = Termfilter(name: .category, descriptiveString: "Kategorie", value: catValue)
            FilterManager.shared.setfilter(newfilter: filter)
            if let subCatValue = defaults.string(forKey: subCatFilterValue) {
                let filter = Termfilter(name: .subcategory, descriptiveString: "Unterkategorie", value: subCatValue)
                FilterManager.shared.setfilter(newfilter: filter)
            }
        }
    }
    
    
    // End  ------------------- USER DEFAULTS Important: Consider Old App Versions --------------- //
    
    
    
    func applyCustomStyles() {
        window?.tintColor = greencolor
        let tabBarFont = UIFont(name: "OpenSans", size: 10.0)!
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: bluecolor, NSFontAttributeName: tabBarFont ], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: tabBarFont ], for: UIControlState())
        UITabBar.appearance().tintColor = UIColor(red: 0/255, green: 80/255, blue: 141/255, alpha: 1)
        let navBarFont = UIFont(name: "OpenSans-Semibold", size: 17.0)!
        let buttonFont = UIFont(name: "OpenSans", size: 18.0)!
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navBarFont]
        UIButton.appearance().titleLabel?.font = buttonFont
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = greencolor
        let segControllFont = UIFont(name: "OpenSans", size: 13.0)!
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: segControllFont], for: UIControlState.selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: segControllFont], for: UIControlState())
        UIApplication.shared.statusBarStyle = .lightContent
    }
    

    

}


