//
//  SidePot.swift
//  HoldemHand
//
//  Created by Dan Hoang on 9/7/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import Foundation

class SidePot {
    var maxPerPlayer : Int
    var maxLoss : Int
    var potSize = 0
    var done = false
    init(maxPerPlayer : Int) {
        self.maxPerPlayer = maxPerPlayer
        self.maxLoss = maxPerPlayer
    }
}