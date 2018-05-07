//
//  LeaderboardsViewController.swift
//  Big Cube
//
//  Created by Jake Leventhal on 5/5/18.
//  Copyright © 2018 Jake Leventhal. All rights reserved.
//

import UIKit

class LeaderboardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	var leaderboardsData: [(String, Int)] = []
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		
		// retrieve the leaderboards
		ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
			// retrieve all the users
			let users = (snapshot.value as? [String : Dictionary<String, AnyObject>] ?? [:])
			
			// add each user to the array of data
			for user in users.values {
				if let name = user["name"] as? String {
					if let score = user["score"] as? Int {
						self.leaderboardsData.append((name, score))
					}
				}
			}
			
			// sort the data by score
			self.leaderboardsData.sort(by: {$0.1 > $1.1})
			
			// refresh the table
			self.tableView.reloadData()
		})
    }
	
	@IBAction func back(_ sender: Any) {
		clickSound()
		self.dismiss(animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return leaderboardsData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardsCell", for: indexPath)
		
		// update the cell's text
		cell.textLabel?.text = "\(indexPath.row + 1). \(leaderboardsData[indexPath.row].0)"
		cell.detailTextLabel?.text = String(leaderboardsData[indexPath.row].1)
		
		return cell
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
}
