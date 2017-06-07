//
//  AccountHeaderView.swift
//  Local24
//
//  Created by Local24 on 21/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
@IBDesignable
class AccountHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var userView: UIView! {didSet { userView.layer.cornerRadius = 35}}
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userInitialsLabel: UILabel!
    @IBOutlet weak var totalAdsCountLabel: UILabel!
    
}
