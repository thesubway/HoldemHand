//
//  PlayerCardsView.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/31/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

class PlayerView: UIView {

    var cardView1 = CardImage()
    var cardView2 = CardImage()
    var seatNumber : Int!
    
    
    func initializeSelf() {
        
        cardView1.frame = CGRectMake(0, 9, 50, 62)
        cardView2.frame = CGRectMake(14, 0, 50, 62)
        cardView1.layer.borderWidth = 1
        cardView1.layer.borderColor = UIColor.redColor().CGColor
        cardView2.layer.borderWidth = 1
        cardView2.layer.borderColor = UIColor.redColor().CGColor
        self.addSubview(cardView1)
        self.addSubview(cardView2)
    }

}
