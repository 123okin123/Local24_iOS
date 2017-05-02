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




public var localCSS = true

public var searchIndexURL = "https://l24-app-proxy.herokuapp.com"

public var remoteConfig = FIRRemoteConfig.remoteConfig()
public var remoteConfigDevMode = false

public var user :User?
public var userToken :String?
public var tokenValid = true


public let screenwidth = UIScreen.main.bounds.size.width
public let screenheight = UIScreen.main.bounds.size.height
public let greencolor = UIColor(red:  60/255, green: 167/255, blue: 3/255, alpha: 1)
public let lightgreencolor = UIColor(red:  70/255, green: 177/255, blue: 13/255, alpha: 1)
public let bluecolor = UIColor(red: 11/255, green: 93/255, blue: 165/255, alpha: 1)
public let local24grey = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)

public func trackScreen(_ screenName :String) {
    FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
        kFIRParameterItemName: screenName as NSObject
        ])
}


