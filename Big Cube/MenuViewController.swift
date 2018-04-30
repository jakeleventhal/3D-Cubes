//
//  MenuViewController.swift
//  Big Cube
//
//  Created by Jake Leventhal on 4/30/18.
//  Copyright © 2018 Jake Leventhal. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

	@IBAction func dismissMenu(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
