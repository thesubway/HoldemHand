//
//  BoardView.swift
//  HoldemHand
//
//  Created by Dan Hoang on 9/7/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

class BoardView: UIView {
    var pots = [SidePotLabel]()
    var mainPot = UILabel()

    func initializeSelf() {
//        self.pots.append(mainPot)
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            //102 is height. Width 77 if text size big.
        }
        else if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            
        }
    }
    func updateSelf() {
        //start out with mainPot
        for var i = 0; i < self.pots.count; i++ {
            var xPos = (i+1) * 77
            var eachPot = self.pots[i]
            eachPot.frame = CGRectMake(CGFloat(xPos), 102, 77, 20)
            eachPot.text = "Pot \(i): \(eachPot.sidePot.potSize)"
            self.addSubview(eachPot)
            println(eachPot.text)
            println()
        }
    }
}
