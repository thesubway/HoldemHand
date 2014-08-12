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
    func compareEach(var hand1: [Card],var hand2: [Card]) -> [Card] {
        for var i = 0; i < hand1.count; i++ {
            if hand1[i].value > hand2[i].value {
                return hand1
            }
            if hand1[i].value < hand2[i].value {
                return hand2
            }
        }
        return hand1
    }
    func compareQuads(var hand1: [Card], var hand2: [Card]) -> [Card] {
        for var i = 3; i < hand1.count; i++ {
            if hand1[i].value > hand2[i].value {
                return hand1
            }
            if hand1[i].value < hand2[i].value {
                return hand2
            }
        }
        return hand1
    }
    func compareBoat(var hand1: [Card], var hand2: [Card]) -> [Card] {
        for var i = 2; i < 4; i++ {
            if hand1[i].value > hand2[i].value {
                return hand1
            }
            if hand1[i].value < hand2[i].value {
                return hand2
            }
        }
        return hand1
    }
    func compareTrips(var hand1: [Card], var hand2: [Card]) -> [Card] {
        for var i = 2; i < hand1.count; i++ {
            if hand1[i].value > hand2[i].value {
                return hand1
            }
            if hand1[i].value < hand2[i].value {
                return hand2
            }
        }
        return hand1
    }
    func compareTwoPair(var hand1: [Card], var hand2: [Card]) -> [Card] {
        
        return compareOnePair(hand1,hand2: hand2)
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