import Foundation
class CardGame {
    //game will be "higher or lower"
    var highLowDeck = DeckOfCards()
}
class DeckOfCards {
    var cards: [Card] = []
    var numSuits = 4
    var fullDeckCount = 0
    init() {
        //assumes the ace is highest value.
        var i = 2
        while i <= 14 {
            let newCard:Card = Card(value: i, suit: "c")
            let newCard2:Card = Card(value: i, suit: "d")
            let newCard3:Card = Card(value: i, suit: "h")
            let newCard4:Card = Card(value: i, suit: "s")
            cards.append(newCard)
            cards.append(newCard2)
            cards.append(newCard3)
            cards.append(newCard4)
            self.numSuits = 4
            i++
        }
        //shuffle the deck
        cards = shuffleDeck(cards)
        fullDeckCount = self.cards.count
    }
    var notInDeck: [Card] = []
    func drawCard() -> Card {
        //ENSURE deck is not empty first:
        assert(cards.count != 0)
        var nextCardInDeck = cards[0]
        cards.removeAtIndex(0)
        notInDeck.append(nextCardInDeck)
        return nextCardInDeck
    }
    func shuffleDeck<Card>(var list: Array<Card>) -> Array<Card> {
        for i in 0..<list.count {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            list.insert(list.removeAtIndex(j), atIndex: i)
        }
        return list
    }
}
class Card {
    //these values will change
    var valueName = ""
    var valueDisplay = ""
    var suitName = ""
    var value = 0
    var suit = ""
    init(value: Int, suit: String) {
        self.value = value
        self.suit = suit
        switch value {
        case 10:
            valueName = "10"
            valueDisplay = "T"
        case 11:
            valueName = "Jack"
            valueDisplay = "J"
        case 12:
            valueName = "Queen"
            valueDisplay = "Q"
        case 13:
            valueName = "King"
            valueDisplay = "K"
        case 14:
            valueName = "Ace"
            valueDisplay = "A"
        case 1:
            valueName = "Ace"
            valueDisplay = "A"
            //else, the card will display its current number
        default:
            valueName = "\(value)"
            valueDisplay = "\(value)"
        }
        switch suit {
        case "c":
            suitName = "clubs"
        case "d":
            suitName = "diamonds"
        case "h":
            suitName = "hearts"
        case "s":
            suitName = "spades"
        default:
            suitName = "noSuit?"
        }
    }
}