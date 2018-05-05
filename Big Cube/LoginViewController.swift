//
//  LoginViewController.swift
//  Big Cube
//
//  Created by Jake Leventhal on 4/20/18.
//  Copyright © 2018 Jake Leventhal. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import AVFoundation

@available(iOS 11.0, *)
class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
	
	@IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
	
	// set up variable for playing the background music
	var backgroundMusicPlayer = AVAudioPlayer()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		// set the permissions for Facebook
		facebookLoginButton.delegate = self
		facebookLoginButton.readPermissions = ["email", "public_profile"]
		
		// start the background music
		playBackgroundMusic()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		// skip the login screen if the user is already logged in
		if FBSDKAccessToken.current() != nil {
			self.perform(#selector(navigateToGame), with: nil, afterDelay: 0.01)
		}
	}
	
	// the function for logging into Facebook
	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
		if error != nil {
			print(error)
			return
		}
		
		// request the basic information
		FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {
			(connection, result, error) in
			if error != nil {
				print("Graph request failed:", error!)
				return
			}
			
			// retrieve the Facebook credential
			let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
			
			Auth.auth().signIn(with: credential) { (user, error) in
				if let error = error {
					print("Error logging in Facebook user to Firebase:", error)
					return
				}
				
				print("Successfully logged in Facebook user:", result ?? "")
				
				// add the user to the database if not already present
				let ref: DatabaseReference = Database.database().reference()
				let userID: String! = Auth.auth().currentUser?.uid
				ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
					if !(snapshot.hasChild(userID)) {
						let databaseUser = ref.child("users").child(userID)
						let authUser = Auth.auth().currentUser!
						
						databaseUser.child("email").setValue(authUser.email)
						databaseUser.child("name").setValue(authUser.displayName)
						databaseUser.child("score").setValue(0)
						databaseUser.child("coins").setValue(0)
						databaseUser.child("cashBalance").setValue(0)
						databaseUser.child("cashTotal").setValue(0)
					}
				})
				
				// navigate to the game
				self.navigateToGame()
			}
		}
	}
	
	func playBackgroundMusic() {
		// get background music
		let backgroundMusic = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Background Music", ofType: "mp3")!)
		
		do {
			// set up audio playback
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
			try AVAudioSession.sharedInstance().setActive(true)
			
			// play the background music
			try self.backgroundMusicPlayer = AVAudioPlayer(contentsOf: backgroundMusic as URL)
			self.backgroundMusicPlayer.numberOfLoops = -1
			self.backgroundMusicPlayer.prepareToPlay()
			self.backgroundMusicPlayer.play()
		} catch {
			print(error)
		}
	}
	
	@IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
	
	@objc private func navigateToGame() {
		let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
		self.present(newViewController, animated: true, completion: nil)
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
		// TODO: add logic for logging out
	}
}
