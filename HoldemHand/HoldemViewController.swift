//
//  HoldemViewController.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/9/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

var faceDownImage = UIImage(named: "Barbie.jpg")
var holdemDeck = DeckOfCards()
var handStage = 0
class HoldemViewController: UIViewController, GameControllerDelegate,UITextFieldDelegate {
    //represents holdem in the point of view of one player.
    //borrow from other classes:
    var handSorter = HandSorter()
    var handComparer = HandComparer()
    //default:
    var gameController = GameController(startingChips: 500, numPlayers: 6)
    var betActionController = UIAlertController(title: "Place your bet", message: "Choose an option", preferredStyle: UIAlertControllerStyle.ActionSheet)
    var betAlertController = UIAlertController(title: "Place your bet", message: "Enter in your amount", preferredStyle: UIAlertControllerStyle.Alert)
    var currentPlayer : Player!
    //this button will rotate clockwise every round.
    var dealerButton = 0
    var roundNumber = 0
    
    //handStage 0-pre-flop. 1-flop. 2-turn. 3-river. 4-showdown. 5-over.
    var allInMode = false
    //all-in will be a different kind of stage
    @IBOutlet var flop1: CardImage!
    @IBOutlet var flop2 : CardImage!
    @IBOutlet var flop3 : CardImage!
    @IBOutlet var turn : CardImage!
    @IBOutlet var river: CardImage!
    @IBOutlet var player11: CardImage!
    @IBOutlet var player12: CardImage!
    @IBOutlet var opponent11: CardImage!
    @IBOutlet var opponent12: CardImage!
    @IBOutlet var opponent21: CardImage!
    @IBOutlet var opponent22: CardImage!
    @IBOutlet var opponent31: CardImage!
    @IBOutlet var opponent32: CardImage!
    
    var best5CardCombo = [Card]()
    
    var cardImages = [CardImage]()
    var allPlayers = [Player]()
    
    var player0: Player!
    //var player1 = gameController.
    //hard-code, or hardcode num players to 1.
    var numPlayers = 1
    var bestHandType: Int = 0
    
    @IBOutlet var handLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("MEMORY LOW")
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func updatePlayersCards(players: [Player]) {
        var onlyPlayer = players[0]
        if onlyPlayer.eliminated == false {
            player11.currentCard = onlyPlayer.hand[0]
            player12.currentCard = onlyPlayer.hand[1]
        }
        else {
            player11.hidden = true
            player12.hidden = true
        }
        var only2ndPlayer = players[1]
        if only2ndPlayer.eliminated == false {
            opponent11.currentCard = nil
            opponent12.currentCard = nil
        }
        else {
            opponent11.hidden = true
            opponent12.hidden = true
        }
        if players.count > 2 {
            let player = players[2]
            if player.eliminated == false {
                opponent21.currentCard = nil
                opponent22.currentCard = nil
            }
            else {
                opponent21.hidden = true
                opponent22.hidden = true
            }
        }
        if players.count > 3 {
            let player = players[3]
            if player.eliminated == false {
                opponent31.currentCard = nil
                opponent32.currentCard = nil
            }
            else {
                opponent31.hidden = true
                opponent32.hidden = true
            }
        }
        //so now the player cards are dealt.
    }
    
    func updateCommunityCards(cards: [Card], forStage: Int) {
    }
    
    override func viewWillAppear(animated: Bool) {
        println("appeared")
        gameController.holdemViewController = self
        //betAlertController.add
        cardImages.append(player11)
        cardImages.append(player12)
        //        cardImages.append(opponent11)
        //        cardImages.append(opponent12)
        cardImages.append(flop1)
        cardImages.append(flop2)
        cardImages.append(flop3)
        cardImages.append(turn)
        cardImages.append(river)
        
        cardImages.append(opponent11)
        cardImages.append(opponent12)
        //conform to protocol at top too:
        var player0 = gameController.players[0]
        self.gameController.delegate = self
       
        //self.beginGame()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setupBetActionController()
        self.setupBetAlertController()
        self.beginGame()
    }
    
