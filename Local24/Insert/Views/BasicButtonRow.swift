//
//  BasicButtonRow.swift
//  Local24
//
//  Created by Nikolai Kratz on 31.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka



// Custom Cell with value type: Bool
// The cell is defined using a .xib, so we can set outlets :)
public class BasicButtonCell: Cell<Bool>, CellType {
   
    @IBOutlet weak var button: UIButton!
    
    
    
    override public func setup() {
        super.setup()
        button.layer.cornerRadius = 10
        height = {return 45}
        backgroundColor = UIColor.clear
        button.titleLabel?.text = row.title
        selectionStyle = .none
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        row.value = (row.value ?? false) ? false : true
        (row as! BasicButtonRow).buttonPressedCallback?(self, self.row)
    }
    
    override public func update() {
        super.update()
        
    }

}

// The custom Row also has the cell: CustomCell and its correspond value
public final class BasicButtonRow: Row<BasicButtonCell>, RowType {
    
    public var buttonPressedCallback: ((_ cell:BaseCell, _ row:BaseRow) -> Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<BasicButtonCell>(nibName: "BasicButtonCell")
    }
    
    
}
