//
//  BetController.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/12/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import GameKit

//at first it was BetController.
protocol GameControllerDelegate {
    //because they have new cards to display.
    func updatePlayersCards(players: [Player])
    //it will be up to the other controller to figure out round.
    func updateCommunityCards(cards: [Card], forStage: Int)
    
}

class GameController {
    var match : GKTurnBasedMatch?
    
    //var holdemDeck = DeckOfCards()
    var handSorter = HandSorter()
    var handComparer = HandComparer()
    var holdemViewController : HoldemViewController!
    var startingChips: Int!
    var players = [Player]()
    var delegate : GameControllerDelegate!
    var currentHighestBet = 0
    
    var gameSummary = [String]()
    @IBInspectable var dealerButton : Int! {
        //be sure it skips the eliminated players.
        didSet {
            
            print("dealer button moves from \(dealerButton) ")
            while self.players[dealerButton].eliminated == true {
                dealerButton = (dealerButton + 1) % self.players.count
            }
            if (self.players.count - self.eliminatedPlayers.count == 2) {
                smallBlind = dealerButton
                bigBlind = (smallBlind + 1) % self.players.count
                while (self.players[bigBlind].eliminated == true) {
                    bigBlind = (bigBlind + 1) % self.players.count
                }
            }
            else {
                //there are > 2 players left, so:
                smallBlind = (dealerButton + 1) % self.players.count
                while (self.players[smallBlind].eliminated == true) {
                    smallBlind = (smallBlind + 1) % self.players.count //this increments blind
                }
                bigBlind = (smallBlind + 1) % self.players.count
                while (self.players[bigBlind].eliminated == true) {
                    bigBlind = (bigBlind + 1) % self.players.count //this increments blind
                }
            }
            println("to \(dealerButton)")
        }
    }
    var smallBlind = 0
    var bigBlind = 0
    var potSize = 0
    var winningPlayers = [Player]()
    var eliminatedPlayers = [Player]()
    
    var currentPlayer : Int! //this player shall act next
    var roundIsOver : Bool!
    
    var isPreFlop = true
    
