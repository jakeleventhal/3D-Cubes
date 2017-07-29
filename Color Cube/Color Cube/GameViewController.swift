//
//  GameViewController.swift
//  Color Cube
//
//  Created by Jake Leventhal on 6/24/17.
//  Copyright © 2017 Jake Leventhal. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import FirebaseDatabase

class GameViewController: UIViewController {
	
	let faces = ["front", "right", "back", "left", "top", "bottom"]
	
	var ref:DatabaseReference?
	var databaseHandle:DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set the Firebase reference
		ref = Database.database().reference()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/MainScene.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // top light
        let lightNode1 = SCNNode()
        lightNode1.light = SCNLight()
        lightNode1.light!.type = .omni
		lightNode1.light!.intensity = 1750
        lightNode1.position = SCNVector3(x: 7, y: 7, z: 7)
        scene.rootNode.addChildNode(lightNode1)
		
		// create and add a light to the bottom of the scene
		let lightNode2 = SCNNode()
		lightNode2.light = SCNLight()
		lightNode2.light!.type = .omni
		lightNode2.light!.intensity = 1750
		lightNode2.position = SCNVector3(x: -7, y: -7, z: -7)
		scene.rootNode.addChildNode(lightNode2)
		
		// retrieve the cube
		let cube = scene.rootNode.childNode(withName: "cube", recursively: true)
		
		// create and configure a material for each face
		var materials: [SCNMaterial] = Array()
		for _ in 0...5
		{
			materials.append(SCNMaterial())
		}

		// Retrieve the posts and listen for additions
		databaseHandle = ref?.child("faces").observe(.childAdded, with: {(snapshot) in
			// Code to execute when a child is added under "Posts"
			
			// Retrieve the post
			let key = snapshot.key
			let value = snapshot.value as? Int
			
			if value == 0 {
				materials[self.faces.index(of: key)!].diffuse.contents = UIColor.red
			}
			else {
				materials[self.faces.index(of: key)!].diffuse.contents = UIColor.yellow
			}
		})
		
		// set the material to the 3d object geometry
		cube?.geometry?.materials = materials
		
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
		
		// Retrieve the posts and listen for changes
		databaseHandle = ref?.child("faces").observe(.childChanged, with: {(snapshot) in
			// Code to execute when a child is added under "faces"
			
			// Retrieve the post
			let key = snapshot.key
			let value = snapshot.value as? Int
			
			if value == 0 {
				cube?.geometry?.materials[self.faces.index(of: key)!].diffuse.contents = UIColor.red
			}
			else {
				cube?.geometry?.materials[self.faces.index(of: key)!].diffuse.contents = UIColor.yellow
			}
		})
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
		
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.materials[result.geometryIndex]
			
			// changing the color and posting to Firebase
			ref?.child("faces/" + faces[result.geometryIndex]).observeSingleEvent(of: .value, with: {(snapshot) in
				let value = snapshot.value as? Int
				if value == 0 {
					self.ref?.child("faces").child(self.faces[result.geometryIndex]).setValue(1)
					material.diffuse.contents = UIColor.yellow
				}
				else if value == 1 {
					self.ref?.child("faces").child(self.faces[result.geometryIndex]).setValue(0)
					material.diffuse.contents = UIColor.red
				}
			})
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
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
}
