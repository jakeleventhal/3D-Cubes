//
//  SettingsViewController.swift
//  Big Cube
//
//  Created by Jake Leventhal on 5/5/18.
//  Copyright © 2018 Jake Leventhal. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

	@IBOutlet weak var musicSoundsButton: UIButton!
	@IBOutlet weak var breakSoundsButton: UIButton!
	@IBOutlet weak var menuSoundsButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		UIView.performWithoutAnimation {
			musicSoundsButton.setTitle("Music: \(onOrOff(on: musicOn))", for: .normal)
			musicSoundsButton.layoutIfNeeded()
			
			breakSoundsButton.setTitle("Break Sounds: \(onOrOff(on: breakSoundsOn))", for: .normal)
			breakSoundsButton.layoutIfNeeded()
			
			menuSoundsButton.setTitle("Menu Sounds: \(onOrOff(on: menuSoundsOn))", for: .normal)
			menuSoundsButton.layoutIfNeeded()
		}
    }
	
	func onOrOff(on: Bool) -> String{
		if on {
			return "On"
		}
		
		return "Off"
	}
	
	@IBAction func back(_ sender: Any) {
		clickSound()
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func musicOption(_ sender: Any) {
		// change the music button text
		UIView.performWithoutAnimation {
			if musicOn {
				// mute the music player
				musicPlayer.volume = 0
				musicSoundsButton.setTitle("Music: Off", for: .normal)
			} else {
				// unmute the music player
				musicPlayer.volume = 1
				
				musicSoundsButton.setTitle("Music: On", for: .normal)
			}
			
			musicSoundsButton.layoutIfNeeded()
		}
		
		// flip the music option flag
		musicOn = !musicOn
		defaults.setValue(musicOn, forKey: "musicOn")
		
		// play click
		clickSound()
	}
	
	@IBAction func breakSoundsOption(_ sender: Any) {
		// change the break sounds button text
		UIView.performWithoutAnimation {
			if breakSoundsOn {
				breakSoundsButton.setTitle("Break Sounds: Off", for: .normal)
			} else {
				breakSoundsButton.setTitle("Break Sounds: On", for: .normal)
			}
			
			breakSoundsButton.layoutIfNeeded()
		}
		
		// flip the break sounds option flag
		breakSoundsOn = !breakSoundsOn
		defaults.setValue(breakSoundsOn, forKey: "breakSoundsOn")
		
		// play click
		clickSound()
	}
	
	@IBAction func menuSoundsOption(_ sender: Any) {
		// change the menu sounds button text
		UIView.performWithoutAnimation {
			if menuSoundsOn {
				menuSoundsButton.setTitle("Menu Sounds: Off", for: .normal)
			} else {
				menuSoundsButton.setTitle("Menu Sounds: On", for: .normal)
			}
			
			menuSoundsButton.layoutIfNeeded()
		}
		
		// flip the menu sounds option flag
		menuSoundsOn = !menuSoundsOn
		defaults.setValue(menuSoundsOn, forKey: "menuSoundsOn")
		
		// play click
		clickSound()
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
}