    func beginGame() {
        //new deck. deck should be shuffled.
        //deal out one players cards.
        //reset the deck:
        //these should be reset at beginning of each hand.
        self.roundNumber++
        gameController.establishBlinds()
        gameController.rotatePlayerRoles()
        //for all players:
        for eachPlayer in gameController.players {
            bestHandType = 0
            //forgetting this did not actually cause problems.
            eachPlayer.best5CardCombo = [Card]()
            best5CardCombo = [Card]()
        }
        
        for eachCard in self.cardImages {
            eachCard.currentCard = nil
        }
        
        //game controller will deal the cards.
        //tell holdemcontroller to prompt user for bet.
        self.handLabel.hidden = true
        self.gameController.setUpGame()
        self.gameController.dealCards()
        //player left of the button will act first
        gameController.beginBetRound()
        self.currentPlayer = self.gameController.players[(dealerButton+1)%(gameController.players.count)]
        
        //do a for-in loop for all players.
        //call beginPlayersTurn(), but for now, I substitute with BUTTON.
        self.beginPlayersTurn()
        //gameController.beginBetRound()
        //ERROR: this below method is getting called before beginPlayersTurn() is done:
        //once that is done, do a while-loop to confirm all bets match.
    }
    
    func setupBetActionController() {
        var checkAction = UIAlertAction(title: "Check/Call", style: UIAlertActionStyle.Default) { (Action: UIAlertAction!) -> Void in
            self.gameController.receiveBet(self.gameController.currentHighestBet, player: self.gameController.players[self.gameController.currentPlayer])
        }
        var betAction = UIAlertAction(title: "Bet/Raise", style: UIAlertActionStyle.Default) { (Action: UIAlertAction!) -> Void in
            self.presentViewController(self.betAlertController, animated: true, completion: nil)
        }
        var foldAction = UIAlertAction(title: "Fold", style: UIAlertActionStyle.Destructive) { (Action: UIAlertAction!) -> Void in
            //self.gameController.players[self.gameController.currentPlayer].folded = true
            self.gameController.receiveFold(self.gameController.players[self.gameController.currentPlayer])
        }
        self.betActionController.addAction(checkAction)
        self.betActionController.addAction(betAction)
        self.betActionController.addAction(foldAction)
    }
    func setupBetAlertController() {
        self.betAlertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.delegate = self
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.returnKeyType = UIReturnKeyType.Done
        }
        var okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default) { (Action: UIAlertAction!) -> Void in
            //self.textFieldDidEndEditing(self.betAlertController.textFields.first as UITextField)
        }
        self.betAlertController.addAction(okAction)
    }
    
    func textFieldDidEndEditing(textField: UITextField!) {
        self.betAlertController.dismissViewControllerAnimated(true, completion: nil)
        gameController.receiveBet(textField.text.toInt()!, player: gameController.players[gameController.currentPlayer])
        //after bet is received, check if round is over.
        //do a for-in loop for all players.
        //call beginPlayersTurn(), but for now, I substitute with BUTTON.
        //once that is done, do a while-loop to confirm all bets match.
        
    }
    
    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        var playerChips = self.gameController.players[self.gameController.currentPlayer].chips
        var betAmount = textField.text.toInt()
        if (betAmount >= playerChips) {
            textField.text = "\(playerChips)"
            return false
        }
        
        return true
    }
    //name of func to be changed to beginBettingRound:
    func beginPlayersTurn() {
        //to create a loop for this.
        
        if !gameController.players[gameController.currentPlayer].isComputer {
            self.betActionController.title = "Player \(gameController.currentPlayer), place your bet"
            if self.betActionController.popoverPresentationController != nil {
                
            self.betActionController.popoverPresentationController.sourceView = self.flop1
              //self.betActionController.popoverPresentationController.sourceView = self.flop1
            }
            self.presentViewController(self.betActionController, animated: true, completion: nil)
        }
        else {
            //so since it's a computer,
            gameController.placeBetForComputer(100, player: gameController.players[gameController.currentPlayer])
        }
        
    }
    func allInDone() {
        self.allInMode = false
    }
    
    func beginAllIn() {
        //reveal opponent's cards:
        var only2ndPlayer = gameController.players[1]
        if only2ndPlayer.eliminated == false && only2ndPlayer.folded == false {
            opponent11.currentCard = only2ndPlayer.hand[0]
            opponent12.currentCard = only2ndPlayer.hand[1]
        }
        if gameController.players.count > 2 {
            let player = gameController.players[2]
            if player.eliminated == false && player.folded == false {
                opponent21.currentCard = player.hand[0]
                opponent22.currentCard = player.hand[1]
            }
        }
        if gameController.players.count > 3 {
            let player = gameController.players[3]
            if player.eliminated == false && player.folded == false {
                opponent31.currentCard = player.hand[0]
                opponent32.currentCard = player.hand[1]
            }
        }
        //MISSING METHOD: reveal all cards.
        if handStage == 0 {
            var timer1 = NSTimer.scheduledTimerWithTimeInterval(14, target: self, selector: Selector("dealNext"), userInfo: nil, repeats: false)
            var timer2 = NSTimer.scheduledTimerWithTimeInterval(35, target: self, selector: Selector("dealNext"), userInfo: nil, repeats: false)
            var timer3 = NSTimer.scheduledTimerWithTimeInterval(70, target: self, selector: Selector("dealNext"), userInfo: nil, repeats: false)
            var timer4 = NSTimer.scheduledTimerWithTimeInterval(72, target: self, selector: Selector("dealNext"), userInfo: nil, repeats: false)
            var timer5 = NSTimer.scheduledTimerWithTimeInterval(74, target: self, selector: Selector("allInDone"), userInfo: nil, repeats: false)
        }
        else if handStage == 1 {
            var timer1 = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: Selector("dealNext"), userInfo: nil, repeats: false)
            var timer2 = NSTimer.scheduledTimerWithTimeInterval(55, target: self, selector: Selector("dealNext"), userInfo: nil, repeats: false)
            var timer3 = NSTimer.scheduledTimerWithTimeInterval(57, target: self, selector: Selector("dealNext"), userInfo: nil, repeats: false)
            var timer4 = NSTimer.scheduledTimerWithTimeInterval(59, target: self, selector: Selector("allInDone"), userInfo: nil, repeats: false)
        }
        else if handStage == 2 {
            var timer1 = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("dealNext"), userInfo: nil, repeats: false)
            var timer2 = NSTimer.scheduledTimerWithTimeInterval(32, target: self, selector: Selector("dealNext"), userInfo: nil, repeats: false)
            var timer3 = NSTimer.scheduledTimerWithTimeInterval(34, target: self, selector: Selector("allInDone"), userInfo: nil, repeats: false)
        }
        
    }
    
    func faceDown() -> UIImage {
        return faceDownImage
    }
    func dealFlop() {
        handStage = 1
        gameController.isPreFlop = false
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
        for eachImage in cardImages {
            eachImage.layer.borderColor = UIColor.greenColor().CGColor
            eachImage.currentCard = nil
        }
        //not calling this caused repeat pocket cards:
        for eachPlayer in gameController.players {
            eachPlayer.hand = [Card]()
            eachPlayer.handPlusBoard = [Card]()
            eachPlayer.best5CardCombo = [Card]()
            eachPlayer.bestHandType = 0
            eachPlayer.handName = ""
            eachPlayer.folded = false
            eachPlayer.lossForHand = 0
            eachPlayer.isAllIn = false
            eachPlayer.isLeading = false
            if eachPlayer.eliminated == false {
                eachPlayer.isLive = true
            }
        }
        handStage = 0
        gameController.isPreFlop = true
        println("endRound")
        self.beginGame()
    }
    func showDown() {
        handStage = 4
        println("showdown")
        gameController.awardWinnerContested(true,falseWinner: gameController.players[0])
    }
    
    func evaluate5CardHand(var cardsToEvaluate: [Card]) -> [Card] {
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
                    //WHEEL detected
                    //move ace to the back; it is now small.
                    let saveAce = cardsToEvaluate[0]
                    cardsToEvaluate.removeAtIndex(0)
                    cardsToEvaluate.append(saveAce)
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
        //return self.handLabel.text
        return cardsToEvaluate
        //add new parameters.
    }
    
    func evaluate6CardHand(cardsToEvaluate6: [Card]) {
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
    
    func dealNext() {
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
            
            for eachPlayer in gameController.players {
                eachPlayer.handPlusBoard.append(flop1.currentCard)
                eachPlayer.handPlusBoard.append(flop2.currentCard)
                eachPlayer.handPlusBoard.append(flop3.currentCard)
                (eachPlayer.best5CardCombo, eachPlayer.bestHandType) = eachPlayer.evaluate5CardHand(eachPlayer.handPlusBoard)
//                while eachPlayer.handPlusBoard.count > 2 {
//                    eachPlayer.handPlusBoard.removeLast()
//                }
            }
            self.evaluate5CardHand(cardsUsed)
            // ADDED TUES
            //begin betting round, but for now call beginPlayersTurn.
            if !self.allInMode {
                gameController.beginBetRound()
                //self.beginPlayersTurn()
                var timer1 = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("beginPlayersTurn"), userInfo: nil, repeats: false)
                
            }
            else {
                gameController.calculateOuts()
                //calculate odds. If odds are already 100%, just quickly deal next cards.
            }
        }
        else if handStage == 1 {
            self.dealTurn()
            cardsUsed.append(flop1.currentCard)
            cardsUsed.append(flop2.currentCard)
            cardsUsed.append(flop3.currentCard)
            cardsUsed.append(turn.currentCard)
            for eachPlayer in gameController.players {
//                eachPlayer.handPlusBoard.append(flop1.currentCard)
//                eachPlayer.handPlusBoard.append(flop2.currentCard)
//                eachPlayer.handPlusBoard.append(flop3.currentCard)
                eachPlayer.handPlusBoard.append(turn.currentCard)
                if !eachPlayer.handPlusBoard.isEmpty {
                    (eachPlayer.best5CardCombo, eachPlayer.bestHandType) = eachPlayer.evaluate6CardHand(eachPlayer.handPlusBoard)
                }
//                while eachPlayer.handPlusBoard.count > 2 {
//                    eachPlayer.handPlusBoard.removeLast()
//                }
            }
            self.evaluate6CardHand(cardsUsed)
            // ADDED TUES
            if !self.allInMode {
                gameController.beginBetRound()
                //self.beginPlayersTurn()
                var timer1 = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("beginPlayersTurn"), userInfo: nil, repeats: false)
            }
            else {
                gameController.calculateOuts()
            }
        }
        else if handStage == 2 {
            self.dealRiver()
            cardsUsed.append(flop1.currentCard)
            cardsUsed.append(flop2.currentCard)
            cardsUsed.append(flop3.currentCard)
            cardsUsed.append(turn.currentCard)
            cardsUsed.append(river.currentCard)
            //this should be for-in loop, for all players:
            for eachPlayer in gameController.players {
//                eachPlayer.handPlusBoard.append(flop1.currentCard)
//                eachPlayer.handPlusBoard.append(flop2.currentCard)
//                eachPlayer.handPlusBoard.append(flop3.currentCard)
//                eachPlayer.handPlusBoard.append(turn.currentCard)
                eachPlayer.handPlusBoard.append(river.currentCard)
                if !eachPlayer.handPlusBoard.isEmpty {
                    (eachPlayer.best5CardCombo, eachPlayer.bestHandType) = eachPlayer.evaluateFullHand(eachPlayer.handPlusBoard)
                }
//                while eachPlayer.handPlusBoard.count > 2 {
//                    eachPlayer.handPlusBoard.removeLast()
//                }
            }
            self.evaluateFullHand(cardsUsed)
            //highlight the cards used:
            for eachImage in cardImages {
                for eachUsed in best5CardCombo {
                    if (eachImage.currentCard.value == eachUsed.value) && (eachImage.currentCard.suit == eachUsed.suit) {
                        eachImage.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
            }
            // ADDED TUES
            if !self.allInMode {
                gameController.beginBetRound()
                //self.beginPlayersTurn()
                var timer1 = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("beginPlayersTurn"), userInfo: nil, repeats: false)
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
    
    @IBAction func BeginPressed(sender: AnyObject) {
        //begin while-loop.
        self.beginPlayersTurn()
        //gameController.beginBetRound()
    }
    
    @IBAction func dealNextPressed(sender: AnyObject) {
        self.dealNext()
        
    }

}
