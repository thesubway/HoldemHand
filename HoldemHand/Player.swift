//
//  Player.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/10/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import Foundation

class Player {
    var hand = [Card]()
    var handPlusBoard = [Card]()
    var best5CardCombo = [Card]()
    @IBInspectable var chips : Int! {
        didSet {
            if let chipsView = self.selfView {
                self.selfView.chipsLabel.text = "P\(self.seatNumber)\nChips:\n\(self.chips)"
            }
        }
    }
    var name : String!
    var folded: Bool!
    var eliminated: Bool!
    var finishPosition : Int!
    
    var isAllIn: Bool!
    var isLive: Bool!
    @IBInspectable var betForRound: Int! {
        didSet {
            self.selfView.chipsLabel.text = "P\(self.seatNumber)\nChips:\n\(self.chips-self.betForRound)"
        }
    }
    var lossForHand = 0
    var tieBreak : Int!
    var outs = [Card]() //applies to all-ins.
    var isLeading : Bool! //applies to all-ins. False if tie.
    
    var isComputer : Bool!
    @IBInspectable var seatNumber : Int!
    //taken from HoldemView:
    var handSorter = HandSorter()
    var handComparer = HandComparer()
    @IBInspectable var bestHandType : Int = 0 {
        didSet {
            //in case they do not have a hand yet:
            if self.best5CardCombo.count == 5 {
                self.handName = handComparer.handName(self.best5CardCombo, handValue: bestHandType)
            }
        }
    }
    
    var selfView : PlayerView!
    // reps self.textView.text in HoldemView
    var handName = ""
    init(isComputer: Bool, seatNumber: Int) {
        self.isComputer = isComputer
        self.seatNumber = seatNumber
        
        self.isLive = true
        self.folded = false
        self.eliminated = false
        self.isAllIn = false
    }
    
    func testNextCard(var cards: [Card]) -> ([Card], Int) {
        assert(handStage == 1 || handStage == 2 || handStage == 4)
        if handStage == 4 {
            assert(cards.count == 0)
        }
        if (handStage == 1) {
            assert(cards.count <= 2) //
        }
        if handStage == 2 {
            assert(cards.count <= 1)
        }
        if handStage == 0 {
            assert(cards.count <= 5)
            assert(cards.count >= 3)
        }
        var unshuffledDeck = UnshuffledDeck()
        var cardsToEvaluate = [Card]()
        var whatHandWouldBe = [Card]()
        var whatHandValueWouldBe = 0
        for eachCard in handPlusBoard {
            cardsToEvaluate.append(eachCard)
        }
        if cards.count != 0 {
            for eachCard in cards {
                cardsToEvaluate.append(eachCard)
            }
        }
        if (cardsToEvaluate.count == 5) {
            (whatHandWouldBe,whatHandValueWouldBe) = self.evaluate5CardHand(cardsToEvaluate)
        }
        else if (cardsToEvaluate.count == 6) {
            (whatHandWouldBe,whatHandValueWouldBe) = self.evaluate6CardHand(cardsToEvaluate)
        }
        else if (cardsToEvaluate.count == 7) {
            (whatHandWouldBe,whatHandValueWouldBe) = self.evaluateFullHand(cardsToEvaluate)
        }
        return (whatHandWouldBe,whatHandValueWouldBe)
    }
    
    func evaluateHand() {
        //best5CardCombo will be set here.
    }
    
