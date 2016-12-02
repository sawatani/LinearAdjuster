//
//  MtrixView.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 12/1/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Cocoa

class MtrixView: NSView {
    private let unit = CGFloat(100.0)
    private var currentState = ViewState.identity

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        NSColor.white.setFill()
        NSRectFill(bounds)
        
        if let layer = self.layer {
            currentState.transform(layer: layer)
        }
        
        let startX = dirtyRect.minX
        let startY = dirtyRect.minY
        let endX = dirtyRect.maxX
        let endY = dirtyRect.maxY
        
        for i in 0...Int(dirtyRect.width / unit) {
            let x = CGFloat(i) * unit
            let path = NSBezierPath()
            path.move(to: NSPoint(x: x, y: startY))
            path.line(to: NSPoint(x: x, y: endY))
            path.lineWidth = 1
            path.stroke()
        }
        for i in 0...Int(dirtyRect.height / unit) {
            let y = CGFloat(i) * unit
            let path = NSBezierPath()
            path.move(to: NSPoint(x: startX, y: y))
            path.line(to: NSPoint(x: endX, y: y))
            path.lineWidth = 1
            path.stroke()
        }
    }
    
    func update(viewState: ViewState) {
        currentState = viewState
        needsDisplay = true
    }
}
