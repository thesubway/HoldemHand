//
//  AllinCalculator.swift
//  HoldemHand
//
//  Created by Dan Hoang on 9/10/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

class AllinCalculator {
    var holdemViewController : HoldemViewController
    init(holdemViewController : HoldemViewController) {
        self.holdemViewController = holdemViewController
    }
    func calcOuts(players : [Player]) {
        var unshuffledDeck = UnshuffledDeck()
        for eachPlayer in players {
            var possibleHand = [Card]()
            var possibleRank = 0
            for eachCard in unshuffledDeck.cards {
//                    (possibleHand,possibleRank) = eachPlayer.testOneCard(eachCard)
                eachPlayer.testOneCard(eachCard)
            }
        }
    }
}
