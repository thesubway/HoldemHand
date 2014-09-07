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
    var chipsLabel = UILabel()
    var betLabel = UILabel()
    var player : Player!
    
    func initializeSelf(player : Player) {
        self.player = player
        self.player.selfView = self
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            cardView1.frame = CGRectMake(0, 9, 50, 62)
            cardView2.frame = CGRectMake(14, 0, 50, 62)
            cardView1.layer.borderWidth = 1
            cardView1.layer.borderColor = UIColor.redColor().CGColor
            cardView2.layer.borderWidth = 1
            cardView2.layer.borderColor = UIColor.redColor().CGColor
            self.addSubview(cardView1)
            self.addSubview(cardView2)
            
            self.chipsLabel.frame = CGRectMake(64, -8, 32, 48)
            self.chipsLabel.text = "P\(self.player.seatNumber)\n Chips:\n500"
            self.chipsLabel.numberOfLines = 0
            self.chipsLabel.font = UIFont(name: self.chipsLabel.font.fontName, size: 8)
            self.addSubview(self.chipsLabel)
            
            self.betLabel.frame = CGRectMake(51, 58, 36, 16)
            self.betLabel.text = "Check"
            self.betLabel.font = UIFont(name: self.betLabel.font.fontName, size: 5)
            self.addSubview(betLabel)
        }
        else if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            cardView1.frame = CGRectMake(0, 9, 75, 93)
            cardView2.frame = CGRectMake(14, 0, 75, 93)
            cardView1.layer.borderWidth = 1
            cardView1.layer.borderColor = UIColor.redColor().CGColor
            cardView2.layer.borderWidth = 1
            cardView2.layer.borderColor = UIColor.redColor().CGColor
            self.addSubview(cardView1)
            self.addSubview(cardView2)
            
            self.chipsLabel.frame = CGRectMake(89, -2, 80, 48)
            self.chipsLabel.text = "P\(self.player.seatNumber)\n Chips:\n500"
            self.chipsLabel.numberOfLines = 0
            self.chipsLabel.font = UIFont(name: self.chipsLabel.font.fontName, size: 12)
            self.addSubview(self.chipsLabel)
            
            self.betLabel.frame = CGRectMake(89, 70, 88, 24)
            self.betLabel.text = "Check"
            self.betLabel.font = UIFont(name: self.betLabel.font.fontName, size: 12)
            self.addSubview(betLabel)
        }
    }

}
