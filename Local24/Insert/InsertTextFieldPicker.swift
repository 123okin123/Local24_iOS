//
//  InsertPicker.swift
//  Local24
//
//  Created by Local24 on 27/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

//InsertPicker
extension InsertTableViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        debugPrint(textField)
        
        currentTextField = textField
        
        if let index = customFieldCellCollection.index(where:{$0.textField == currentTextField}) {
            currentPickerArray = customFields[index].possibleValues!
            customFieldCellCollection[index].textField.inputView = pickerView
            customFieldCellCollection[index].textField.inputAccessoryView = toolBar
            if let selectedIndex = customFields[index].possibleValues?.index(where: {$0 == customFieldCellCollection[index].textField.text}) {
                pickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
            } else {
                pickerView.selectRow(0, inComponent: 0, animated: true)
                currentTextField.text = currentPickerArray[0]
            }
        }
        
        switch currentTextField {
        case adTypeTextField:
            adTypeTextField.inputView = pickerView
            adTypeTextField.inputAccessoryView = toolBar
            currentPickerArray = Array(AdType.allValues.values)
        case priceTypeTextField:
            priceTypeTextField.inputView = pickerView
            priceTypeTextField.inputAccessoryView = toolBar
            currentPickerArray = Array(PriceType.allValues.values)
        default: break
        }
        pickerView.reloadAllComponents()
        
        return true
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentPickerArray.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentPickerArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        currentTextField.text = currentPickerArray[row]
    }
    func pickerDonePressed() {
        view.endEditing(true)
    }
    func pickerPreviousPressed() {
    }
    func pickerNextPressed() {
            currentTextField.resignFirstResponder()
    }
    
}
