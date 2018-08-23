//
//  GameViewController.swift
//  Mandelbrot Explorer macOS
//
//  Created by Joseph Utecht on 8/23/18.
//  Copyright © 2018 Joseph Utecht. All rights reserved.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {

    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkViewTemp = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }
        mtkView = mtkViewTemp

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice

        guard let newRenderer = Renderer(mtkView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
    }
    
    override func magnify(with event: NSEvent) {
        let x = Float(event.locationInWindow.x * 2) / Float(mtkView.drawableSize.width)
        let y = Float(event.locationInWindow.y * 2) / Float(mtkView.drawableSize.height)
        renderer.zoom(center: [x, 1 - y], speed: Float(event.magnification))
    }
    
    override func scrollWheel(with event: NSEvent) {
        renderer.pan(pan_x: event.deltaX, pan_y: event.deltaY)
    }
    
    @IBAction func toggle_rotation(_ sender: NSMenuItem) {
        renderer.should_rotate = !renderer.should_rotate
        sender.isEnabled = renderer.should_rotate
    }
}