    func evaluate5CardHand(var cardsToEvaluate: [Card]) -> ([Card], Int) {

        var numPairs = 0
        var currentPairs = [Card]()
        var numTrips = 0
        var currentTrip : Card!
        var numQuads = 0
        var currentQuad : Card!
        var numSingles = 0
        var isFlush = false
        var isStraight = false
        var handRanking: Int = 0
        
        var numBins = holdemDeck.fullDeckCount / holdemDeck.numSuits
        var allBins = [[Card]]()
        //first, append empty bins 0 and 1. Because no card has those values.
        let emptyBin = [Card]()
        allBins.append(emptyBin)
        allBins.append(emptyBin)
        //from here on out, every appended bin is an actual card value.
        for var i = 2; i < numBins+2; i++ {
            //Create 1 bin each time through. Each bin is an array of Cards.
            var currentBin = [Card]()
            //now iterate through the 5 cards:
            for eachCard in cardsToEvaluate {
                if eachCard.value == i {
                    currentBin.append(eachCard)
                }
            }
            allBins.append(currentBin)
        }
        //now count the cards:
        for eachBin in allBins {
            if eachBin.count > 0 {
                
            }
            if eachBin.count == 4 {
                currentQuad = eachBin[0]
                numQuads++
            }
            else if eachBin.count == 3 {
                currentTrip = eachBin[0]
                numTrips++
            }
            else if eachBin.count == 2 {
                currentPairs.append(eachBin[0])
                numPairs++
            }
            else if eachBin.count == 1 {
                numSingles++
            }
        }
        //now count the quads,trips,pairs.
        if numQuads == 1 {
            handRanking = 7
            cardsToEvaluate = handSorter.sortQuads(cardsToEvaluate, quadValue: currentQuad)
//            if handRanking > self.bestHandType {
//                self.bestHandType = 7
//                self.handName = "Four of a Kind"
//                self.best5CardCombo = cardsToEvaluate
//                best5CardCombo = handSorter.sortQuads(best5CardCombo, quadValue: currentQuad)
//            }
//            else if handRanking == self.bestHandType {
//                //apply quads tiebreak.
//                cardsToEvaluate = handSorter.sortQuads(cardsToEvaluate, quadValue: currentQuad)
//                best5CardCombo = handComparer.compareTrips(best5CardCombo, hand2: cardsToEvaluate)
//            }
        }
        else if (numTrips == 1) && (numPairs == 1) {
            handRanking = 6
            cardsToEvaluate = handSorter.sortTrips(cardsToEvaluate, tripValue: currentTrip)
//            if handRanking > self.bestHandType {
//                self.bestHandType = 6
//                self.handName = "Full House"
//                self.best5CardCombo = cardsToEvaluate
//                best5CardCombo = handSorter.sortBoat(best5CardCombo, tripValue: currentTrip)
//            }
//            else if handRanking == self.bestHandType {
//                cardsToEvaluate = handSorter.sortTrips(cardsToEvaluate, tripValue: currentTrip)
//                best5CardCombo = handComparer.compareTrips(best5CardCombo, hand2: cardsToEvaluate)
//            }
        }
        else if numTrips == 1 {
            handRanking = 3
            cardsToEvaluate = handSorter.sortTrips(cardsToEvaluate, tripValue: currentTrip)
//            if handRanking > self.bestHandType {
//                self.bestHandType = 3
//                self.handName = "Three of a Kind"
//                self.best5CardCombo = cardsToEvaluate
//                best5CardCombo = handSorter.sortTrips(best5CardCombo,tripValue: currentTrip)
//            }
//            else if handRanking == self.bestHandType {
//                cardsToEvaluate = handSorter.sortTrips(cardsToEvaluate, tripValue: currentTrip)
//                best5CardCombo = handComparer.compareTrips(best5CardCombo, hand2: cardsToEvaluate)
//            }
        }
        else if numPairs == 2 {
            handRanking = 2
            var twoPairs = [Int]()
            twoPairs.append(currentPairs[0].value)
            twoPairs.append(currentPairs[1].value)
            cardsToEvaluate = handSorter.sortTwoPair(cardsToEvaluate, pairValues: twoPairs)
//            if handRanking > self.bestHandType {
//                self.bestHandType = 2
//                self.handName = "Two Pair"
//                self.best5CardCombo = cardsToEvaluate
//                var twoPairs = [Int]()
//                twoPairs.append(currentPairs[0].value)
//                twoPairs.append(currentPairs[1].value)
//                best5CardCombo = handSorter.sortTwoPair(best5CardCombo, pairValues: twoPairs)
//            }
//            else if handRanking == self.bestHandType {
//                var twoPairs = [Int]()
//                twoPairs.append(currentPairs[0].value)
//                twoPairs.append(currentPairs[1].value)
//                cardsToEvaluate = handSorter.sortTwoPair(cardsToEvaluate, pairValues: twoPairs)
//                best5CardCombo = handComparer.compareTwoPair(best5CardCombo, hand2: cardsToEvaluate)
//            }
        }
        else if numPairs == 1 {
            handRanking = 1
            cardsToEvaluate = handSorter.sortOnePair(cardsToEvaluate, pairValue: currentPairs[0].value)
//            if handRanking > self.bestHandType {
//                self.bestHandType = 1
//                self.handName = "One Pair"
//                self.best5CardCombo = cardsToEvaluate
//                best5CardCombo = handSorter.sortOnePair(best5CardCombo,pairValue: currentPairs[0].value)
//            }
//            else if handRanking == self.bestHandType {
//                cardsToEvaluate = handSorter.sortOnePair(cardsToEvaluate, pairValue: currentPairs[0].value)
//                best5CardCombo = handComparer.compareOnePair(best5CardCombo,hand2: cardsToEvaluate)
//            }
        }
        else {
            //might be nothing. or a straight and/or flush
            //either way, time to do standard sorting:
            if cardsToEvaluate.count != 5 {
                println(cardsToEvaluate.count)
            }
            assert(cardsToEvaluate.count == 5)
            cardsToEvaluate = handSorter.sortCardValue(cardsToEvaluate)
            //check for flush:
            var stillFlush = true
            var currentSuit = cardsToEvaluate[0].suit
            for eachCard in cardsToEvaluate {
                if eachCard.suit != currentSuit {
                    stillFlush = false
                }
            }
            if stillFlush == true {
                isFlush = true
            }
            //now check for straight:
            //track the highest, lowest, and 2nd-highest.
            /*var lowest = cardsToEvaluate[0]
            var highest = cardsToEvaluate[0]
            for eachCard in cardsToEvaluate {
            if eachCard.value > highest.value {
            highest = eachCard
            }
            if eachCard.value < lowest.value {
            lowest = eachCard
            }
            } */
            if (cardsToEvaluate[0].value - cardsToEvaluate[4].value) == 4 {
                isStraight = true
            }
            else if cardsToEvaluate[0].value == 14 {
                if cardsToEvaluate[1].value == 5 {
                    isStraight = true
                    //move ace to the back; it is now small.
                    let saveAce = cardsToEvaluate[0]
                    cardsToEvaluate.removeAtIndex(0)
                    cardsToEvaluate.append(saveAce)
                }
            }
            if isStraight && isFlush {
                handRanking = 8
//                if handRanking > self.bestHandType {
//                    self.bestHandType = 8
//                    if cardsToEvaluate[0].value == 14 {
//                        self.handName = "Royal Flush"
//                    }
//                    else {
//                        self.handName = "Straight Flush"
//                    }
//                    self.best5CardCombo = cardsToEvaluate
//                    //already been sorted
//                }
//                else if handRanking == self.bestHandType {
//                    self.best5CardCombo = handComparer.compareEach(best5CardCombo, hand2: cardsToEvaluate)
//                    if cardsToEvaluate[0].value == 14 {
//                        self.handName = "Royal Flush"
//                    }
//                }
            }
            else if isFlush {
                handRanking = 5
//                if handRanking > self.bestHandType {
//                    self.bestHandType = 5
//                    self.handName = "Flush"
//                    self.best5CardCombo = cardsToEvaluate
//                }
//                else if handRanking == self.bestHandType {
//                    self.best5CardCombo = handComparer.compareEach(best5CardCombo, hand2: cardsToEvaluate)
//                }
            }
            else if isStraight {
                handRanking = 4
//                if handRanking > self.bestHandType {
//                    self.bestHandType = 4
//                    self.handName = "Straight"
//                    self.best5CardCombo = cardsToEvaluate
//                }
//                else if handRanking == self.bestHandType {
//                    self.best5CardCombo = handComparer.compareEach(best5CardCombo, hand2: cardsToEvaluate)
//                }
            }
            else {
//                if handRanking == 0 && self.bestHandType == 0 {
//                    self.best5CardCombo = handComparer.compareEach(best5CardCombo, hand2: cardsToEvaluate)
//                    self.handName = "Nothing"
//                }
            }
        }
        
//        println(self.handName)
        //return self.handName
        return (cardsToEvaluate, handRanking)
        //add new parameters.
    }
    
