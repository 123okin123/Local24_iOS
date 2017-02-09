//
//  PublicSettings.swift
//  Local24
//
//  Created by Locla24 on 26/11/15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import UIKit
import WebKit
import FirebaseRemoteConfig
import Firebase

//------Important------//
/*
set
 
 public var localCSS = false
 public var dryRunGA = false
 public var gaLogging = false
 public let mode = "www"
 public var adultContent = true
 public var remoteConfigDevMode = false
 
befor publishing!!!!

 */



public var localCSS = true
public var dryRunGA = false
public var gaLogging = false
public let mode = "www"
public var adultContent = true
public var remoteConfigDevMode = false

public var searchIndexURL = "https://l24-app-proxy.herokuapp.com"

public var remoteConfig = FIRRemoteConfig.remoteConfig()


public var user :User?
public var userToken :String?
public var tokenValid = true
public var categoryBuilder = Categories()
public var networkManager = NetworkManager()

public let screenwidth = UIScreen.main.bounds.size.width
public let screenheight = UIScreen.main.bounds.size.height
public let greencolor = UIColor(red: 105/255, green: 155/255, blue: 0/255, alpha: 1)
public let bluecolor = UIColor(red: 11/255, green: 106/255, blue: 165/255, alpha: 1)

public func showMode(_ webView: WKWebView, view: UIView) {
    if mode == "stage" {
        if let absoluteURL = webView.url?.absoluteString {
            let demoView = UILabel()
            demoView.frame.size = CGSize(width: 100, height: 30)
            demoView.frame.origin = CGPoint(x: screenwidth/2 - 50, y: 100)
            demoView.text = "STAGE"
            demoView.textAlignment = .center
            demoView.textColor = UIColor.white
            demoView.backgroundColor = UIColor.red
            if  absoluteURL.contains("stage") {
                view.addSubview(demoView)
            } else {
                demoView.removeFromSuperview()
            }
        }
    }
}

public func gaUserTracking(_ screenName :String) {
    GAI.sharedInstance().dryRun = dryRunGA
    let tracker = GAI.sharedInstance().defaultTracker
    tracker?.set(kGAIScreenName, value: screenName)
    tracker?.allowIDFACollection = true
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker?.send((builder?.build())!  as NSDictionary as! [AnyHashable: Any])
}

