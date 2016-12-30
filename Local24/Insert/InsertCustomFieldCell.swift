//
//  InsertCustomFieldCell.swift
//  Local24
//
//  Created by Local24 on 27/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class InsertCustomFieldCell: UITableViewCell {

    
    let textField = UITextField()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let frame = CGRect(x: 15, y: 0, width: screenwidth - 30, height: self.contentView.bounds.size.height)
        textField.frame = frame
        textField.textAlignment = .right
        self.addSubview(textField)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