    func evaluate6CardHand(cardsToEvaluate6: [Card]) -> ([Card], Int) {
        //I also have a cardsToEvaluate6 here.
        var bestHand = [Card]()
        var bestHandRanking : Int = 0
        var currentHand = [Card]()
        var currentHandRanking : Int = 0
        //save variable for the best hand:
        for var i = 0; i < cardsToEvaluate6.count; i++ {
            //don't put this outside the loop. so it resets.
            var cardsToEvaluate5 = [Card]()
            //ignore that one card:
            for var j = 0; j < cardsToEvaluate6.count; j++ {
                if j != i {
                    cardsToEvaluate5.append(cardsToEvaluate6[j])
                }
            }
            if bestHand.count != 5 {
                //then make sure it is:
                bestHand = cardsToEvaluate5
                //go ahead and keep currentHandRanking at 0.
            }
            //here I actually call the method.
            (currentHand, currentHandRanking) = evaluate5CardHand(cardsToEvaluate5)
            //compare which is best:
            bestHand = handComparer.compare(bestHand, hand2: currentHand, hand1Type: bestHandRanking, hand2Type: currentHandRanking)
            //this shouldn't cause error because bestHand and currentHand aren't used in this method.
            bestHandRanking = handComparer.compare(bestHand, hand2: currentHand, hand1Type: bestHandRanking, hand2Type: currentHandRanking)
        }
        return (bestHand, bestHandRanking)
    }
    
    func evaluateFullHand(cardsToEvaluate7: [Card]) -> ([Card], Int) {
        var bestHand = [Card]()
        var bestHandRanking : Int = 0
        var currentHand = [Card]()
        var currentHandRanking : Int = 0
        //there will be 7 cards, so:
        for var i = 0; i < cardsToEvaluate7.count; i++ {
            //don't put this outside the loop. so it resets.
            var cardsToEvaluate6 = [Card]()
            //ignore that one card:
            for var j = 0; j < cardsToEvaluate7.count; j++ {
                if j != i {
                    cardsToEvaluate6.append(cardsToEvaluate7[j])
                }
            }
            if bestHand.count == 0 {
                //then make sure it is:
                bestHand = cardsToEvaluate6
                //go ahead and keep currentHandRanking at 0.
            }
            (currentHand, currentHandRanking) = evaluate6CardHand(cardsToEvaluate6)
            //compare which is best:
            bestHand = handComparer.compare(bestHand, hand2: currentHand, hand1Type: bestHandRanking, hand2Type: currentHandRanking)
            //this shouldn't cause error because bestHand and currentHand aren't used in this method.
            bestHandRanking = handComparer.compare(bestHand, hand2: currentHand, hand1Type: bestHandRanking, hand2Type: currentHandRanking)
            
            evaluate6CardHand(cardsToEvaluate6)
        }
        return (bestHand, bestHandRanking)
    }
}