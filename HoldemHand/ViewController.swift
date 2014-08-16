//
//  ViewController.swift
//  HoldemHand
//
//  Created by Dan Hoang on 8/9/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit
import GameKit
class ViewController: UIViewController, GKTurnBasedMatchmakerViewControllerDelegate, UINavigationControllerDelegate {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showGameCenterAuthController:", name: "present_authentication_view_controller", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func handleButtonPressed(sender: AnyObject) {
        
        println("pressed")
        
                var holdemView = self.storyboard.instantiateViewControllerWithIdentifier("holdemView") as HoldemViewController
        if self.navigationController {
            self.navigationController.pushViewController(holdemView, animated: true)
        }
    }

  func playPressed(sender: AnyObject) {
        

    }
    func showGameCenterAuthController(note: NSNotification) {
        println("method has been called")
        if let gkHelper = note.object as? GameKitHelper {
            self.presentViewController(gkHelper.authenticationViewController, animated: true, completion: { () -> Void in
                println("Showing authenticationVC")
            })
        }
        else {
            println("if does not work")
        }
    }
    @IBAction func joinMatchPressed(sender: AnyObject) {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showGameCenterAuthController:", name: "present_authentication_view_controller", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("present_authentication_view_controller", object: nil)
        var matchRequest = GKMatchRequest()
        //set min and max players:
        matchRequest.minPlayers = 2
        matchRequest.maxPlayers = 6
        
        //will be a pre-built controller:
        var matchRequestVC = GKTurnBasedMatchmakerViewController(matchRequest: matchRequest)
        matchRequestVC.delegate = self
        
        
        
//        let localPlayer = GKLocalPlayer()
        let localPlayer = GameKitHelper.getLocalPlayer()
        
        if localPlayer.authenticated == false {
            localPlayer.authenticateHandler = {(viewController, error) in
                if viewController != nil {
                    println("Fire")
                    self.presentViewController(viewController, animated: true, completion: nil)
                }
                else {
                    println("viewcontroller is nil")
                }
                if error != nil {
                    println("error authenticating local user: \(error.localizedDescription)")
                }
                else {
                    println("dismissing.")
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        println("Finished Logging In. View Controller exit.")
                    })
                }
            }
        }
        else {
            println("no error")
            self.presentViewController(matchRequestVC, animated: true, completion: { () -> Void in
                
                /*
                var localPlayer = CGLocalPlayer.localPlayer()
                localPlayer.authenticationHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
                //handle authentication
                }
                
                localPlayer.authenticateHandler  =
                ^(UIViewController *viewController, NSError *error) {
                //3
                [self setLastError:error];
                
                if(viewController != nil) {
                //4
                [self setAuthenticationViewController:viewController];
                } else if([GKLocalPlayer localPlayer].isAuthenticated) {
                //5
                _enableGameCenter = YES;
                } else {
                //6
                _enableGameCenter = NO;
                }
                };
                */
            })
        }

        
    }
    //must implement 4 following methods:
    
    // The user has cancelled
    func turnBasedMatchmakerViewControllerWasCancelled(viewController: GKTurnBasedMatchmakerViewController!) {
        //for when user presses join, but then cancels.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Matchmaking has failed with an error
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, didFailWithError error: NSError!) {
        println("Error finding match: \(error.localizedDescription)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // A turned-based match has been found, the game should start
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, didFindMatch match: GKTurnBasedMatch!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //now pass reference of match onto game view controller.

        var holdemView = self.storyboard.instantiateViewControllerWithIdentifier("holdemView") as HoldemViewController
        
        holdemView.gameController.match = match
        if self.navigationController != nil {
            self.navigationController.pushViewController(holdemView, animated: true)
        }
    }
    
    // Called when a users chooses to quit a match and that player has the current turn.  The developer should call playerQuitInTurnWithOutcome:nextPlayer:matchData:completionHandler: on the match passing in appropriate values.  They can also update matchOutcome for other players as appropriate.
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController!, playerQuitForMatch match: GKTurnBasedMatch!) {
        //player should be eliminated.
        println("Player quit match")
    }

}

