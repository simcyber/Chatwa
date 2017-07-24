//
//  ViewController.swift
//  Chatwa iOS
//
//  Created by Javon Davis on 25/05/2017.
//  Copyright © 2017 Chatwa. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import GameKit

class HomeViewController: UIViewController {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    lazy var clickSoundPlayer: AVAudioPlayer? = self.getClickSoundPlayer()
    
    // MARK:- Game Center Variables
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    var score = 0
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    
    // MARK:- Lifecycle 
    
    override func viewWillAppear(_ animated: Bool) {
        loadingIndicator.stopAnimating()
        showNavigationBar(show: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateLocalPlayer()
    }

    // MARK:- IBActions
    
    @IBAction func playButtonClicked(_ sender: Any) {
        playAudio(player: clickSoundPlayer)
        loadingIndicator.startAnimating()
        DataManager.shared.loadRounds(localRounds: fetchLocalRounds(), completion: { success in
            self.loadingIndicator.stopAnimating()
            
            if success {
                self.performSegue(withIdentifier: Constants.SegueIdentifiers.game, sender: self)
            } else {
                self.alert(message: "There was an error with your Internet connection. Only previously loaded levels can be played", handler: { action in
                    self.performSegue(withIdentifier: Constants.SegueIdentifiers.game, sender: self)
                })
            }
            
        })
        
    }

    @IBAction func instructionsButtonClicked(_ sender: Any) {
        playAudio(player: clickSoundPlayer)
        self.present(buildInstructionsAlertContoller(), animated: true, completion: nil)
    }
    
    @IBAction func leadboardButtonClicked(_ sender: Any) {
        playAudio(player: clickSoundPlayer)
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = Constants.LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
    
    // MARK:- Core Data
    
    func fetchLocalRounds() -> [Round] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.coreDataStack.context
        
        let fetchRequest: NSFetchRequest<Round> = Round.fetchRequest()
        
        do {
            let rounds = try context.fetch(fetchRequest)
            
            print("Round count: \(rounds.count)")
            return rounds
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    // MARK:- Alert for instructions
    
    func buildInstructionsAlertContoller() -> UIAlertController{
        
        let alertController = UIAlertController(title: "", message:"", preferredStyle: .alert)
        alertController.view.tintColor = .letterColor // This changes the color of the defined action
        
        let dismissAction = UIAlertAction(title: Constants.StaticText.instructionsDismissText, style: .default, handler: nil)
       
        alertController.addAction(dismissAction)
        
        
        alertController.setValue(textInChalboardSEFont(text: Constants.StaticText.instructionsTitle as NSString, color: .black, size: 24), forKey: "attributedTitle")
        alertController.setValue(textInChalboardSEFont(text: Constants.StaticText.instructionsMessage as NSString, color: .letterColor, size: 12), forKey: "attributedMessage")
        return alertController
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error?.localizedDescription ?? "")
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error?.localizedDescription ?? "")
            }
        }
    }
}

