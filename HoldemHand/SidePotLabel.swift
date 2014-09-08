//
//  SidePotLabel.swift
//  HoldemHand
//
//  Created by Dan Hoang on 9/7/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

class SidePotLabel: UILabel {
    var sidePot : SidePot!
    func initializeSelf(sidePot : SidePot) {
        self.sidePot = sidePot
    }
}
