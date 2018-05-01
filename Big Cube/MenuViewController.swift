//
//  MenuViewController.swift
//  Big Cube
//
//  Created by Jake Leventhal on 4/30/18.
//  Copyright © 2018 Jake Leventhal. All rights reserved.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController {
	
	var menuSoundPlayer = AVAudioPlayer()
	@IBOutlet weak var closeButton: UIButton!
	
	@IBAction func dismissMenu(_ sender: Any) {
		clickSound()
		self.dismiss(animated: true, completion: nil)
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		clickSound()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func clickSound() {
		let menuSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Blop", ofType: "mp3")!)
		
		do {
			// set up audio playback
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
			try AVAudioSession.sharedInstance().setActive(true)
			
			// play the sound
			try self.menuSoundPlayer = AVAudioPlayer(contentsOf: menuSound as URL)
			self.menuSoundPlayer.prepareToPlay()
			self.menuSoundPlayer.play()
		} catch {
			print(error)
		}
	}
}
