//
//  HoldemViewController.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/9/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

var faceDownImage = UIImage(named: "Barbie.jpg")
class HoldemViewController: UIViewController {
    //represents holdem in the point of view of one player.
    //borrow from other classes:
    var handSorter = HandSorter()
    var handComparer = HandComparer()
    
    var holdemDeck = DeckOfCards()
    //handStage 0-pre-flop. 1-flop. 2-turn. 3-river. 4-showdown. 5-over.
    var handStage = 0
    //all-in will be a different kind of stage
    @IBOutlet var flop1: CardImage!
    @IBOutlet var flop2 : CardImage!
    @IBOutlet var flop3 : CardImage!
    @IBOutlet var turn : CardImage!
    @IBOutlet var river: CardImage!
    @IBOutlet var player11: CardImage!
    @IBOutlet var player12: CardImage!
    
    var best5CardCombo = [Card]()
    
    var allCards = [CardImage]()
    var allPlayers = [Player]()
    //hard-code, or hardcode num players to 1.
    var numPlayers = 1
    var bestHandType: Int = 0
    
    @IBOutlet var handLabel: UILabel!
    override func viewDidLoad() {
        loadEverything()
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("MEMORY LOW")
        // Dispose of any resources that can be recreated.
    }
    
    func loadEverything() {
        //new deck. deck should be shuffled.
        //deal out one players cards.
        var playersPossibleCards = [Card]()
        //reset the deck:
        holdemDeck = DeckOfCards()
        //these should be reset at beginning of each hand.
        bestHandType = 0
        //forgetting this did not actually cause problems.
        best5CardCombo = [Card]()
        
        allCards.append(player11)
        allCards.append(player12)
        allCards.append(flop1)
        allCards.append(flop2)
        allCards.append(flop3)
        allCards.append(turn)
        allCards.append(river)
        for eachCard in allCards {
            eachCard.currentCard = nil
        }
        var player1 = Player()
        player11.currentCard = holdemDeck.drawCard()
        player12.currentCard = holdemDeck.drawCard()
        self.handLabel.hidden = true
    }
    
    func faceDown() -> UIImage {
        return faceDownImage
    }
    func dealFlop() {
        handStage = 1
        flop1.currentCard = holdemDeck.drawCard()
        flop2.currentCard = holdemDeck.drawCard()
        flop3.currentCard = holdemDeck.drawCard()
    }
    func dealTurn() {
        handStage = 2
        turn.currentCard = holdemDeck.drawCard()
        
    }
    func dealRiver() {
        handStage = 3
        river.currentCard = holdemDeck.drawCard()
        
    }
    func endRound() {
        for eachImage in allCards {
            eachImage.layer.borderColor = UIColor.greenColor().CGColor
        }
        handStage = 0
        println("endRound")
        for eachCard in allCards {
            eachCard.currentCard = nil
        }
        self.loadEverything()
    }
    func showDown() {
        handStage = 4
        //after showDown:
        println("showdown")
    }
    
