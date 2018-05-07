//
//  FriendsViewController.swift
//  Big Cube
//
//  Created by Jake Leventhal on 5/5/18.
//  Copyright © 2018 Jake Leventhal. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// work goes here
    }

	@IBAction func back(_ sender: Any) {
		clickSound()
		self.dismiss(animated: true, completion: nil)
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
}
