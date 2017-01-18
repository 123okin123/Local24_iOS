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

public var myContext = 0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var filter = Filter()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        loadDataFromDefaults()
     
        let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
        let tabBarVC = window!.rootViewController!
        tabBarVC.view.addSubview(launchScreen.view)
        let indicator = UIActivityIndicatorView()
        indicator.frame.size = CGSize(width: 50, height: 50)
        indicator.frame.origin = CGPoint(x: (launchScreen.view.frame.size.width/2) - 25, y: launchScreen.view.bounds.height - 120)
        indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
        indicator.color = UIColor.lightGray
        launchScreen.view.addSubview(indicator)
        indicator.startAnimating()
        
        categoryBuilder.getCategories(completion: { (mainCat, subCat, error) in
            if error == nil {
                if userToken != nil {
                    networkController.getUserProfile(userToken: userToken!, completion: { (fetchedUser, statusCode) in
                        if statusCode == 200 {
                            user = fetchedUser
                        }
                            UIView.transition(with: tabBarVC.view, duration: 0.2, options: .curveEaseIn, animations: {
                                launchScreen.view.alpha = 0
                            }, completion: { done in
                                indicator.stopAnimating()
                                launchScreen.view.removeFromSuperview()
                            })
                        
                    })
                } else {
                    UIView.transition(with: tabBarVC.view, duration: 0.2, options: .curveEaseIn, animations: {
                        launchScreen.view.alpha = 0
                    }, completion: { done in
                        launchScreen.view.removeFromSuperview()
                    })
                }

            }
        })
        
        
        applyCustomStyles()

        
        
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        if gaLogging {
        gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
        }
       
        //ADWORDS CONVERSION TRACKING
        ACTConversionReporter.report(withConversionID: "1059198657", label: "vk-bCOu16WgQwa2I-QM", value: "0.50", isRepeatable: false)
      
        // FIREBASE CONFIG
        FIRApp.configure()
        
         // FACEBOOK
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

    }

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
        //FACEBOOK
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        saveDataToDefaults()
    }
 
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      
        

        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        print("wooooooooorks")
        /*
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        
        // if condition is met Do something and return true
        if components.path.contains("/mein-local24/")  {
            if let tvc = self.window?.rootViewController as? UITabBarController {
                tvc.selectedIndex = 3
                return true
            }
        }
        if components.path.contains("/anzeige-aufgeben/")  {
            if let tvc = self.window?.rootViewController as? UITabBarController {
                tvc.selectedIndex = 2
                return true
            }
        }
 */
        /* Example:
         
         if let computer = ItemHandler.sharedInstance.items.filter({ $0.path == components.path}).first {
         self.presentDetailViewController(computer)
         return true
         }
         */
        
        
        return Branch.getInstance().continue(userActivity)
 
    }

    

    
    
    
    
    
    func loadDataFromDefaults() {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "existingUser") != nil {
            if let sZ = defaults.string(forKey: "searchZip") {filter.searchZip = sZ}
            if let minP = defaults.string(forKey: "minPrice") {filter.minPrice = minP}
            if let maxP = defaults.string(forKey: "maxPrice") {filter.maxPrice = maxP}
            if let sls = defaults.string(forKey: "searchLocationString") {filter.searchLocationString = sls}
            filter.searchLong = defaults.double(forKey: "long")
            filter.searchLat = defaults.double(forKey: "lat")
            filter.searchRadius = defaults.integer(forKey: "radius")
            filter.mainCategoryID = defaults.integer(forKey: "mainCategoryID")
            filter.subCategoryID = defaults.integer(forKey: "subCategoryID")
            filter.viewedRegion.center.latitude = defaults.double(forKey: "viewedRegion.center.latitude")
            filter.viewedRegion.center.longitude = defaults.double(forKey: "viewedRegion.center.longitude")
            filter.viewedRegion.span.latitudeDelta = defaults.double(forKey: "viewedRegion.span.latitudeDelta")
            filter.viewedRegion.span.longitudeDelta = defaults.double(forKey: "viewedRegion.span.longitudeDelta")
            filter.onlyLocalListings = defaults.bool(forKey: "onlyLocalListings")
            userToken = defaults.string(forKey: "userToken")
        }
    }
    func saveDataToDefaults() {
        let defaults = UserDefaults.standard
        defaults.set("existingUser", forKey: "existingUser")
        defaults.set(filter.searchZip, forKey: "searchZip")
        defaults.set(filter.minPrice, forKey: "minPrice")
        defaults.set(filter.maxPrice, forKey: "maxPrice")
        defaults.set(filter.searchLocationString, forKey: "searchLocationString")
        defaults.set(filter.searchLong, forKey: "long")
        defaults.set(filter.searchLat, forKey: "lat")
        defaults.set(filter.searchRadius, forKey: "radius")
        defaults.set(filter.mainCategoryID, forKey: "mainCategoryID")
        defaults.set(filter.subCategoryID, forKey: "subCategoryID")
        defaults.set(filter.viewedRegion.center.latitude, forKey: "viewedRegion.center.latitude")
        defaults.set(filter.viewedRegion.center.longitude, forKey: "viewedRegion.center.longitude")
        defaults.set(filter.viewedRegion.span.latitudeDelta, forKey: "viewedRegion.span.latitudeDelta")
        defaults.set(filter.viewedRegion.span.longitudeDelta, forKey: "viewedRegion.span.longitudeDelta")
        defaults.set(filter.onlyLocalListings, forKey: "onlyLocalListings")
        if userToken != nil {
            defaults.set(userToken!, forKey: "userToken")
        } else {
            defaults.removeObject(forKey: "userToken")
        }

    }

    
    
    func applyCustomStyles() {
        window?.tintColor = greencolor
        let tabBarFont = UIFont(name: "OpenSans", size: 10.0)!
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: bluecolor, NSFontAttributeName: tabBarFont ], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: tabBarFont ], for: UIControlState())
        UITabBar.appearance().tintColor = UIColor(red: 0/255, green: 80/255, blue: 141/255, alpha: 1)
        let navBarFont = UIFont(name: "OpenSans-Semibold", size: 17.0)!
        let buttonFont = UIFont(name: "OpenSans", size: 18.0)!
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navBarFont, NSForegroundColorAttributeName: UIColor.white,]
        UIButton.appearance().titleLabel?.font = buttonFont
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = greencolor
        let segControllFont = UIFont(name: "OpenSans", size: 13.0)!
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: segControllFont],
                                                               for: UIControlState.selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: segControllFont],
                                                               for: UIControlState())
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    
}

