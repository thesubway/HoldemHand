//
//  CardImage.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/9/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

@IBDesignable class CardImage: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    
    */
    @IBInspectable var currentCard: Card! {
        didSet {
            //Card.suit refers to just the first letter
            //valueDisplay, because then the 10 must be T.
            if currentCard != nil {
            println("card has been set to \(currentCard.valueDisplay) of \(currentCard.suitName)")
            self.image = UIImage(named: "\(currentCard.valueDisplay)\(currentCard.suitName).jpg")
            }
            else {
//                println("card has been set to nil.")
                self.image = faceDownImage
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.redColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    func flipCard(cardView : UIImageView) {
        UIView.transitionWithView(cardView, duration: 0.2, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () -> Void in
            
            }) { (success : Bool) -> Void in
                
        }
    }
    //take care of the hidden features later

}
