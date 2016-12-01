//
//  ViewController.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 11/28/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController {
    
    @IBOutlet weak var mtrixView: MtrixView!
    @IBOutlet weak var pdfView: PDFView!
    
    let app: AppDelegate = NSApplication.shared().delegate as! AppDelegate
    
    private var state = ViewState.neutral
    private var preState: ViewState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.autoScales = false
        pdfView.scaleFactor = 1.0
        pdfView.displaysPageBreaks = false

        app.pdfView = pdfView
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func changeState(gesture: NSGestureRecognizer, offset: ViewState) {
        switch gesture.state {
        case .began: preState = state
        case .ended: preState = nil
        default: break
        }
        if let pre = preState {
            mtrixView.update(viewState: pre + offset)
        }
    }
    
    @IBAction func panGesture(_ sender: Any) {
        if let g = sender as? NSPanGestureRecognizer {
            changeState(gesture: g, offset: ViewState(skew: g.translation(in: mtrixView)))
        }
    }
    
    @IBAction func rotationGesture(_ sender: Any) {
        if let g = sender as? NSRotationGestureRecognizer {
            changeState(gesture: g, offset: ViewState(rotationInDegrees: g.rotationInDegrees))
        }
    }
    
    @IBAction func zoomGesture(_ sender: Any) {
        if let g = sender as? NSMagnificationGestureRecognizer {
            changeState(gesture: g, offset: ViewState(zoom: g.magnification))
        }
    }
}

struct ViewState {
    static let neutral = ViewState(zoom: 1, rotationInDegrees: 0, skew: NSPoint(x: 0, y: 0))
    
    init(zoom: CGFloat = 0, rotationInDegrees: CGFloat = 0, skew: NSPoint = NSPoint(x: 0, y: 0)) {
        self.zoom = zoom
        self.rotationInDegrees = rotationInDegrees
        self.skew = skew
    }
    
    let zoom: CGFloat
    let rotationInDegrees: CGFloat
    let skew: NSPoint
}

extension ViewState {
    static func +(left: ViewState, right: ViewState) -> ViewState {
        return ViewState(
            zoom: left.zoom + right.zoom,
            rotationInDegrees: normalize(degrees: left.rotationInDegrees + right.rotationInDegrees),
            skew: left.skew + right.skew)
    }
    
    static func -(left: ViewState, right: ViewState) -> ViewState {
        return ViewState(
            zoom: left.zoom - right.zoom,
            rotationInDegrees: normalize(degrees: left.rotationInDegrees - right.rotationInDegrees),
            skew: left.skew - right.skew)
    }
}

fileprivate func normalize(degrees: CGFloat) -> CGFloat {
    let v = (degrees + 360).truncatingRemainder(dividingBy: 360)
    if 180 < v {
        return v - 360
    } else {
        return v
    }
}

fileprivate extension NSPoint {
    static func +(left: NSPoint, right: NSPoint) -> NSPoint {
        return NSPoint(x: left.x + right.x, y: left.y + right.y)
    }
    static func -(left: NSPoint, right: NSPoint) -> NSPoint {
        return NSPoint(x: left.x - right.x, y: left.y - right.y)
    }
}
