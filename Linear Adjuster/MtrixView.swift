//
//  MtrixView.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 12/1/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Cocoa

class MtrixView: NSView {
    private let mtrix = Mtrix(unitLengthInCM: 10, dims: NSSize(width: 10, height: 6))

    func update(viewState: ViewState) {
        log.debug("Updating \(viewState)")
        if let layer = self.layer {
            let sub = CALayer()
            sub.bounds = NSRect(origin: NSPoint.zero, size: mtrix.canvasSize)
            sub.backgroundColor = NSColor.white.cgColor
            sub.delegate = mtrix
            
            viewState.transform(layer: sub)
            
            layer.sublayers = nil
            layer.addSublayer(sub)
            
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        log.debug("Drawing \(self)")
        
        if let sub = layer?.sublayers?.first {
            sub.position = NSPoint(x: frame.midX, y: frame.midY)
            log.debug("Set layer position: \(sub.position)")
            
            sub.setNeedsDisplay()
        }
    }
}

fileprivate class Mtrix: NSObject, CALayerDelegate {
    let unit: CGFloat
    let canvasSize: NSSize
    
    init(dpi: CGFloat? = nil, unitLengthInCM: CGFloat, dims: NSSize) {
        let cm = (dpi ?? detectScreenDPI().width) / 2.54
        unit = cm * unitLengthInCM
        canvasSize = dims * unit
    }
    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        log.debug("Drawing Mtrix \(self)")
        
        let rect = NSRect(origin: ctx.boundingBoxOfClipPath.origin, size: canvasSize)
        
        let start = NSPoint(x: rect.minX, y: rect.minY)
        let end = NSPoint(x: rect.maxX, y: rect.maxY)
        
        ctx.setLineWidth(1)
        
        for i in 0...Int(rect.width / unit) {
            let x = CGFloat(i) * unit
            ctx.move(to: NSPoint(x: x, y: start.y))
            ctx.addLine(to: NSPoint(x: x, y: end.y))
        }
        for i in 0...Int(rect.height / unit) {
            let y = CGFloat(i) * unit
            ctx.move(to: NSPoint(x: start.x, y: y))
            ctx.addLine(to: NSPoint(x: end.x, y: y))
        }
        ctx.strokePath()
        
        // Center Line
        ctx.setStrokeColor(NSColor.red.cgColor)
        
        ctx.move(to: NSPoint(x: rect.midX, y: start.y))
        ctx.addLine(to: NSPoint(x: rect.midX, y: end.y))
        
        ctx.move(to: NSPoint(x: start.x, y: rect.midY))
        ctx.addLine(to: NSPoint(x: end.x, y: rect.midY))
        
        ctx.strokePath()
    }
}

func detectScreenDPI() -> NSSize {
    let inMM = CGDisplayScreenSize(CGMainDisplayID())
    let pixels = NSSize(
        width: CGDisplayPixelsWide(CGMainDisplayID()),
        height: CGDisplayPixelsHigh(CGMainDisplayID()))
    
    let result = (pixels / inMM) * 25.4
    log.debug("Detected Screen DPI: \(result)")
    return result
}

fileprivate extension NSSize {
    static func /(left: NSSize, right: NSSize) -> NSSize {
        return NSSize(width: left.width / right.width, height: left.height / right.height)
    }
    static func *(left: NSSize, right: CGFloat) -> NSSize {
        return NSSize(width: left.width * right, height: left.height * right)
    }
}
