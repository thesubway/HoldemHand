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
    func handName(var hand: [Card], var handValue: Int) -> String {
        var fiveCards = ""
        for eachCard in hand {
            fiveCards = "\(fiveCards)\(eachCard.valueDisplay)"
        }
        switch handValue {
        case 8:
            if hand[0].value == 14 {
                return "Royal Flush"
            }
            return "Straight Flush \(fiveCards)"
        case 7:
            return "Four of a Kind \(fiveCards)"
        case 6:
            return "Full House \(fiveCards)"
        case 5:
            return "Flush \(fiveCards)"
        case 4:
            return "Straight \(fiveCards)"
        case 3:
            return "Three of a Kind \(fiveCards)"
        case 2:
            return "Two Pair \(fiveCards)"
        case 1:
            return "One Pair \(fiveCards)"
        default:
            return "High Card \(fiveCards)"
        }
    }
    
    func cardsAreEqual(var card1: Card, var card2: Card) -> Bool {
        if card1.value != card2.value {
            return false
        }
        if card1.suit != card2.suit {
            return false
        }
        return true
    }
    func isEqual(var hand: [Card], var to: [Card]) -> Bool {
        //returns -1 if not.
        assert(hand.count == 5 && to.count == 5)
        for var i = 0; i < hand.count; i++ {
            if hand[i].value != to[i].value {
                return false
            }
        }
        var firstHandIsFlush = true
        var secondHandIsFlush = true
        for var i = 0; i < hand.count-1; i++ {
            if hand[i].suit != to[i+1].suit {
                firstHandIsFlush = false
            }
            if to[i].suit != to[i+1].suit {
                secondHandIsFlush = false
            }
        }
        //if one is a flush, and the other isn't:
        if firstHandIsFlush != secondHandIsFlush {
            return false
        }
        return true
    }
    func compareForLoser(var player1: Player, var player2: Player) -> Player {
        if player1.bestHandType > player2.bestHandType {
            println("tiebreak by type")
            return player2
        }
        else if player1.bestHandType < player2.bestHandType {
            println("tiebreak by type")
            return player1
        }
        //comparing each card in the player's hands:
        for var i = 0; i < player1.best5CardCombo.count; i++ {
            if player1.best5CardCombo[i].value > player2.best5CardCombo[i].value {
                println("tiebreak here")
                return player2
            }
            if player1.best5CardCombo[i].value < player2.best5CardCombo[i].value {
                println("tiebreak here")
                return player1
            }
        }
        return player1
    }
    //takes array of hands, returns one hand.
    func compareMultipleHands(var allHands: [[Card]],var allValues: [Int]) -> [Card] {
        for eachHand in allHands {
        }
        var highestValue = 0
        var highestValueIndex = 0
        for var i = 0; i < allValues.count; i++ {
            if allValues[i] > highestValue {
                highestValue = allValues[i]
                highestValueIndex = i
            }
        }
        var bestHand = allHands[highestValueIndex]
        for var i = 0; i < allHands.count; i++ {
            if allValues[i] == highestValue {
                bestHand = self.compareEach(bestHand,hand2: allHands[i])
            }
        }
        return bestHand
    }
    func compare(var hand1: [Card], var hand2: [Card],var hand1Type: Int!, var hand2Type: Int!) -> [Card] {
        if hand1Type > hand2Type {
            return hand1
        }
        if hand2Type > hand1Type {
            return hand2
        }
        return self.compareEach(hand1, hand2: hand2)
    }
    //same name as above, but this time returns the hand type, instead of the hand.
    func compare(var hand1: [Card], var hand2: [Card],var hand1Type: Int!, var hand2Type: Int!) -> Int {
        if hand1Type > hand2Type {
            return hand1Type
        }
        if hand2Type > hand1Type {
            return hand2Type
        }
        return hand1Type
    }
    func areEqual(var hand1: [Card], var hand2: [Card],var hand1Type: Int!, var hand2Type: Int!) -> Bool {
        if hand1Type > hand2Type {
            return false
        }
        if hand2Type > hand1Type {
            return false
        }
        for var i = 0; i < hand1.count; i++ {
            if hand1[i].value != hand2[i].value {
                return false
            }
        }
        return true
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