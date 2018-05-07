//
//  SettingsViewController.swift
//  Big Cube
//
//  Created by Jake Leventhal on 5/5/18.
//  Copyright © 2018 Jake Leventhal. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
	
	@IBAction func back(_ sender: Any) {
		clickSound()
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func musicOption(_ sender: Any) {
	}
	
	@IBAction func breakSoundsOption(_ sender: Any) {
	}
	
	@IBAction func menuSoundsOption(_ sender: Any) {
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
}
