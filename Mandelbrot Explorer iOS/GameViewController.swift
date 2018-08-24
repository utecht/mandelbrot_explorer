//
//  GameViewController.swift
//  Mandelbrot Explorer iOS
//
//  Created by Joseph Utecht on 8/23/18.
//  Copyright © 2018 Joseph Utecht. All rights reserved.
//

import UIKit
import MetalKit

// Our iOS specific view controller
class GameViewController: UIViewController {

    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkViewTemp = self.view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }
        mtkView = mtkViewTemp

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }

        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black

        guard let newRenderer = Renderer(mtkView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
    }

    @IBAction func scalePiece(_ gestureRecognizer : UIPinchGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            print(gestureRecognizer.velocity)
            renderer.zoom(center: [0.5, 0.5], speed: Float(gestureRecognizer.velocity / 5))
        }
    }
    
    @IBAction func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: piece)
        renderer.pan(pan_x: (-1 * translation.x) / 100, pan_y: (-1 * translation.y) / 100)
    }
}
