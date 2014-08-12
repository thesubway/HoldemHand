//
//  HandTieBreak.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/11/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import Foundation

class HandSorter {
    init() {
        //sort the hands from lowest to highest:
    }
    
    func sortCardValue(var hand: [Card]) -> [Card] {
        //this goes for a flush, or "nothing".
        //selection sort
        var sortedPart = [Card]()
        while !hand.isEmpty {
            var highestIndex = hand.count-1
            var highest = hand[highestIndex]
            for var i = 0; i < hand.count; i++ {
                if hand[i].value > hand[highestIndex].value {
                    highestIndex = i
                }
            }
            sortedPart.append(hand[highestIndex])
            //remember to POP that card.
            hand.removeAtIndex(highestIndex)
        }
        return sortedPart
    }
    func sortQuads(var hand:[Card], var quadValue: Card) -> [Card] {
        var sortedPart = [Card]()
        while sortedPart.count < 4 {
            for var i = 0; i < hand.count; i++ {
                if hand[i].value == quadValue.value {
                    sortedPart.append(hand[i])
                    hand.removeAtIndex(i)
                }
            }
        }
        sortedPart.append(hand[0])
        return sortedPart
    }
    func sortBoat(var hand: [Card], var tripValue: Card) -> [Card] {
        var sortedPart = [Card]()
        while sortedPart.count < 3 {
            for var i = 0; i < hand.count; i++ {
                if hand[i].value == tripValue.value {
                    sortedPart.append(hand[i])
                    hand.removeAtIndex(i)
                }
            }
        }
        sortedPart.append(hand[0])
        sortedPart.append(hand[1])
        return sortedPart
    }
    func sortTrips(var hand: [Card], var tripValue: Card) -> [Card] {
        var sortedPart = [Card]()
        while sortedPart.count < 3 {
            for var i = 0; i < hand.count; i++ {
                if hand[i].value == tripValue.value {
                    sortedPart.append(hand[i])
                    hand.removeAtIndex(i)
                }
            }
        }
        hand = self.sortCardValue(hand)
        for var i = 0; i < hand.count; i++ {
            sortedPart.append(hand[i])
        }
        return sortedPart
    }
    func sortTwoPair(var hand: [Card], var pairValues: [Int]) -> [Card] {
        var sortedPart = [Card]()
        let higherPair = pairValues[1] //second one added is higher.
        let lowerPair = pairValues[0]
        while sortedPart.count < 2 {
            for var i = 0 ; i < hand.count; i++ {
                if hand[i].value == higherPair {
                    sortedPart.append(hand[i])
                    hand.removeAtIndex(i)
                }
            }
        }
        while sortedPart.count < 4 {
            for var i = 0 ; i < hand.count; i++ {
                if hand[i].value == lowerPair {
                    sortedPart.append(hand[i])
                    hand.removeAtIndex(i)
                }
            }
        }
        //add the last element
        sortedPart.append(hand[0])
        return sortedPart
    }
    
    func sortOnePair(var hand: [Card], var pairValue: Int) -> [Card] {
        //this only should be called when hand is quads.
        var sortedPart = [Card]()
        var nextElement = hand[0]
        while sortedPart.count < 2 {
            for var i = 0 ; i < hand.count; i++ {
                if hand[i].value == pairValue {
                    sortedPart.append(hand[i])
                    hand.removeAtIndex(i)
                }
            }
        }
        //now to sort the other 3 elements. no longer need to check for empty cards
        hand = self.sortCardValue(hand)
        for var i = 0; i < hand.count; i++ {
            sortedPart.append(hand[i])
        }
        return sortedPart
    }
}