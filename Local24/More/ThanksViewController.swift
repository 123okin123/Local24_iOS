//
//  ThanksViewController.swift
//  Local24
//
//  Created by Local24 on 20/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class ThanksViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var textToShow :String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: textToShow, ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                textView.text = myStrings.joined(separator: "\n")
                textView.contentOffset.y = 0
            } catch {
                textView.text = String(describing: error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("More/ThanksOverview/ThanksTo: \(textToShow!)")
    }

}
