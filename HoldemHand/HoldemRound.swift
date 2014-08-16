//
//  HoldemRound.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/12/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import Foundation

enum BettingRound {
    case PreFlop
    case Flop
    case Turn
    case River
}

class HoldemRound {
    var currentBetRound: BettingRound!
    init() {
        currentBetRound = BettingRound.PreFlop
    }
}