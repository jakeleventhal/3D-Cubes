//
//  GameViewController.swift
//  Layered Cube
//
//  Created by Jake Leventhal on 6/24/17.
//  Copyright © 2017 Jake Leventhal. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import FirebaseDatabase

class GameViewController: UIViewController {
	
	var ref:DatabaseReference?
	var databaseHandle:DatabaseHandle?
	var scene:SCNScene = SCNScene(named: "art.scnassets/MainScene.scn")!
	var faces:Dictionary<String,Int> = [String: Int]()
	var nodeFaces = [SCNNode]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set the Firebase reference
		ref = Database.database().reference()
		
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
		
		// create the dictionary to store face values
		var faces = [String: Int]()
		
		// add the faces to the cube
		initializeFaces()
		
		// retrieve the posts
		databaseHandle = ref?.child("faces").observe(.childAdded, with: {(snapshot) in
			let key = snapshot.key
			let value = snapshot.value as? Int
			
			faces[key] = value
			
			if value == 0 {
				if let nodeToDelete = self.scene.rootNode.childNode(withName: key, recursively: true) {
					self.deleteNode(node: nodeToDelete)
					self.nodeFaces = self.nodeFaces.filter {$0 != nodeToDelete}
					if self.nodeFaces.count == 0 {
						self.resetCube()
					}
				}
			}
		})
		
		// listen for updates
		databaseHandle = ref?.child("faces").observe(.childChanged, with: {(snapshot) in
			// Code to execute when a child is added under "faces"
			
			// Retrieve the post
			let key = snapshot.key
			let value = snapshot.value as? Int
			
			if value == 0 {
				if let nodeToDelete = self.scene.rootNode.childNode(withName: key, recursively: true) {
					self.deleteNode(node: nodeToDelete)
					self.nodeFaces = self.nodeFaces.filter {$0 != nodeToDelete}
					if self.nodeFaces.count == 0 {
						self.resetCube()
					}
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
		addTopFace()
		addBottomFace()
		addFrontFace()
		addBackFace()
		addLeftFace()
		addRightFace()
	}
	
	func addTopFace() {
		// add the top face
		let topFace = SCNBox(width: 10, height: 1, length: 10, chamferRadius: 0.0)
		let topFaceNode = SCNNode(geometry: topFace)
		topFaceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
		topFaceNode.position = SCNVector3(x: 0, y: 5.6, z: 0)
		topFaceNode.name = "top"
		scene.rootNode.addChildNode(topFaceNode)
		nodeFaces.append(topFaceNode)
	}
	
	func addBottomFace() {
		let bottomFace = SCNBox(width: 10, height: 1, length: 10, chamferRadius: 0.0)
		let bottomFaceNode = SCNNode(geometry: bottomFace)
		bottomFaceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
		bottomFaceNode.position = SCNVector3(x: 0, y: -5.6, z: 0)
		bottomFaceNode.name = "bottom"
		scene.rootNode.addChildNode(bottomFaceNode)
		nodeFaces.append(bottomFaceNode)
	}
	
	func addFrontFace() {
		// add the front face
		let frontFace = SCNBox(width: 10, height: 10, length: 1, chamferRadius: 0.0)
		let frontFaceNode = SCNNode(geometry: frontFace)
		frontFaceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
		frontFaceNode.position = SCNVector3(x: 0, y: 0, z: 5.6)
		frontFaceNode.name = "front"
		scene.rootNode.addChildNode(frontFaceNode)
		nodeFaces.append(frontFaceNode)
	}
	
	func addBackFace() {
		// add the back face
		let backFace = SCNBox(width: 10, height: 10, length: 1, chamferRadius: 0.0)
		let backFaceNode = SCNNode(geometry: backFace)
		backFaceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
		backFaceNode.position = SCNVector3(x: 0, y: 0, z: -5.6)
		backFaceNode.name = "back"
		scene.rootNode.addChildNode(backFaceNode)
		nodeFaces.append(backFaceNode)
	}
	
	func addLeftFace() {
		// add the left face
		let leftFace = SCNBox(width: 1, height: 10, length: 10, chamferRadius: 0.0)
		let leftFaceNode = SCNNode(geometry: leftFace)
		leftFaceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
		leftFaceNode.position = SCNVector3(x: -5.6, y: 0, z: 0)
		leftFaceNode.name = "left"
		scene.rootNode.addChildNode(leftFaceNode)
		nodeFaces.append(leftFaceNode)
	}
	
	func addRightFace() {
		// add the right face
		let rightFace = SCNBox(width: 1, height: 10, length: 10, chamferRadius: 0.0)
		let rightFaceNode = SCNNode(geometry: rightFace)
		rightFaceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
		rightFaceNode.position = SCNVector3(x: 5.6, y: 0, z: 0)
		rightFaceNode.name = "right"
		scene.rootNode.addChildNode(rightFaceNode)
		nodeFaces.append(rightFaceNode)
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
	
	func deleteNode(node: SCNNode) {
		node.removeFromParentNode()
	}
	
	func resetCube() {
		self.initializeFaces()
		faces["top"] = 1
		self.ref?.child("faces").child("top").setValue(1)
		faces["bottom"] = 1
		self.ref?.child("faces").child("bottom").setValue(1)
		faces["front"] = 1
		self.ref?.child("faces").child("front").setValue(1)
		faces["back"] = 1
		self.ref?.child("faces").child("back").setValue(1)
		faces["left"] = 1
		self.ref?.child("faces").child("left").setValue(1)
		faces["right"] = 1
		self.ref?.child("faces").child("right").setValue(1)
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
			ref?.child("faces/" + result.node.name!).observeSingleEvent(of: .value, with: {(snapshot) in
				
				// Retrieve the post
				let key = snapshot.key
				let value = snapshot.value as? Int
				
				if value == 1 {
					self.ref?.child("faces").child(result.node.name!).setValue(0)
					if let nodeToDelete = self.scene.rootNode.childNode(withName: key, recursively: true) {
						self.nodeFaces = self.nodeFaces.filter {$0 != nodeToDelete}
						if self.nodeFaces.count == 0 {
							self.resetCube()
						}
						else {
							self.deleteNode(node: nodeToDelete)
						}
					}
				}
			})
		}
	}
}
