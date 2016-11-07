//
//  TitleTableViewCell.swift
//  Local24
//
//  Created by Local24 on 09/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    
    @IBOutlet weak var adTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
