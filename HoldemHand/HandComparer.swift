//
//  HandComparer.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/11/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import Foundation

class HandComparer {
    //this class assumes the parameters are already sorted.
    init() {
        
    }
    func compareOnePair(var hand1: [Card], var hand2: [Card]) -> [Card] {
        //skip i = 0, because 0 and 1 have same value in pairs.
        for var i = 1; i < hand1.count; i++ {
            if hand1[i].value > hand2[i].value {
                return hand1
            }
            if hand1[i].value < hand2[i].value {
                return hand2
            }
        }
        return hand1
    }
}