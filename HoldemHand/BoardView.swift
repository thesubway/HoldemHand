//
//  BoardView.swift
//  HoldemHand
//
//  Created by Dan Hoang on 9/7/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

class BoardView: UIView {
    var pots = [UILabel]()
    var mainPot = UILabel()

    func initializeSelf() {
        self.pots.append(mainPot)
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            //102 is height. Width 77 if text size big.
        }
        else if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            
        }
    }
}
