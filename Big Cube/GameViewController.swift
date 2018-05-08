//
//  GameViewController.swift
//  Big Cube
//
//  Created by Jake Leventhal on 7/28/17.
//  Copyright © 2017 Jake Leventhal. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Firebase
import FirebaseDatabase
import AVFoundation
import FBSDKCoreKit

// set up Firebase variables for global access
var ref: DatabaseReference = Database.database().reference()
let userID: String! = Auth.auth().currentUser!.uid

class GameViewController: UIViewController {
	// configuration
	let cubiesPerFace: Double = 100
	let numWinningTiles = 17
	
	// set up variables for the scene
	var scene: SCNScene = SCNScene(named: "art.scnassets/MainScene.scn")!
	var cameraNode: SCNNode!
	var cubeNode: SCNNode!
	var rendered = false
	let faceNames = ["front", "back", "left", "right", "top", "bottom"]
	let colorNames = ["blue", "red", "green", "pink"]
	let colors: [String: UIColor] = ["blue": .blue, "red": .red, "green": .green, "pink": .magenta]
	var currentColor: String!
	var nextColor: String!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set the background of the scene
		scene.background.contents = [#imageLiteral(resourceName: "space"), #imageLiteral(resourceName: "space"), #imageLiteral(resourceName: "space"), #imageLiteral(resourceName: "space"), #imageLiteral(resourceName: "space"), #imageLiteral(resourceName: "space")]
		
		// create and add a camera to the scene
		cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.name = "camera"
		scene.rootNode.addChildNode(cameraNode)
		if #available(iOS 11.0, *) {
			self.cameraNode!.camera!.fieldOfView = 179.39
		}
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 32)
		
		// add lights to the scene
		addLights()
		
		// retrieve the SCNView
		let scnView = self.view as! SCNView
		
		// set the scene to the view
		scnView.scene = scene
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = false
		
		// add menu button to the screen
		addMenuButton()
		
		// add a tap gesture recognizer
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
		
		// add a pan gesture recognizer
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		scnView.addGestureRecognizer(panGesture)
		
		// add a zoom gesture recognizer
		if #available(iOS 11.0, *) {
			let zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
			scnView.addGestureRecognizer(zoomGesture)
		}
		
		// add listener for updates
		ref.child("cubies/remaining").observe(.childRemoved, with: { (snapshot) in
			// retrieve the post
			let key = snapshot.key
			
			if let nodeToDelete = self.cubeNode.childNode(withName: key, recursively: true) {
				// remove the cubie from the cube
				nodeToDelete.removeFromParentNode()
				self.createExplosion(geometry: nodeToDelete.geometry!,
									 position: nodeToDelete.presentation.position,
									 rotation: nodeToDelete.presentation.rotation)
				
				// reset the cube if necessary
				if self.cubeNode.childNodes.count == 0 {
					self.resetCube(scatterWinningTiles: false)
				}
			}
		})
		
		ref.child(".info/connected").observe(.value, with: { (snapshot) in
			if let connected = snapshot.value as? Bool, connected {
				print("Connected")
				
				// zoom out
				if #available(iOS 11.0, *) {
					self.cameraNode!.camera!.fieldOfView = 179.39
				}
				
				// remove old cube if it already exists
				if self.rendered {
					self.cubeNode.removeFromParentNode()
				}
				
				// render the new cube
				self.createCube()
				
				// set the rendered flag to true
				self.rendered = true
			} else {
				print("Not connected")
			}
		})
	}
	
	func createCube() {
		ref.child("currentColor").observeSingleEvent(of: .value) { (snapshot) in
			// retrieve the cube colors
			self.currentColor = snapshot.value as? String
			self.getNextColor()
			
			// create the base cube
			let cube = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0.0)
			self.cubeNode = SCNNode(geometry: cube)
			self.cubeNode.geometry?.firstMaterial?.diffuse.contents = self.colors[self.nextColor]
			self.cubeNode.position = SCNVector3(x: 0, y: 0, z: 0)
			self.cubeNode.name = "base"
			self.scene.rootNode.addChildNode(self.cubeNode)
			
			// add the faces to the cube
			self.initializeFaces(cubieColor: self.colors[self.currentColor]!)
			
			// update the state of the cube
			self.retrieveCurrentState()
		}
	}
	
	func getNextColor() {
		var nextColorIndex = colorNames.index(of: currentColor)! + 1
		if nextColorIndex == colorNames.count {
			nextColorIndex = 0
		}
		
		nextColor = colorNames[nextColorIndex]
	}
	
	func addMenuButton() {
		let menuButton = UIButton()
		menuButton.setBackgroundImage(#imageLiteral(resourceName: "menu"), for: UIControlState.normal)
		menuButton.alpha = 0.5
		menuButton.frame = CGRect(x: 12, y: 22, width: 60, height: 60)
		menuButton.layer.cornerRadius = 0.5 * menuButton.bounds.size.width
		menuButton.addTarget(self, action: #selector(buttonReleased(sender:)), for: UIControlEvents.touchUpInside)
		
		view.addSubview(menuButton)
	}
	
	@objc func buttonReleased(sender: UIButton) {
		let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
		newViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
		self.present(newViewController, animated: true, completion: nil)
	}
	
	// retreive the current state of the cube
	func retrieveCurrentState() {
		// retrieve the loaded state of the cube
		ref.child("cubies/deleted").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
			// retrieve all the deleted cubies
			let deletedCubies = (snapshot.value as? [String : AnyObject] ?? [:]).keys
			
			// delete each cubie
			for cubie in deletedCubies {
				if let nodeToDelete = self.cubeNode.childNode(withName: cubie, recursively: true) {
					nodeToDelete.removeFromParentNode()
					
					if self.cubeNode.childNodes.count == 0 {
						self.resetCube(scatterWinningTiles: false)
					}
				}
			}
			
			// fly in when finished
			if #available(iOS 11.0, *) {
				self.flyIn()
			}
		})
	}
	
	// fly in to the cube from far away
	@available(iOS 11.0, *)
	func flyIn() {
		// perform the action in a different thread
		DispatchQueue.global(qos: .background).async {
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 1.25
			self.cameraNode!.camera!.fieldOfView = 75
			SCNTransaction.commit()
		}
	}
	
	// add lights to the scene
	func addLights() {
		// create an array of light positions
		let lightPositions: [SCNVector3] = [SCNVector3(x: -10, y: 10, z: 10),
											SCNVector3(x: 10, y: 10, z: 10),
											SCNVector3(x: 0, y: -10, z: 10)]
		
		// add each light to the scene
		for position in lightPositions {
			let lightNode = SCNNode()
			lightNode.light = SCNLight()
			lightNode.light!.type = .omni
			lightNode.light!.intensity = 600
			lightNode.position = position
			scene.rootNode.addChildNode(lightNode)
		}
	}
	
	// a function to handle pinching
	@available(iOS 11.0, *)
	@objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
		// get the scale of the gesture
		let scale = gestureRecognizer.velocity
		
		// handle beginning and ending the gesture
		switch gestureRecognizer.state {
			case .began:
				break
			case .changed:
				// update the camera scale
				let newScale = (cameraNode?.camera?.fieldOfView)! - CGFloat(scale)
				if newScale >= 20 && newScale <= 115 {
					cameraNode!.camera!.fieldOfView = cameraNode!.camera!.fieldOfView - CGFloat(scale)
				}
			default:
				break
		}
	}
	
	// a function to handle panning
	@objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
		// retrieve the position and angle
		let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
		
		// multiply x and y values by 0.75 to reduce pan sensitivity
		let x = Float(translation.x) * 0.75
		let y = Float(-translation.y) * 0.75
		let anglePan = sqrt(pow(x, 2) + pow(y , 2)) * (Float)(Double.pi) / 180
		
		// update the cube's rotation
		cubeNode.rotation = SCNVector4(x: -y, y: x, z: 0, w: anglePan)
		cubeNode.transform = SCNMatrix4MakeRotation(anglePan, -y, x, 0)

		// if panning ended
		if gestureRecognizer.state == UIGestureRecognizerState.ended {
			let currentPivot = cubeNode.pivot
			let currentPostion = cubeNode.position
			let changePivot = SCNMatrix4Invert(SCNMatrix4MakeRotation(cubeNode.rotation.w, cubeNode.rotation.x, cubeNode.rotation.y, cubeNode.rotation.z))
			
			cubeNode.pivot = SCNMatrix4Mult(changePivot, currentPivot)
			cubeNode.transform = SCNMatrix4Identity
			cubeNode.position = currentPostion
		}
	}
	
	// delete all cubies but one
	func deleteAllButOne() {
		var cubieNodes = cubeNode.childNodes
		
		// don't touch the one remaining cubie
		cubieNodes.removeFirst()
		
		// delete all other cubies
		for nodeToDelete in cubieNodes {
			// animate the explosion
			self.createExplosion(geometry: nodeToDelete.geometry!,
								 position: nodeToDelete.presentation.position,
								 rotation: nodeToDelete.presentation.rotation)
			
			// remove the cubie from the remaining database
			ref.child("cubies/remaining").child(nodeToDelete.name!).removeValue()
			
			// add the cubie to the deleted database
			ref.child("cubies/deleted").child(nodeToDelete.name!).setValue("0")
			
			// remove the node from the screen
			nodeToDelete.removeFromParentNode()
		}
	}
	
	func initializeFaces(cubieColor: UIColor) {
		let cubiesPerRow = Int(sqrt(cubiesPerFace))-1
		addTopCubies(size: cubiesPerRow, color: cubieColor)
		addBottomCubies(size: cubiesPerRow, color: cubieColor)
		addFrontCubies(size: cubiesPerRow, color: cubieColor)
		addBackCubies(size: cubiesPerRow, color: cubieColor)
		addLeftCubies(size: cubiesPerRow, color: cubieColor)
		addRightCubies(size: cubiesPerRow, color: cubieColor)
	}
	
	// add cubies to the top face
	func addTopCubies(size: Int, color: UIColor) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfColor(color: color)
				cubieNode.position = SCNVector3(x: 4.5 - Float(i), y: 5.6, z: 4.5 - Float(j))
				cubieNode.name = "top " + String(i) + ", " + String(j)
				self.cubeNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the bottom face
	func addBottomCubies(size: Int, color: UIColor) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfColor(color: color)
				cubieNode.position = SCNVector3(x: 4.5 - Float(i), y: -5.6, z: 4.5 - Float(j))
				cubieNode.name = "bottom " + String(i) + ", " + String(j)
				cubeNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the front face
	func addFrontCubies(size: Int, color: UIColor) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfColor(color: color)
				cubieNode.position = SCNVector3(x: 4.5 - Float(i), y: 4.5 - Float(j), z: 5.6)
				cubieNode.name = "front " + String(i) + ", " + String(j)
				cubeNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the back face
	func addBackCubies(size: Int, color: UIColor) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfColor(color: color)
				cubieNode.position = SCNVector3(x: 4.5 - Float(i), y: 4.5 - Float(j), z: -5.6)
				cubieNode.name = "back " + String(i) + ", " + String(j)
				cubeNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the left face
	func addLeftCubies(size: Int, color: UIColor) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfColor(color: color)
				cubieNode.position = SCNVector3(x: -5.6, y: 4.5 - Float(i), z: 4.5 - Float(j))
				cubieNode.name = "left " + String(i) + ", " + String(j)
				cubeNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the right face
	func addRightCubies(size: Int, color: UIColor) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfColor(color: color)
				cubieNode.position = SCNVector3(x: 5.6, y: 4.5 - Float(i), z: 4.5 - Float(j))
				cubieNode.name = "right " + String(i) + ", " + String(j)
				cubeNode.addChildNode(cubieNode)
			}
		}
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return .allButUpsideDown
		} else {
			return .all
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Release any cached data, images, etc that aren't in use.
	}
	
	// get a random shade of a color
	func getRandomShadeOfColor(color: UIColor) -> UIColor {
		// generate a random percent change
		var percentChange = CGFloat(arc4random()) / CGFloat(UINT32_MAX) * 12.5
		if drand48() > 0.5 {
			percentChange *= -1
		}
		
		// update RGB values
		let ciColor: CIColor = CIColor(color: color)
		let red = max(min(ciColor.red + percentChange/100, 1.0), 0)
		let blue = max(min(ciColor.blue + percentChange/100, 1.0), 0)
		let green = max(min(ciColor.green + percentChange/100, 1.0), 0)
		
		// return the new color
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
	
	// reset the cube
	func resetCube(scatterWinningTiles: Bool) {
		// highlight the cube
		if let material = scene.rootNode.childNode(withName: "base", recursively: true)?.geometry?.firstMaterial {
			// highlight it
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 0.5
			
			// on completion - unhighlight
			SCNTransaction.completionBlock = {
				SCNTransaction.begin()
				SCNTransaction.animationDuration = 0.5
				
				material.emission.contents = UIColor.black
				
				SCNTransaction.commit()
				self.currentColor = self.nextColor
				self.getNextColor()
				self.cubeNode.geometry?.firstMaterial?.diffuse.contents = self.colors[self.nextColor]
				self.initializeFaces(cubieColor: self.colors[self.currentColor]!)
				let cubiesPerRow = Int(sqrt(self.cubiesPerFace))-1
				
				var cubieNames: [String] = []
				
				// add the cubies to the database
				for face in self.faceNames {
					for i in 0...cubiesPerRow {
						for j in 0...cubiesPerRow {
							let cubieName = face + " " + String(i) + ", " + String(j)
							// add each cubie name to the list of all names
							cubieNames.append(cubieName)
							if (scatterWinningTiles) {
								ref.child("cubies/remaining").child(cubieName).setValue(0)
							}
						}
					}
				}
				ref.child("cubies/deleted").removeValue()
				
				// if scatter should occur
				if (scatterWinningTiles) {
					self.scatterWinningTiles(cubieNames: cubieNames)
				}
				
				ref.child("currentColor").setValue(self.currentColor)
			}
			
			material.emission.contents = UIColor.white
			
			SCNTransaction.commit()
		}
		
	}
	
	// scatter winning tiles throughout the cube
	func scatterWinningTiles(cubieNames: [String]) {
		var cubieNames = cubieNames
		// for each winning tile to place
		for _ in 1...numWinningTiles {
			// get random index of cubie name
			let randomIndex = Int(arc4random_uniform(UInt32(cubieNames.count)))
			
			// get the winner name
			let winnerName = cubieNames[randomIndex]
			
			// update the cash value for that tile
			ref.child("cubies/remaining").child(winnerName).setValue(1)
			
			// remove the winner from the list of all names
			cubieNames.remove(at: randomIndex)
		}
	}
	
	func createExplosion(geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4) {
//		let explosion = SCNParticleSystem(named: "BokehParticle.scnp", inDirectory: "art.scnassets")!
//		explosion.emitterShape = geometry
//		explosion.birthLocation = .surface
//
//		let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
//
//		let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z)
//
//		let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
//
//		scene.addParticleSystem(explosion, transform: transformMatrix)
	}
	
	@objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
		// retrieve the SCNView
		let scnView = self.view as! SCNView
		
		// check what nodes are tapped
		let p = gestureRecognizer.location(in: scnView)
		
		let hitResults = scnView.hitTest(p, options: [:])
		// check that user clicked on at least one object
		if hitResults.count > 0 && hitResults[0].node.name != "base" {
			
			// retrieved the first clicked object
			let result: AnyObject = hitResults[0]
			
			// deleting the face and posting to Firebase
			ref.child("cubies/remaining/" + result.node.name!).observeSingleEvent(of: .value, with: { (snapshot) in
				
				// retrieve the key
				let key = snapshot.key
				
				ref.child("cubies/remaining").child(result.node.name!).removeValue()
				if let nodeToDelete = self.cubeNode.childNode(withName: key, recursively: true) {
					// remove the cubie from the cube
					nodeToDelete.removeFromParentNode()
					self.playBreakSound()
					self.createExplosion(geometry: nodeToDelete.geometry!,
										 position: nodeToDelete.presentation.position,
										 rotation: nodeToDelete.presentation.rotation)
					
					// if cube needs to be reset
					if self.cubeNode.childNodes.count == 0 {
						self.resetCube(scatterWinningTiles: true)
					}
				}
				
				// perform database updates in the background
				DispatchQueue.global(qos: .background).async {
					// retrieve the cash value
					if let cashVal = snapshot.value as? Double {
						// update user's cash if cash cube
						if cashVal > 0 {
							ref.child("users").child(userID!).runTransactionBlock { (currentData: MutableData) -> TransactionResult in
								if var userData = currentData.value as? [String: Any] {
									userData["cashBalance"] = (userData["cashBalance"] as? Int)! + 1
									userData["cashTotal"] = (userData["cashTotal"] as? Int)! + 1
									
									currentData.value = userData
									return TransactionResult.success(withValue: currentData)
								}
								
								return TransactionResult.success(withValue: currentData)
							}
						}
						
						ref.child("cubies/deleted").child(result.node.name!).setValue(cashVal)
					}
					
					// update the user's score
					ref.child("users").child(userID!).runTransactionBlock { (currentData: MutableData) -> TransactionResult in
						if var userData = currentData.value as? [String: Any] {
							userData["score"] = (userData["score"] as? Int)! + 1
							userData["coins"] = (userData["coins"] as? Int)! + 1
							
							currentData.value = userData
							return TransactionResult.success(withValue: currentData)
						}
						
						return TransactionResult.success(withValue: currentData)
					}
				}
			})
		}
	}
	
	func playBreakSound() {
		if breakSoundsOn {
			DispatchQueue.global(qos: .background).async {
				// get break audio sound
				let glassSoundNumber = arc4random_uniform(4) + 1
				let resourceName = "Break \(glassSoundNumber)"
				let breakSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: resourceName, ofType: "mp3")!)
				
				do {
					// set up audio playback
					try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
					try AVAudioSession.sharedInstance().setActive(true)
					
					// play the sound
					try breakSoundPlayer = AVAudioPlayer(contentsOf: breakSound as URL)
					breakSoundPlayer.prepareToPlay()
					breakSoundPlayer.play()
				} catch {
					print(error)
				}
			}
		}
	}
}
