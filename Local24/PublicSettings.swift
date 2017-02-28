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

 public var remoteConfigDevMode = false
 
befor publishing!!!!

 */



public var localCSS = true
public var dryRunGA = false
public var gaLogging = false


public var searchIndexURL = "https://l24-app-proxy.herokuapp.com"

public var remoteConfig = FIRRemoteConfig.remoteConfig()
public var remoteConfigDevMode = true

public var user :User?
public var userToken :String?
public var tokenValid = true

public var categoryBuilder = Categories()

public let screenwidth = UIScreen.main.bounds.size.width
public let screenheight = UIScreen.main.bounds.size.height
public let greencolor = UIColor(red: 105/255, green: 155/255, blue: 0/255, alpha: 1)
public let bluecolor = UIColor(red: 11/255, green: 106/255, blue: 165/255, alpha: 1)



public func gaUserTracking(_ screenName :String) {
    GAI.sharedInstance().dryRun = dryRunGA
    let tracker = GAI.sharedInstance().defaultTracker
    tracker?.set(kGAIScreenName, value: screenName)
    tracker?.allowIDFACollection = true
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker?.send((builder?.build())!  as NSDictionary as! [AnyHashable: Any])
}

