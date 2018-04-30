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

@available(iOS 11.0, *)
class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
	
	@IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		// set the permissions for Facebook
		facebookLoginButton.delegate = self
		facebookLoginButton.readPermissions = ["email", "public_profile"]
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
						ref.child("users").child(userID).child("score").setValue(0)
					}
				})
				
				// navigate to the game
				self.navigateToGame()
			}
		}
	}
	
	private func navigateToGame() {
		let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
		self.present(newViewController, animated: true, completion: nil)
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
		// TODO: add logic for logging out
	}
}
