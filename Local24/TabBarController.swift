//
//  TabBarController.swift
//  Local24
//
//  Created by Local24 on 23/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import Alamofire

public var tabBarSelectedIndex :Int?
class TabBarController: UITabBarController, UITabBarControllerDelegate {

    var willSelectedIndex = 0
    let insertButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setupInsertButton()
        self.tabBar.shadowImage = UIImage(named: "tabBarShadow")
        self.tabBar.backgroundImage = UIImage()
        if tabBarSelectedIndex != nil {
        self.selectedIndex = tabBarSelectedIndex!
        _  = self.tabBarController(self, shouldSelect: self.viewControllers![tabBarSelectedIndex!])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    func setupInsertButton() {
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
            if index == 3 && selectedIndex == 3 {
            return false
            }
            
            
        }
        return true
    }

}
