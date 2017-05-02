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
class RangeCell: Cell<FilterRange>, CellType, UIPickerViewDataSource, UIPickerViewDelegate  {
   
    @IBOutlet weak var lowerLabel: UILabel!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    
    lazy public var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private var rangeRow: RangeRow<Int>! { return row as! RangeRow<Int> }
    private var titles = [String]()
    var lowerValue:Int?
    var upperValue:Int?
    
    public override func setup() {
        super.setup()
        height = {return 75}
        title.text = rangeRow.title
        picker.delegate = self
        picker.dataSource = self
        inputAccessoryView?.tintColor = greencolor
        titles = rangeRow.options.map({
            var option = String(describing: $0)
            if let unit = rangeRow.unit {
            option += unit
            }
            return option
        })
        
    }
  
    
    public override func update() {
        super.update()
        if let lowerBound = rangeRow.value?.lowerBound {
            var lowerBoundString = String(describing: lowerBound)
            if let unit = rangeRow.unit {
                lowerBoundString += unit
            }
            lowerLabel.text = lowerBoundString
        }
        if let upperBound = rangeRow.value?.upperBound {
            var upperBoundString = String(describing: upperBound)
            if let unit = rangeRow.unit {
                upperBoundString += unit
            }
            upperLabel.text = upperBoundString
        }

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
        rangeRow.value = FilterRange(upperBound: upperValue, lowerBound: lowerValue)
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
            lowerValue = rangeRow.options[rowNumber]
        case 1:
            upperLabel.text = titles[rowNumber]
            upperValue = rangeRow.options[rowNumber]
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



struct FilterRange:Equatable {
    var upperBound:Int?
    var lowerBound:Int?
    static func == (lhs: FilterRange, rhs: FilterRange) -> Bool {
        return
            lhs.upperBound == rhs.upperBound &&
            lhs.lowerBound == rhs.lowerBound
    }
}

