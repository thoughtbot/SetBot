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
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
  @IBOutlet var overlayView: UIView!
  @IBOutlet var sceneView: ARSCNView!

  override func viewDidLoad() {
    super.viewDidLoad()

    sceneView.delegate = self
    sceneView.session.delegate = self
    sceneView.showsStatistics = true
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let configuration = ARWorldTrackingConfiguration()
    sceneView.session.run(configuration)
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

  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
    do {
      try handler.perform([request])
    } catch {
      print("failed to perform request", error)
    }
  }

  lazy var request: VNDetectRectanglesRequest = {
    let request = VNDetectRectanglesRequest { request, error in
      guard error == nil else {
        print("request failed", error!)
        return
      }
      self.requestCompleted(request as! VNDetectRectanglesRequest)
    }
    request.maximumObservations = 18
    return request
  }()

  func requestCompleted(_ request: VNDetectRectanglesRequest) {
    guard let results = request.results as? [VNRectangleObservation],
      let currentFrame = sceneView.session.currentFrame
      else { return }

    print("detected \(results.count) rectangles")

    let bounds = sceneView.bounds
    let orientation = UIApplication.shared.statusBarOrientation
    let rotateAndCrop = currentFrame.displayTransform(for: orientation, viewportSize: bounds.size)
    let scale = CGAffineTransform(scaleX: bounds.width, y: bounds.height)

    overlayView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

    for result in results {
      let path = UIBezierPath()
      path.move(to: result.bottomLeft.invertingYAxis.applying(rotateAndCrop))
      path.addLine(to: result.topLeft.invertingYAxis.applying(rotateAndCrop))
      path.addLine(to: result.topRight.invertingYAxis.applying(rotateAndCrop))
      path.addLine(to: result.bottomRight.invertingYAxis.applying(rotateAndCrop))
      path.close()
      path.apply(scale)

      let layer = CAShapeLayer()
      layer.fillColor = UIColor.green.cgColor
      layer.path = path.cgPath

      overlayView.layer.addSublayer(layer)
    }
  }
}

extension CGPoint {
  var invertingYAxis: CGPoint {
    return CGPoint(x: x, y: 1 - y)
  }
}
