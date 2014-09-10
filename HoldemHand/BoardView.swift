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

    }
    func updateSelf() {
        //start out with mainPot
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            for var i = 0; i < self.pots.count; i++ {
                var xPos = (i+0) * 45
                var eachPot = self.pots[i]
                eachPot.frame = CGRectMake(CGFloat(xPos), 102, 45, 20)
                if i >= 1 {
                    eachPot.text = "Side-Pot \(i): \(eachPot.sidePot.potSize)"
                }
                else {
                    eachPot.text = "Main-Pot: \(eachPot.sidePot.potSize)"
                }
                eachPot.font = UIFont(name: eachPot.font.fontName, size: 6)
                self.addSubview(eachPot)
            }
        }
        else if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            for var i = 0; i < self.pots.count; i++ {
                var xPos = (i+0) * 77
                var eachPot = self.pots[i]
                eachPot.frame = CGRectMake(CGFloat(xPos), 132, 77, 20)
                if i >= 1 {
                    eachPot.text = "Side-Pot \(i): \(eachPot.sidePot.potSize)"
                }
                else {
                    eachPot.text = "Main-Pot: \(eachPot.sidePot.potSize)"
                }
                eachPot.font = UIFont(name: eachPot.font.fontName, size: 10)
                self.addSubview(eachPot)
            }
        }
    }
}
