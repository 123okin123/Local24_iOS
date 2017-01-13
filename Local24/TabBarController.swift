//
//  TabBarController.swift
//  Local24
//
//  Created by Local24 on 23/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import Alamofire

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    var willSelectedIndex = 0
    let insertButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setupInsertButton()
     
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
        self.view.addSubview(insertButton)
        insertButton.layer.shadowColor = UIColor.black.cgColor
        insertButton.layer.shadowOpacity = 0.3
        insertButton.layer.shadowOffset = CGSize.zero
        insertButton.layer.shadowRadius = 3
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
                insertButton.setImage(UIImage(named: "insert_white"), for: .normal)
            }else {
                insertButton.backgroundColor = UIColor.white
                insertButton.setImage(UIImage(named: "insert"), for: .normal)
            }
            if index == 3 && selectedIndex == 3 {
            return false
            }
            
            
        }
        return true
    }


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
