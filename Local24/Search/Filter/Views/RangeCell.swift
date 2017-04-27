//
//  Rangecell.swift
//  Local24
//
//  Created by Nikolai Kratz on 27.04.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//


import Eureka
import UIKit

// Custom Cell with value type: Bool
// The cell is defined using a .xib, so we can set outlets :)
class RangeCell: Cell<Range<Double>>, CellType, UIPickerViewDataSource, UIPickerViewDelegate  {
   
    @IBOutlet weak var lowerLabel: UILabel!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    
    lazy public var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private var rangeRow: RangeRow<Double>! { return row as! RangeRow<Double> }
    private var titles = [String]()
    
    
    public override func setup() {
        super.setup()
        height = {return 90}
        title.text = rangeRow.title
        picker.delegate = self
        picker.dataSource = self
        titles = rangeRow.options.map({String(describing: Int($0)) + rangeRow.unit!})
    }
  
    
    public override func update() {
        super.update()

    }
    
    deinit {
        picker.delegate = nil
        picker.dataSource = nil
    }
    
    override var inputView: UIView? {
        return picker
    
    }
    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder
    }
    
    override open var canBecomeFirstResponder: Bool {
        return !rangeRow!.isDisabled
    }
    
    override func resignFirstResponder() -> Bool {
        rangeRow.value = Range(uncheckedBounds: (lower: 1, upper: 2))
        return super.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow rowNumber: Int, inComponent component: Int) {
        switch component {
        case 0:
            lowerLabel.text = titles[rowNumber]
        case 1:
            upperLabel.text = titles[rowNumber]
        default:
            break
        }
        rangeRow?.updateCell()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class RangeRow<T:Equatable>: Row<RangeCell>, RowType  {
    
    
    
    var unit:String?
    var options = [T]()
   
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<RangeCell>(nibName: "RangeCell")
    }
}
