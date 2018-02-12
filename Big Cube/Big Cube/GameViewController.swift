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
import FirebaseDatabase

class GameViewController: UIViewController {
	
	// Configuration
	var cubiesPerFace:Double = 100
	
	var ref:DatabaseReference?
	var databaseHandle:DatabaseHandle?
	var scene:SCNScene = SCNScene(named: "art.scnassets/MainScene.scn")!
	var faceNames = ["front", "back", "left", "right", "top", "bottom"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set the Firebase reference
		ref = Database.database().reference()
		
		// add new data to the database (TEMPORARY CALL TO FUNCTION)
		//resetCube()
		
		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 32)
		
		// top light
		let lightNode1 = SCNNode()
		lightNode1.light = SCNLight()
		lightNode1.light!.type = .omni
		lightNode1.light!.intensity = 1750
		lightNode1.position = SCNVector3(x: 10, y: 10, z: 10)
		scene.rootNode.addChildNode(lightNode1)
		
		// create and add a light to the bottom of the scene
		let lightNode2 = SCNNode()
		lightNode2.light = SCNLight()
		lightNode2.light!.type = .omni
		lightNode2.light!.intensity = 1750
		lightNode2.position = SCNVector3(x: -10, y: -10, z: -10)
		scene.rootNode.addChildNode(lightNode2)
		
		// create the base cube
		let cube = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0.0)
		let cubeNode = SCNNode(geometry: cube)
		cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
		cubeNode.position = SCNVector3(x: 0, y: 0, z: 0)
		cubeNode.name = "base"
		scene.rootNode.addChildNode(cubeNode)
		
		// add the faces to the cube
		initializeFaces()
		
		// retrieve the cubies
		databaseHandle = ref?.child("deleted").observe(.childAdded, with: {(snapshot) in
			let key = snapshot.key
			
			if let nodeToDelete = self.scene.rootNode.childNode(withName: key, recursively: true) {
				if self.scene.rootNode.childNodes.count == 4 {
					self.resetCube()
				}
				else {
					nodeToDelete.removeFromParentNode()
				}
			}
		})
		
		// listen for updates
		databaseHandle = ref?.child("remaining").observe(.childRemoved, with: {(snapshot) in
			// Code to execute when a child is added under "faces"
			
			// Retrieve the post
			let key = snapshot.key
			
			
			if let nodeToDelete = self.scene.rootNode.childNode(withName: key, recursively: true) {
				if self.scene.rootNode.childNodes.count == 5 {
					self.resetCube()
				}
				else {
					nodeToDelete.removeFromParentNode()
				}
			}
		})
		
		// retrieve the SCNView
		let scnView = self.view as! SCNView
		
		// set the scene to the view
		scnView.scene = scene
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true
		
		// configure the view
		scnView.backgroundColor = UIColor.lightGray
		
		// add a tap gesture recognizer
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
	}
	
	func initializeFaces() {
		let cubiesPerRow = Int(sqrt(cubiesPerFace))-1
		addTopCubies(size: cubiesPerRow)
		addBottomCubies(size: cubiesPerRow)
		addFrontCubies(size: cubiesPerRow)
		addBackCubies(size: cubiesPerRow)
		addLeftCubies(size: cubiesPerRow)
		addRightCubies(size: cubiesPerRow)
	}
	
	// add cubies to the top face
	func addTopCubies(size: Int) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfBlue()
				cubieNode.position = SCNVector3(x: 4.5 - Float(i), y: 5.6, z: 4.5 - Float(j))
				cubieNode.name = "top " + String(i) + ", " + String(j)
				scene.rootNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the bottom face
	func addBottomCubies(size: Int) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfBlue()
				cubieNode.position = SCNVector3(x: 4.5 - Float(i), y: -5.6, z: 4.5 - Float(j))
				cubieNode.name = "bottom " + String(i) + ", " + String(j)
				scene.rootNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the front face
	func addFrontCubies(size: Int) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfBlue()
				cubieNode.position = SCNVector3(x: 4.5 - Float(i), y: 4.5 - Float(j), z: 5.6)
				cubieNode.name = "front " + String(i) + ", " + String(j)
				scene.rootNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the back face
	func addBackCubies(size: Int) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfBlue()
				cubieNode.position = SCNVector3(x: 4.5 - Float(i), y: 4.5 - Float(j), z: -5.6)
				cubieNode.name = "back " + String(i) + ", " + String(j)
				scene.rootNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the left face
	func addLeftCubies(size: Int) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfBlue()
				cubieNode.position = SCNVector3(x: -5.6, y: 4.5 - Float(i), z: 4.5 - Float(j))
				cubieNode.name = "left " + String(i) + ", " + String(j)
				scene.rootNode.addChildNode(cubieNode)
			}
		}
	}
	
	// add cubies to the right face
	func addRightCubies(size: Int) {
		for i in 0...size {
			for j in 0...size {
				let cubie = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
				let cubieNode = SCNNode(geometry: cubie)
				cubieNode.geometry?.firstMaterial?.diffuse.contents = getRandomShadeOfBlue()
				cubieNode.position = SCNVector3(x: 5.6, y: 4.5 - Float(i), z: 4.5 - Float(j))
				cubieNode.name = "right " + String(i) + ", " + String(j)
				scene.rootNode.addChildNode(cubieNode)
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
	
	func getRandomShadeOfBlue() -> UIColor {
		let randomBlueValue = CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(0.87 - 1) + min(0.87, 1)
		return UIColor(red: 0, green: 0, blue: randomBlueValue, alpha: 1)
	}
	
	func resetCube() {
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
				self.initializeFaces()
				let cubiesPerRow = Int(sqrt(self.cubiesPerFace))-1
				for face in self.faceNames {
					for i in 0...cubiesPerRow {
						for j in 0...cubiesPerRow {
							self.ref?.child("remaining").child(face + " " + String(i) + ", " + String(j)).setValue(1)
						}
					}
				}
				self.ref?.child("deleted").removeValue()
			}
			
			material.emission.contents = UIColor.white
			
			SCNTransaction.commit()
		}
	}
	
	func createExplosion(geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4) {
		let explosion = SCNParticleSystem(named: "BokehParticle.scnp", inDirectory: nil)!
		explosion.emitterShape = geometry
		explosion.birthLocation = .surface
		
		let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
		
		let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z)
		
		let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
		
		scene.addParticleSystem(explosion, transform: transformMatrix)
	}
	
	func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		// retrieve the SCNView
		let scnView = self.view as! SCNView
		
		// check what nodes are tapped
		let p = gestureRecognize.location(in: scnView)
		
		let hitResults = scnView.hitTest(p, options: [:])
		// check that user clicked on at least one object
		if hitResults.count > 0 && hitResults[0].node.name != "base" {
			
			// retrieved the first clicked object
			let result: AnyObject = hitResults[0]
			
			// deleting the face and posting to Firebase
			ref?.child("remaining/" + result.node.name!).observeSingleEvent(of: .value, with: {(snapshot) in
				
				// retrieve the key
				let key = snapshot.key
				
				
				self.ref?.child("remaining").child(result.node.name!).removeValue()
				self.ref?.child("deleted").child(result.node.name!).setValue(1)
				if let nodeToDelete = self.scene.rootNode.childNode(withName: key, recursively: true) {
					if self.scene.rootNode.childNodes.count == 5 {
						self.resetCube()
					}
					else {
						self.createExplosion(geometry: nodeToDelete.geometry!,
											 position: nodeToDelete.presentation.position,
											 rotation: nodeToDelete.presentation.rotation)
						
						nodeToDelete.removeFromParentNode()
					}
				}
			})
		}
	}
}