    func evaluate5CardHand(var cardsToEvaluate: [Card]) -> String {
        if self.best5CardCombo.count != 5 {
            self.best5CardCombo = cardsToEvaluate
        }
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
        println("holdemDeck.fullDeckCount: \(holdemDeck.fullDeckCount)")
        println("holdemDeck.numSuits: \(holdemDeck.numSuits)")
        var allBins = [[Card]]()
        //first, append empty bins 0 and 1.
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
                //println("player has \(eachBin.count) \(eachBin[0].valueDisplay) s")
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
            if handRanking > self.bestHandType {
                self.bestHandType = 7
                self.handLabel.text = "Four of a Kind"
                self.best5CardCombo = cardsToEvaluate
                best5CardCombo = handSorter.sortQuads(best5CardCombo, quadValue: currentQuad)
            }
            else if handRanking == self.bestHandType {
                //apply quads tiebreak.
                cardsToEvaluate = handSorter.sortQuads(cardsToEvaluate, quadValue: currentQuad)
                best5CardCombo = handComparer.compareTrips(best5CardCombo, hand2: cardsToEvaluate)
            }
        }
        else if (numTrips == 1) && (numPairs == 1) {
            handRanking = 6
            if handRanking > self.bestHandType {
                self.bestHandType = 6
                self.handLabel.text = "Full House"
                self.best5CardCombo = cardsToEvaluate
                best5CardCombo = handSorter.sortBoat(best5CardCombo, tripValue: currentTrip)
            }
            else if handRanking == self.bestHandType {
                cardsToEvaluate = handSorter.sortTrips(cardsToEvaluate, tripValue: currentTrip)
                best5CardCombo = handComparer.compareTrips(best5CardCombo, hand2: cardsToEvaluate)
            }
        }
        else if numTrips == 1 {
            handRanking = 3
            if handRanking > self.bestHandType {
                self.bestHandType = 3
                self.handLabel.text = "Three of a Kind"
                self.best5CardCombo = cardsToEvaluate
                best5CardCombo = handSorter.sortTrips(best5CardCombo,tripValue: currentTrip)
            }
            else if handRanking == self.bestHandType {
                cardsToEvaluate = handSorter.sortTrips(cardsToEvaluate, tripValue: currentTrip)
                best5CardCombo = handComparer.compareTrips(best5CardCombo, hand2: cardsToEvaluate)
            }
        }
        else if numPairs == 2 {
            handRanking = 2
            if handRanking > self.bestHandType {
                self.bestHandType = 2
                self.handLabel.text = "Two Pair"
                self.best5CardCombo = cardsToEvaluate
                var twoPairs = [Int]()
                twoPairs.append(currentPairs[0].value)
                twoPairs.append(currentPairs[1].value)
                best5CardCombo = handSorter.sortTwoPair(best5CardCombo, pairValues: twoPairs)
            }
            else if handRanking == self.bestHandType {
                var twoPairs = [Int]()
                twoPairs.append(currentPairs[0].value)
                twoPairs.append(currentPairs[1].value)
                cardsToEvaluate = handSorter.sortTwoPair(cardsToEvaluate, pairValues: twoPairs)
                best5CardCombo = handComparer.compareTwoPair(best5CardCombo, hand2: cardsToEvaluate)
            }
        }
        else if numPairs == 1 {
            handRanking = 1
            if handRanking > self.bestHandType {
                self.bestHandType = 1
                self.handLabel.text = "One Pair"
                self.best5CardCombo = cardsToEvaluate
                best5CardCombo = handSorter.sortOnePair(best5CardCombo,pairValue: currentPairs[0].value)
            }
            else if handRanking == self.bestHandType {
                cardsToEvaluate = handSorter.sortOnePair(cardsToEvaluate, pairValue: currentPairs[0].value)
                best5CardCombo = handComparer.compareOnePair(best5CardCombo,hand2: cardsToEvaluate)
            }
        }
        else {
            //might be nothing. or a straight and/or flush
            //either way, time to do standard sorting:
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
                    print("WHEEL: ")
                    //move ace to the back; it is now small.
                    let saveAce = cardsToEvaluate[0]
                    cardsToEvaluate.removeAtIndex(0)
                    cardsToEvaluate.append(saveAce)
                    for eachCard in cardsToEvaluate {
                        print(eachCard.value)
                    }
                }
            }
            if isStraight && isFlush {
                handRanking = 8
                if handRanking > self.bestHandType {
                    self.bestHandType = 8
                    if cardsToEvaluate[0].value == 14 {
                        self.handLabel.text = "Royal Flush"
                    }
                    else {
                        self.handLabel.text = "Straight Flush"
                    }
                    self.best5CardCombo = cardsToEvaluate
                    //already been sorted
                }
                else if handRanking == self.bestHandType {
                    self.best5CardCombo = handComparer.compareEach(best5CardCombo, hand2: cardsToEvaluate)
                    if cardsToEvaluate[0].value == 14 {
                        self.handLabel.text = "Royal Flush"
                    }
                }
            }
            else if isFlush {
                handRanking = 5
                if handRanking > self.bestHandType {
                    self.bestHandType = 5
                    self.handLabel.text = "Flush"
                    self.best5CardCombo = cardsToEvaluate
                }
                else if handRanking == self.bestHandType {
                    self.best5CardCombo = handComparer.compareEach(best5CardCombo, hand2: cardsToEvaluate)
                }
            }
            else if isStraight {
                handRanking = 4
                if handRanking > self.bestHandType {
                    self.bestHandType = 4
                    self.handLabel.text = "Straight"
                    self.best5CardCombo = cardsToEvaluate
                }
                else if handRanking == self.bestHandType {
                    self.best5CardCombo = handComparer.compareEach(best5CardCombo, hand2: cardsToEvaluate)
                }
            }
            else {
                if handRanking == 0 && self.bestHandType == 0 {
                    self.best5CardCombo = handComparer.compareEach(best5CardCombo, hand2: cardsToEvaluate)
                    self.handLabel.text = "Nothing"
                }
            }
        }
        
        self.handLabel.hidden = false
        println(self.handLabel.text)
        for eachCard in best5CardCombo {
            println("\(eachCard.valueName) of \(eachCard.suitName)")
        }
        return self.handLabel.text
    }
    
    func evaluate6CardHand(cardsToEvaluate6: [Card]) {
        //there will be 6 cards, so:
        println("\(cardsToEvaluate6.count) cards")
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
            evaluate5CardHand(cardsToEvaluate5)
        }
    }
    
    func evaluateFullHand(cardsToEvaluate7: [Card]) {
        //there will be 7 cards, so:
        println("\(cardsToEvaluate7.count) cards")
        for var i = 0; i < cardsToEvaluate7.count; i++ {
            //don't put this outside the loop. so it resets.
            var cardsToEvaluate6 = [Card]()
            //ignore that one card:
            for var j = 0; j < cardsToEvaluate7.count; j++ {
                if j != i {
                    cardsToEvaluate6.append(cardsToEvaluate7[j])
                }
            }
            evaluate6CardHand(cardsToEvaluate6)
        }
    }
    
    @IBAction func dealNextPressed(sender: AnyObject) {
        var cardsUsed = [Card]()
        if handStage < 3 {
            cardsUsed.append(player11.currentCard)
            cardsUsed.append(player12.currentCard)
        }
        if handStage == 0 {
            self.dealFlop()
            cardsUsed.append(flop1.currentCard)
            cardsUsed.append(flop2.currentCard)
            cardsUsed.append(flop3.currentCard)
            self.evaluate5CardHand(cardsUsed)
        }
        else if handStage == 1 {
            self.dealTurn()
            cardsUsed.append(flop1.currentCard)
            cardsUsed.append(flop2.currentCard)
            cardsUsed.append(flop3.currentCard)
            cardsUsed.append(turn.currentCard)
            println("Turn card is a \(turn.currentCard.valueName)")
            self.evaluate6CardHand(cardsUsed)
        }
        else if handStage == 2 {
            self.dealRiver()
            cardsUsed.append(flop1.currentCard)
            cardsUsed.append(flop2.currentCard)
            cardsUsed.append(flop3.currentCard)
            cardsUsed.append(turn.currentCard)
            cardsUsed.append(river.currentCard)
            println("River card is a \(river.currentCard.valueName)")
            //this should be for-in loop, for all players:
            self.evaluateFullHand(cardsUsed)
            //highlight the cards used:
            for eachImage in allCards {
                for eachUsed in best5CardCombo {
                    if (eachImage.currentCard.value == eachUsed.value) && (eachImage.currentCard.suit == eachUsed.suit) {
                        eachImage.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
            }
        }
        else if handStage == 3 {
            //end the round.
            self.showDown()
        }
        else {
            self.endRound()
        }
        
    }

}
