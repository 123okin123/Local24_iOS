//
//  InitialViewController.swift
//  Local24
//
//  Created by Local24 on 23/01/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
import Firebase

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CategoryManager.shared.getCategories(completion: { (mainCat, subCat, error) in
            if error == nil {
                self.setRemoteConfiguration(completion: {
                    if userToken != nil {
                        NetworkManager.shared.getUserProfile(userToken: userToken!, completion: { (fetchedUser, statusCode) in
                            if statusCode == 200 {
                                user = fetchedUser
                            }
                            self.performSegue(withIdentifier: "initialSegueID", sender: self)
                        })
                    } else {
                        self.performSegue(withIdentifier: "initialSegueID", sender: self)
                    }
                })
            }
        })
    }

    func setRemoteConfiguration(completion: @escaping () -> Void) {
        remoteConfig = FIRRemoteConfig.remoteConfig()
        let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: remoteConfigDevMode)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaultsFromPlistFileName("RemoteConfigDefaults")
        var expirationDuration = 3600
        if remoteConfig.configSettings.isDeveloperModeEnabled ||
            remoteConfig["showAppRating"].boolValue == true {
            expirationDuration = 0
        }
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
            completion()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
