//
//  InsertViewController.swift
//  Local24
//
//  Created by Nikolai Kratz on 11.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAnalytics

class InsertViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      
        
        form
            +++ Section()
            <<< ImageSelectorRow() {
            $0.images = [UIImage(),UIImage()]
            }
            +++ Section()
            <<< SegmentedRow<String>() {
                $0.options = ["Ich suche","Ich biete"]
                $0.value = "Ich suche"
            }
            <<< TextRow() {
                $0.placeholder = "Titel"
            }
            <<< PushRow<String>() {
                $0.title = "Kategorie"
            }
            +++ Section("Beschreibung")
            <<< TextAreaRow()
        
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Anzeige aufgeben"
            }
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
