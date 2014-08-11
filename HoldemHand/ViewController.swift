//
//  ViewController.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/9/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func playPressed(sender: AnyObject) {
        var holdemView = self.storyboard.instantiateViewControllerWithIdentifier("holdemView") as HoldemViewController
        if self.navigationController {
            self.navigationController.pushViewController(holdemView, animated: true)
        }
    }

}

