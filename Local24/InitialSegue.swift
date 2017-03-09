//
//  InitialSegue.swift
//  Local24
//
//  Created by Local24 on 09/03/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class InitialSegue: UIStoryboardSegue {
    
    override func perform() {
        let sourceVCView = source.view as UIView!
        let destinationVCView = destination.view as UIView!
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(destinationVCView!, belowSubview: sourceVCView!)
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
        sourceVCView?.alpha = 0
        }, completion: { finished in
        self.source.present(self.destination, animated: false, completion: nil)
        })
    }
    
}

