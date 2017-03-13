//
//  TabBarController.swift
//  Local24
//
//  Created by Local24 on 23/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

public var tabBarPreferedIndex :Int?


class TabBarController: UITabBarController, UITabBarControllerDelegate {

    var willSelectedIndex = 0
    let insertButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setupInsertButton()
        self.tabBar.shadowImage = UIImage(named: "tabBarShadow")
        self.tabBar.backgroundImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPreferredIndex()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: { [unowned self] in
            if !checkedForAppRating {
                self.checkAppRating()
                checkedForAppRating = true
            }
        })
    }
    
    func setPreferredIndex() {
        if tabBarPreferedIndex != nil {
            _  = self.tabBarController(self, shouldSelect: self.viewControllers![tabBarPreferedIndex!])
            self.selectedIndex = tabBarPreferedIndex!
            self.viewControllers![tabBarPreferedIndex!].viewWillAppear(true)
            tabBarPreferedIndex = nil
        }
    }


    private func setupInsertButton() {
        var insertButtonFrame = insertButton.frame
        insertButtonFrame.origin.y = self.view.bounds.height - insertButtonFrame.height - 15
        insertButtonFrame.origin.x = self.view.bounds.width/2 - insertButtonFrame.width/2
        insertButton.frame = insertButtonFrame
        insertButton.backgroundColor = UIColor.white
        insertButton.layer.cornerRadius = insertButtonFrame.height/2
        insertButton.layer.borderColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1).cgColor
        insertButton.layer.borderWidth = 1
        self.view.addSubview(insertButton)
        insertButton.setImage(UIImage(named: "insert"), for: UIControlState.normal)
        insertButton.addTarget(self, action: #selector(insertButtonAction), for: UIControlEvents.touchUpInside)
        
        self.view.layoutIfNeeded()
    }

    func insertButtonAction() {
        if tabBarController(self, shouldSelect: self.viewControllers![2]) {
        self.selectedIndex = 2
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.index(of: viewController) {
            willSelectedIndex = index
            if index == 2 {
                insertButton.backgroundColor = bluecolor
                insertButton.layer.borderWidth = 0
                insertButton.setImage(UIImage(named: "insert_white"), for: .normal)
            }else {
                insertButton.backgroundColor = UIColor.white
                insertButton.layer.borderWidth = 1
                insertButton.setImage(UIImage(named: "insert"), for: .normal)
            }
            if index == 2 && selectedIndex == 2 || index == 3 && selectedIndex == 3 {
            return false
            }
            
            
        }
        return true
    }
    
    func checkAppRating() {
        let startsSinceAppRating = UserDefaults.standard.integer(forKey: "startsSinceAppRating") + 1
        UserDefaults.standard.set(startsSinceAppRating, forKey: "startsSinceAppRating")
        FIRAnalytics.setUserPropertyString(String(startsSinceAppRating), forName: "starts_since_apprating")
        
        print("startsSinceAppRating:\(startsSinceAppRating)")
        if !hasSeenAppRatingInSession {
            if remoteConfig["showAppRating"].boolValue || forceShowAppRating {
                hasSeenAppRatingInSession = true
                UserDefaults.standard.set(0, forKey: "startsSinceAppRating")
                FIRAnalytics.setUserPropertyString(String(0), forName: "starts_since_apprating")
                presentAppRating()
            }
        }
        
    }
    
    
    
    func presentAppRating() {
        guard let url = URL(string : "itms-apps://itunes.apple.com/de/app/id1089153890") else { return}
        let alert = UIAlertController(title: "Dir gefällt Local24?", message: "Dann würden wir uns freuen, du nimmst dir die Zeit und zeigst es uns.\n\n\u{1F31F} \u{1F31F} \u{1F31F} \u{1F31F} \u{1F31F} \n\n Vielen Dank!", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
            UIApplication.shared.openURL(url)
            FIRAnalytics.setUserPropertyString("true", forName: "has_confirmed_apprating")
        })
        let cancelAction = UIAlertAction(title: "Vieleicht später", style: .default, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    


}
