//
//  HomeHeaderCollectionReusableView.swift
//  Local24
//
//  Created by Local24 on 24/01/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class HomeHeaderCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var currentLocationButton: UIButton!
    
    override func layoutSubviews() {
            /*
            searchBar.setImage(UIImage(named: "lupe_grau"), for: UISearchBarIcon.search, state: UIControlState())
            let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
            if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
                let font = UIFont(name: "OpenSans", size: 13.0)
                let attributeDict = [
                    NSFontAttributeName: font!,
                    NSForegroundColorAttributeName: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                ]
                searchTextField!.attributedPlaceholder = NSAttributedString(string: "Wonach suchst du?", attributes: attributeDict)
            }
            searchTextField?.textColor = UIColor.gray
            */
        }
  
    
}
