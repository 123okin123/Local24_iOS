//
//  PriceTableViewCell.swift
//  Local24
//
//  Created by Local24 on 09/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
class PriceTableViewCell: UITableViewCell {

    @IBOutlet weak var adPriceLabel: UILabel!
    @IBOutlet weak var contactButton: UIButton! {didSet {
        contactButton.layer.cornerRadius = 5
        }}
    
    @IBOutlet weak var phoneButton: UIButton! {didSet {
        phoneButton.layer.cornerRadius = 5
        }}
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
            }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
