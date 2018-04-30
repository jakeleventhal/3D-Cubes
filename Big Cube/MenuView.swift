//
//  MenuView.swift
//  Big Cube
//
//  Created by Jake Leventhal on 4/21/18.
//  Copyright © 2018 Jake Leventhal. All rights reserved.
//

import UIKit

class MenuView: UIView {
	
	@IBOutlet var contentView: UIView!
	@IBOutlet weak var tableView: UITableView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		let indexPath:IndexPath = IndexPath(row:0, section:0)
		
		tableView.insertRows(at: [indexPath], with: .left)
	}
}