    @IBInspectable var firstPlayerToAct : Int! {
        didSet {
            while (self.players[self.firstPlayerToAct].isLive == false) {
                self.firstPlayerToAct = (self.firstPlayerToAct + 1) % self.players.count
            }
        }
    }
    @IBInspectable var lastPlayerToAct: Int! {
        didSet {
            while (self.players[self.lastPlayerToAct].isLive == false) {
                self.lastPlayerToAct = (self.lastPlayerToAct - 1 + self.players.count) % self.players.count
            }
        }
    }
    init(startingChips: Int, numPlayers: Int) {
        self.startingChips = startingChips
        //create human player:
        var player0 = Player(isComputer: false, seatNumber: 0)
        player0.chips = startingChips
        players.append(player0)
        for i in 1..<(numPlayers) {
            var player = Player(isComputer: true, seatNumber: i)
            player.chips = startingChips
            players.append(player)
        }
    }
    func setUpGame() {
        holdemDeck = DeckOfCards()
    }
    func dealCards() {
        for eachPlayer in players {
            eachPlayer.hand.append(holdemDeck.drawCard())
            eachPlayer.hand.append(holdemDeck.drawCard())
            eachPlayer.handPlusBoard.append(eachPlayer.hand[0])
            eachPlayer.handPlusBoard.append(eachPlayer.hand[1])
                //but the images won't show.
                //protocol image delegate
        }
        self.delegate.updatePlayersCards(players)
    }
    func establishBlinds() {
        println("establishing blinds")
        if (players.count-eliminatedPlayers.count) == 2 {
            if dealerButton == nil {
                dealerButton = 0
            }
//            smallBlind = 0
//            bigBlind = 1
        }
        else {
            if dealerButton == nil {
                dealerButton = 0
            }
//            smallBlind = 1
//            bigBlind = 2
        }
    }
    func rotatePlayerRoles() {
        self.dealerButton = (self.dealerButton + 1) % self.players.count
//        self.smallBlind++
//        self.bigBlind++
        //in case it passes
        
    }
    func beginBetRound() {
        self.currentHighestBet = 0
        for eachPlayer in players {
            eachPlayer.betForRound = 0
        }
        if isPreFlop && (self.players.count-self.eliminatedPlayers.count) == 2 {
            firstPlayerToAct = dealerButton
            lastPlayerToAct = bigBlind
        }
        else if isPreFlop && (self.players.count-self.eliminatedPlayers.count) != 2 {
            //start with small blind.
            firstPlayerToAct = (bigBlind + 1) % players.count
            //var lastPlayerToAct = (firstPlayerToAct - 1 + players.count) % players.count
            lastPlayerToAct = bigBlind
        }
        else if (!isPreFlop) && (self.players.count-self.eliminatedPlayers.count) == 2 {
            firstPlayerToAct = bigBlind
            lastPlayerToAct = dealerButton
        }
        else if (!isPreFlop) && (self.players.count-self.eliminatedPlayers.count) != 2 {
            firstPlayerToAct = smallBlind
            lastPlayerToAct = dealerButton
        }
        //in case those set players are not live:
        self.currentPlayer = firstPlayerToAct
        //once bet round ends, set isPreFlop = false, regardless of round.
    }
    func placeBetForPlayer(amount: Int, player: Player) {
        
    }
    func receiveBet(amount: Int, player: Player) {
        //set the player's bet.
        var betAmount = amount
        if (amount >= player.chips) {
            betAmount = player.chips
            self.receiveAllIn(player)
        }
        player.betForRound = betAmount
        if player.folded == true {
            holdemViewController.handLabel.text = "Player \(player.seatNumber) folds"
            gameSummary.append("Player \(player.seatNumber) folds")
        }
        else if betAmount == 0 {
            holdemViewController.handLabel.text = "Player \(player.seatNumber) checks."
            gameSummary.append("Player \(player.seatNumber) checks.")
        }
        if player.betForRound > self.currentHighestBet {
            if self.currentHighestBet == 0 {
                //so it's a bet.
                if player.isAllIn == false {
                    holdemViewController.handLabel.text = "Player \(player.seatNumber) bets \(betAmount) chips"
                    gameSummary.append("Player \(player.seatNumber) bets \(betAmount) chips")
                }
                else {
                    holdemViewController.handLabel.text = "Player \(player.seatNumber) bets \(betAmount) chips"
                    gameSummary.append("Player \(player.seatNumber) bets \(betAmount) chips")
                }
            }
            else {
                if player.isAllIn == false {
                    gameSummary.append("Player \(player.seatNumber) raises to \(betAmount)")
                    holdemViewController.handLabel.text = "Player \(player.seatNumber) raises to \(betAmount)"
                }
                else {
                    gameSummary.append("Player \(player.seatNumber) raises ALL-IN for \(betAmount)")
                    holdemViewController.handLabel.text = "Player \(player.seatNumber) raises ALL-IN for \(betAmount)"
                }
            }
            self.currentHighestBet = player.betForRound
            //raiser/better is now treated as the "first to act":
            self.firstPlayerToAct = player.seatNumber
            self.lastPlayerToAct = (player.seatNumber - 1 + self.players.count) % self.players.count
        }
        else if player.betForRound == self.currentHighestBet {
            if self.currentHighestBet > 0 {
                //That means he calls.
                if player.isAllIn == false {
                    gameSummary.append("Player \(player.seatNumber) calls \(betAmount)")
                    holdemViewController.handLabel.text = "Player \(player.seatNumber) calls \(betAmount)"
                }
                else {
                    gameSummary.append("Player \(player.seatNumber) calls ALL-IN for \(betAmount)")
                    holdemViewController.handLabel.text = "Player \(player.seatNumber) calls ALL-IN for \(betAmount)"
                }
            }
        }
        holdemViewController.tableView.reloadData()
        //check if round is over.
        if player.seatNumber != lastPlayerToAct {
            //this begins the next player's turn:
            //DO NOT DUPLICATE:
            do {
                self.currentPlayer = (self.currentPlayer + 1) % self.players.count
            }
            while (self.players[currentPlayer].isLive == false)
            //if duplicate, it will increment 2 players. Don't want that.
            if let isComputer = self.players[currentPlayer].isComputer {
                if isComputer {
                    print("Computer makes a bet: ")
//                    var timer1 = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("placeBetForComputer"), userInfo: nil, repeats: false)
                    self.placeBetForComputer()
                }
                else {
                    //this means it's a human, so:
                    println("Human at seat \(self.currentPlayer) to bet: ")
                    holdemViewController.beginPlayersTurn()
                }
            }
        }
        else if player.seatNumber == lastPlayerToAct {
            //place the bet.
            
            //end the betting round somehow:
            gameSummary.append("betting round has ended.")
            holdemViewController.tableView.reloadData()
            //subtract all player's chips.
            for eachPlayer in self.players {
                self.potSize += eachPlayer.betForRound
                if let chipTot = eachPlayer.chips {
                    eachPlayer.chips = eachPlayer.chips - eachPlayer.betForRound
                    eachPlayer.lossForHand = eachPlayer.lossForHand + eachPlayer.betForRound
                }
            }
            //reset everything here? No. receiveBet method should do that.
            //check if all-in mode:
            var numPlayersLive = 0
            for eachPlayer in self.players {
                if eachPlayer.folded == false && eachPlayer.eliminated == false {
                    if eachPlayer.isAllIn == false {
                        numPlayersLive++
                    }
                }
                
            }
            if numPlayersLive <= 1 {
                //turn on all-in mode
                holdemViewController.allInMode = true
                holdemViewController.beginAllIn()
            }
            else {
                holdemViewController.dealNext()
            }
        }
    }
    func placeBetForComputer() {
        if self.players[currentPlayer].hand[0].value == self.players[currentPlayer].hand[1].value {
            if self.players[currentPlayer].hand[0].value <= 8 {
                self.receiveBet((self.currentHighestBet + 5) * 2, player: self.players[currentPlayer])
            }
            else {
                //go basically all-in:
                self.receiveBet(self.currentHighestBet + 1000, player: self.players[currentPlayer])
            }
        }
        else {
            var aceCard = 0
            var highCards = 0
            var medHighCards = 0
            var medLowCards = 0
            var lowCards = 0
            for eachCard in self.players[currentPlayer].hand {
                if eachCard.value >= 14 {
                    aceCard++
                }
                if eachCard.value > 11 {
                    highCards++
                }
                else if eachCard.value > 8 {
                    medHighCards++
                }
                else if eachCard.value > 5 {
                    medLowCards++
                }
                else {
                    lowCards++
                }
            }
            if highCards == 2 {
                self.receiveBet(self.currentHighestBet + 1000, player: self.players[currentPlayer])
            }
            else if aceCard > 0 {
                //check-or-call algorithm.
                self.receiveBet(self.currentHighestBet, player: self.players[currentPlayer])
            }
            else if highCards == 1 {
                if self.currentHighestBet < 50 {
                    self.receiveBet(self.currentHighestBet, player: self.players[currentPlayer])
                }
                else {
                    self.receiveFold(self.players[currentPlayer])
                }
            }
            else {
                if self.currentHighestBet == 0 {
                    self.receiveBet(self.currentHighestBet, player: self.players[currentPlayer])
                }
                else {
                    self.receiveFold(self.players[currentPlayer])
                }
            }
        }
    }
    func receiveFold(player: Player) {
        player.folded = true
        player.isLive = false
        //now their cards are gone:
        var playersIn = [Player]()
        var numPlayersLive = 0
        //now go through a series of checkings:
        //check what players are still in:
        for eachPlayer in self.players {
            if eachPlayer.folded == false && eachPlayer.eliminated == false {
                playersIn.append(eachPlayer)
                if eachPlayer.isAllIn == false {
                    numPlayersLive++
                }
            }
            
        }
        if playersIn.count == 1 {
            //give that player the chips.
            println("Only player \(playersIn[0].seatNumber) left")
            self.awardWinnerContested(false,falseWinner: playersIn[0])
            //end game
            holdemViewController.endRound()
        }
        //if numPlayersLive = 1, another method's got that covered.
        else if numPlayersLive == 0 {
            //turn on all-in mode
            println("COMMENTED out all-in,allin")
            //however, end the round first by collecting chips:
            for eachPlayer in self.players {
                self.potSize += eachPlayer.betForRound
                if let chipTot = eachPlayer.chips {
                    eachPlayer.chips = eachPlayer.chips - eachPlayer.betForRound
                    eachPlayer.lossForHand = eachPlayer.lossForHand + eachPlayer.betForRound
                }
            }
            holdemViewController.allInMode = true
            holdemViewController.beginAllIn()
        }
        else {
            //change firstPlayerToAct accordingly, if the folding-player was last:
            if self.firstPlayerToAct == player.seatNumber {
                self.firstPlayerToAct = (self.firstPlayerToAct + 1) % self.players.count
            }
            //don't need to change lastPlayerToAct. end of round anyway. plus, it would cause error.
            self.receiveBet(player.betForRound, player: player)
        }
    }
    func receiveAllIn(player: Player) {
        player.isAllIn = true
        player.isLive = false
        //before setting who acts first, make sure there is a live player.
        var numLive = 0
        for eachPlayer in self.players {
            if eachPlayer.isLive == true {
                numLive = numLive + 1
            }
        }
        if numLive > 0 {
            if self.firstPlayerToAct == player.seatNumber {
                self.firstPlayerToAct = (self.firstPlayerToAct + 1) % self.players.count
            }
        }
    }
    //so after all bets are made, check if match.
    func endRound() {
        //check if any players are out of chips.
        for var i = 0; i < players.count; i++ {
            if players[i].eliminated == false {
                if players[i].chips <= 0 {
                    println("Player at \(i) eliminated")
                    players[i].eliminated = true
                    //decrement i, to avoid skipping someone.
                }
            }
        }
    }
    func awardWinnerContested(contested: Bool,falseWinner: Player) {
        var winnerList = [Player]()
        if contested == true {
            winnerList = self.calculateLeader()
        }
        else {
            winnerList.append(falseWinner)
        }
        for eachPlayer in winnerList {
            self.winningPlayers.append(eachPlayer)
        }
        var chipsToGive = 0
        var listOfPlayers = "Players "
        for var i = 0; i < self.winningPlayers.count; i++ {
            chipsToGive = self.potSize / self.winningPlayers.count
//            println("Player \(eachPlayer.seatNumber) wins \(chipsToGive) chips!")
                listOfPlayers = listOfPlayers + "\(self.winningPlayers[i].seatNumber), "
            self.winningPlayers[i].chips = self.winningPlayers[i].chips + chipsToGive
        }
        listOfPlayers = listOfPlayers + "each win \(chipsToGive) chips!"
        if self.winningPlayers.count == 1 {
            holdemViewController.handLabel.text = "Player \(self.winningPlayers[0].seatNumber) wins \(chipsToGive) chips!"
        }
        else {
            holdemViewController.handLabel.text = listOfPlayers
        }
        //reset the list, and pot.
        for eachPlayer in self.winningPlayers {
            self.winningPlayers = [Player]()
        }
        self.potSize = 0
        //check for eliminations:
        var numEliminations = 0
        var eliminatedThisHand = [Player]()
        for eachPlayer in self.players {
            if eachPlayer.eliminated == false && eachPlayer.chips == 0 {
//                self.eliminatedPlayers.append(eachPlayer)
                eliminatedThisHand.append(eachPlayer)
                eachPlayer.tieBreak = eliminatedThisHand.count - 1
                numEliminations++
                eachPlayer.eliminated = true
            }
        }
        while numEliminations >= 1 {
            //find the player with fewest lost chips this round.
            var playerWithFewestChips = eliminatedThisHand[0]
            for eachPlayer in eliminatedThisHand {
                if eachPlayer.lossForHand < playerWithFewestChips.lossForHand {
                    playerWithFewestChips = eachPlayer
                }
                else if eachPlayer.lossForHand == playerWithFewestChips.lossForHand {
                    //check who had worse hand
                    playerWithFewestChips = handComparer.compareForLoser(eachPlayer, player2: playerWithFewestChips)
                }
            }
            //eliminate that player:
            eliminatedPlayers.append(playerWithFewestChips)
            playerWithFewestChips.finishPosition = self.players.count - self.eliminatedPlayers.count + 1
            println("Player \(playerWithFewestChips.seatNumber) eliminated in \(playerWithFewestChips.finishPosition)th place.")
            //now for eliminatedThisHand to somehow get rid of that player.
            eliminatedThisHand.removeAtIndex(playerWithFewestChips.tieBreak)
            //now to shift down other players:
            for eachPlayer in eliminatedThisHand {
                if eachPlayer.tieBreak > playerWithFewestChips.tieBreak {
                    eachPlayer.tieBreak = eachPlayer.tieBreak - 1
                }
            }
            numEliminations = numEliminations - 1
        }
        if numEliminations == 1 {
            eliminatedPlayers.append(eliminatedThisHand[0])
            eliminatedThisHand[0].finishPosition = self.players.count - self.eliminatedPlayers.count + 1
            if let fpos = eliminatedThisHand[0].finishPosition {
            switch fpos {
            case 3:
                println("Player \(eliminatedThisHand[0].seatNumber) is eliminated in \(eliminatedThisHand[0].finishPosition)rd place.")
            case 2:
                println("Player \(eliminatedThisHand[0].seatNumber) is eliminated in \(eliminatedThisHand[0].finishPosition)nd place.")
            case 1:
                println("Player \(eliminatedThisHand[0].seatNumber) is the champion!")
            default:
            println("Player \(eliminatedThisHand[0].seatNumber) is eliminated in \(eliminatedThisHand[0].finishPosition)th place.")
            }
            }
        }
        //announce the chip counts:
        println("Chip counts:")
        for eachPlayer in self.players {
            if eachPlayer.eliminated == false {
                println("Player \(eachPlayer.seatNumber): \(eachPlayer.chips) chips")
            }
            else {
                if let fpos = eachPlayer.finishPosition {
                switch fpos {
                case 3:
                    println("Player \(eachPlayer.seatNumber): Eliminated \(eachPlayer.finishPosition)rd place")
                case 2:
                    println("Player \(eachPlayer.seatNumber): Eliminated \(eachPlayer.finishPosition)nd place")
                case 1:
                    println("Player \(eachPlayer.seatNumber): Finished \(eachPlayer.finishPosition)st place with \(eachPlayer.chips) chips")
                default:
                    println("Player \(eachPlayer.seatNumber): Eliminated \(eachPlayer.finishPosition)th place")
                }
                }
            }
        }
    }
    func calculateOuts() {
        var outsForTie = [Card]()
        //make sure each player's outs are re-set
        for eachPlayer in self.players {
            assert(eachPlayer.outs.count == 0)
        }
        //so only testing one card at a time
        assert(handStage == 1 || handStage == 2)
        var unshuffledDeck = UnshuffledDeck()
        var bestHand = [Card]()
        var playersInHand = [Player]()
        //to filter out any player not in the hand:
        for eachPlayer in self.players {
            if eachPlayer.folded == false && eachPlayer.eliminated == false {
                playersInHand.append(eachPlayer)
            }
        }
        for eachCard in unshuffledDeck.cards {
            //ensure card is not already visible on field.
            var cardAlreadyVisible = false
            for eachPlayer in playersInHand {
                for eachCard2 in eachPlayer.handPlusBoard {
                    if handComparer.cardsAreEqual(eachCard, card2: eachCard2) == true {
                        cardAlreadyVisible = true
                    }
                }
            }
            if cardAlreadyVisible == true {
                continue
            }
            var oneCardArray = [Card]()
            oneCardArray.append(eachCard)
            var allHands = [[Card]]()
            var allValues = [Int]()
            //to keep track of which seat player is in:
            var playerAtSeat = [Int]()
            for eachPlayer in playersInHand {
                var potentialHand = [Card]()
                var potentialValue = 0
                (potentialHand,potentialValue) = eachPlayer.testNextCard(oneCardArray)
                allHands.append(potentialHand)
                allValues.append(potentialValue)
                playerAtSeat.append(eachPlayer.seatNumber)
            }
            //now compare all of them, to find the best:
            bestHand = handComparer.compareMultipleHands(allHands,allValues: allValues)
            //track all players who would have best hand:
            var playersWithBest = [Player]()
            for var i = 0; i < allHands.count; i++ {
                if handComparer.isEqual(allHands[i], to: bestHand) == true {
                    playersWithBest.append(self.players[playerAtSeat[i]])
                }
            }
            assert(playersWithBest.count > 0)
            if playersWithBest.count > 1 {
                outsForTie.append(eachCard)
            }
            else {
                playersWithBest[0].outs.append(eachCard)
            }
        }
        self.calculateLeader()
        //first, re-set the cards.
        holdemViewController.outsCards = [Card]()
        for eachPlayer in playersInHand {
            if eachPlayer.isLeading == false {
                println("Player \(eachPlayer.seatNumber) has \(eachPlayer.outs.count) outs:")
                for eachCard2 in eachPlayer.outs {
                    //add to first outs list:
                    holdemViewController.outsCards.append(eachCard2)
                    print("\(eachCard2.valueDisplay)\(eachCard2.suit) ")
                }
                println()
            }
        }
        holdemViewController.collectionView.reloadData()
        println("There are \(outsForTie.count) outs for TIE.")
        if outsForTie.count < 23 && outsForTie.count > 0 {
            for eachCard in outsForTie {
                print("\(eachCard.valueDisplay)\(eachCard.suit) ")
            }
            println()
        }
        //done with outs, so empty the lists again.
        for eachPlayer in self.players {
            eachPlayer.outs = [Card]()
        }
    }
    func calculateOdds() {
        
    }
    func calculateLeader() -> [Player] {
        var winningHand = [Card]()
        var winningHandType = 0
        var winnerList = [Player]()
        for eachPlayer in self.players {
            //TO-DO: check if folded, but that's for later.
            if (eachPlayer.folded == false && eachPlayer.eliminated == false) {
            if winningHand.count != 5 {
                var emptyArray = [Card]()
                (winningHand,winningHandType) = eachPlayer.testNextCard(emptyArray)
//                winningHandType = eachPlayer.bestHandType
            }
            else {
                //pass in parameter bestHandType.
                //also pass in parameter of hand.
                winningHand = handComparer.compare(winningHand,hand2: eachPlayer.best5CardCombo,hand1Type: winningHandType,hand2Type: eachPlayer.bestHandType)
                //NOTE: not the same method as previous line. Returns different type:
                winningHandType = handComparer.compare(winningHand,hand2: eachPlayer.best5CardCombo,hand1Type: winningHandType,hand2Type: eachPlayer.bestHandType)
                //update winningHandType
            }
            }
        }
        for var i = 0; i < self.players.count; i++ {
            var eachPlayer = self.players[i]
            if (self.players[i].folded == false && self.players[i].eliminated == false) {
                //TO-DO: should check if folded, but that's for later.
                var isEqualToWinner = handComparer.areEqual(eachPlayer.best5CardCombo, hand2: winningHand, hand1Type: eachPlayer.bestHandType, hand2Type: winningHandType)
                if handStage == 4 {
                print("Player \(i) hand: ")
                for eachCard in eachPlayer.hand {
                    print("\(eachCard.valueName) \(eachCard.suit);")
                }
                println()
                for eachCard in eachPlayer.best5CardCombo {
                    print("\(eachCard.valueName) \(eachCard.suit);")
                }
                }
                if isEqualToWinner {
                    if handStage == 4 {
                        println("\nPlayer \(i) wins!")
                    }
                    else {
                        println("\nPlayer \(i) leads.")
                        self.players[i].isLeading = true
                    }
                    winnerList.append(self.players[i])
                }
                else {
                    if handStage == 4 {
                    println("\nPlayer \(i) does not win.")
                    }
                    else {
                        self.players[i].isLeading = false
                        //Display their outs in other method.
                    }
                }
            }
        }
        for eachPlayer in winnerList {
            if winnerList.count > 1 {
                if let leadCheck = eachPlayer.isLeading {
                    if eachPlayer.isLeading == true {
                        eachPlayer.isLeading = false
                    }
                }
            }
        }
        return winnerList
    }
}