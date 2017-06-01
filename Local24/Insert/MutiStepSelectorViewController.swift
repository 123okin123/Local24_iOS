//
//  MutiStepSelectorViewController.swift
//  Local24
//
//  Created by Nikolai Kratz on 18.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka
import EquatableArray

class MutiStepSelectorViewController: FormViewController, TypedRowControllerType {
    /// The row that pushed or presented this controller
    public var row: RowOf<String>!
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    
    /// The row presenting this VC
    var mutiplePushRow :MutiplePushRow {return row as! MutiplePushRow}
    
  
    
    var viewControllerForStep :Int {return mutiplePushRow.numberOfSteps - 1}
    
    var stepsTaken :Int {return mutiplePushRow.stepsTaken + 1}
 
    override func viewDidLoad() {
        super.viewDidLoad()

        let section = Section()
        for option in(row as! MutiplePushRow).options {
            if viewControllerForStep == 0 {
                section
                <<< LabelRow() {
                    $0.title = option
                    }.onCellSelection { (cell, row) in
                        self.mutiplePushRow.value = row.title
                        self.mutiplePushRow.selectedValues.append(row.title!)
                        self.onDismissCallback!(self)
                }
            } else {
                section
                <<< MutiplePushRow() {
                    $0.numberOfSteps = viewControllerForStep
                    $0.title = option
                    $0.stepsTaken = stepsTaken
                    $0.selectedValues = mutiplePushRow.selectedValues
                    $0.options = mutiplePushRow.optionsForOption!(option, viewControllerForStep)
                    $0.optionsForOption = {(option, step) in
                        return self.mutiplePushRow.optionsForOption!(option, self.viewControllerForStep)
                    }}.onCellSelection {(cell, row) in
                        row.selectedValues.append(row.title!)
                    }
            }
        }
        form
            +++ section
        
    }
    
    
    

    
    
}

