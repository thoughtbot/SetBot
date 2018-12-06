//
//  ViewController.swift
//  SetBot
//
//  Created by Adam Sharp on 6/12/18.
//  Copyright © 2018 thoughtbot. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
  @IBOutlet var sceneView: ARSCNView!

  override func viewDidLoad() {
    super.viewDidLoad()

    sceneView.delegate = self
    sceneView.session.delegate = self
    sceneView.showsStatistics = true
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let configuration = ARImageTrackingConfiguration()

    if let images = ARReferenceImage.referenceImages(inGroupNamed: "Set Cards", bundle: nil) {
      configuration.trackingImages = images
      sceneView.session.run(configuration)
    } else {
      fatalError("failed to load images")
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    sceneView.session.pause()
  }

  func session(_ session: ARSession, didFailWithError error: Error) {
    print(#function, error)
  }

  func sessionWasInterrupted(_ session: ARSession) {
    print(#function)
  }

  func sessionInterruptionEnded(_ session: ARSession) {
    print(#function)
  }

  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    print(#function, camera.trackingState)
  }

  func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    print(#function, anchors)
  }

  func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    print(#function, anchors)
  }
}
