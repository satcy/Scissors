//
//  ScissorSaver.swift
//  Scissors
//
//  Created by satcy on 2015/06/24.
//  Copyright (c) 2015年 satcy. All rights reserved.
//

import Cocoa
import ScreenSaver


func getRandomNumber(Min _Min : Double, Max _Max : Double)->Double {
    
    return ( Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX) ) * (_Max - _Min) + _Min
}


class ScissorSaver : ScreenSaverView {
    
    class Scissor : NSView{
        
        let PI = 3.1415926535897932384626433832795028841971693993751058
        class LifeLine {
            
            var start: CGPoint = CGPoint(x: 0, y: 0);
            var end: CGPoint = CGPoint(x: 0, y: 0);
            var vec: CGPoint = CGPoint(x: 0, y: 0);
            var alive:Bool = false;
            var color:NSColor = NSColor.whiteColor();
            init(){
                start.x = 0;
                start.y = 0;
            }
        }
        
        
        var lifeLines: Array<LifeLine> = Array()
        
        let SPEED = getRandomNumber(Min: 3.0, Max: 9.0)
        var GEN_NUM = UInt32(getRandomNumber(Min: 1.0, Max: 7.0))
        let MAX_NUM = UInt32(getRandomNumber(Min: 100.0, Max: 500.0))
        
        dynamic var cnt: UInt32 = 0 {
            didSet {
                self.needsDisplay = true
            }
        }
        
        required override init(frame: NSRect) {
            super.init(frame: frame)
            generate()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func drawRect(dirtyRect: NSRect){
            super.drawRect(dirtyRect)
            NSColor(calibratedRed: 0.05, green: 0.05, blue: 0.05, alpha: 1).set()
            NSRectFill(dirtyRect)
            
            
            NSColor(calibratedRed: 0.4, green: 0.4, blue: 0.4, alpha: 1).set()
            let figure = NSBezierPath() // container for line(s)
            
            
            
            
            let num = lifeLines.count
            if ( num > 0 ) {
                for i in 0...(num-1) {
                    var line = lifeLines[i];
                    figure.moveToPoint(line.start) // start point
                    figure.lineToPoint(line.end) // destination
                    
                }
            }
            figure.lineWidth = 0.8
            figure.stroke()
            
        }
        
        func update(){
            if ( arc4random_uniform(10) < 1 ) {
                addSeed(CGFloat(arc4random_uniform(UInt32(self.frame.width))),
                    y: CGFloat(arc4random_uniform(UInt32(self.frame.height))) )
            }
            
            let num = lifeLines.count
            if ( num > 0 ) {
                for i in 0...(num-1) {
                    var line = lifeLines[i];
                    
                    if ( line.alive ) {
                        var pre = CGPoint(x: line.end.x, y: line.end.y)
                        line.end.x += line.vec.x
                        line.end.y += line.vec.y
                        for j in 0...(num-1) {
                            if ( i != j ) {
                                var line2 = lifeLines[j]
                                if ( crossLine(pre, b: line.end, c: line2.start, d: line2.end) ) {
                                    var cross = crossLinePoint(pre, b: line.end, c: line2.start, d: line2.end)
                                    if ( cross != nil ) {
                                        var cross2: CGPoint = cross!
                                        line.end.x = cross2.x
                                        line.end.y = cross2.y
                                    }
                                    line.alive = false
                                    break
                                }
                            }
                        }
                    }
                    
                }
            }
            
            if ( UInt32(num) > MAX_NUM ) {
                generate();
            }
            
            self.needsDisplay = true
        }
        
        func generate(){
            GEN_NUM = UInt32(getRandomNumber(Min: 1.0, Max: 10.0))
            
            lifeLines = Array();
            let w = self.frame.width
            let h = self.frame.height
            let def_pos = [0,0,w,0, w,0,w,h, w,h,0,h, 0,h,0,0]
            for i in 0...3 {
                var line: LifeLine = LifeLine()
                line.start.x = def_pos[i*4];
                line.start.y = def_pos[i*4+1];
                line.end.x = def_pos[i*4+2];
                line.end.y = def_pos[i*4+3];
                
                lifeLines.append(line)
            }
        }
        
        func addSeed(x: CGFloat, y:CGFloat){
            let PI_3 = PI * 2.0 / 3.0
            var r = getRandomNumber(Min: 0.0, Max: PI)
            let speed = SPEED
            let cr = ( GEN_NUM != 1 ) ? PI * 2.0 / Double(GEN_NUM) : PI
            
            for i in 0...GEN_NUM {
                var vec = CGPoint(x: CGFloat(cos(r)*speed), y: CGFloat(sin(r)*speed))
                var line = LifeLine()
                line.start.x = x
                line.start.y = y
                line.end.x = x
                line.end.y = y
                line.vec = vec
                line.alive = true
                lifeLines.append(line)
                r = r + cr
            }
        }
        
        func crossLine(a: CGPoint, b: CGPoint, c: CGPoint, d:CGPoint) ->Bool{
            
            var a1 = signedTriangle(a, b: b, c: d)
            var a2 = signedTriangle(a, b: b, c: c)
            
            if (!(a1 * a2 < 0.0)) {return false}
            
            var a3 = signedTriangle(c, b: d, c: a);
            var a4 = signedTriangle(c, b: d, c: b);
            
            if(a3 * a4 < 0.0){
                return true
            }
            
            return false
        }
        
        func crossLinePoint(a: CGPoint, b: CGPoint, c: CGPoint, d:CGPoint) ->CGPoint?{
            var bundo = ( b.x - a.x ) * ( d.y - c.y ) - ( b.y - a.y ) * ( d.x - c.x );
            if ( bundo == 0 ) {// heikou
                return nil;
            }
            
            var vectorAC = CGPoint(x: c.x - a.x, y: c.y - a.y );
            var dR = ( ( d.y - c.y ) * vectorAC.x - ( d.x - c.x ) * vectorAC.y ) / bundo;
            var dS = ( ( b.y - a.y ) * vectorAC.x - ( b.x - a.x ) * vectorAC.y ) / bundo;
            
            return CGPoint(x: a.x + dR * ( b.x - a.x ), y: a.y + dR * ( b.y - a.y ));
        }
        
        func containSegment(p: CGPoint, a:CGPoint, b: CGPoint) ->Bool{
            if (a.x != b.x) {    // S is not  vertical
                if a.x <= p.x && p.x <= b.x {return true}
                if a.x >= p.x && p.x >= b.x {return true}
            }
            else {    // S is vertical, so test y  coordinate
                if a.y <= p.y && p.y <= b.y {return true}
                if a.y >= p.y && p.y >= b.y {return true}
            }
            return false
        }
        
        func signedTriangle(a: CGPoint, b: CGPoint, c: CGPoint) ->CGFloat{
            return (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x)
        }
    }
    var arr:Array<Scissor> = []

    var cnt: UInt32 = 0
    
    override init(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        if ( !isPreview ) {
            initialize()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func startAnimation() {
        if ( !self.isPreview() ) {
            super.startAnimation()
        }
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
        NSColor(calibratedRed: 0.05, green: 0.05, blue: 0.05, alpha: 1).set()
        
        NSRectFill(rect)
        
        if ( self.isPreview() && arr.count == 0 ) {
            removeAllObjects()
            let w = rect.width
            let h = rect.height
            var scissor = Scissor(frame: NSRect(x:0, y:0, width:w, height:h))
            arr.append(scissor)
            self.addSubview(scissor)
            for i in 0...100 {
                scissor.update()
            }
        }
    }
    
    override func animateOneFrame() {
        loop()
    }
    
    override func hasConfigureSheet() -> Bool {
        return false
    }
    
    override func configureSheet() -> NSWindow? {
        return nil
    }
    
    func initialize(){
        wantsLayer = true
        generate()
    }
    
    func loop(){
        let num = arr.count
        for ( var i=0; i<num; i++ ) {
            for j in 0...3 {
                arr[i].update()
            }
        }
        cnt++;
        if ( cnt > 500 ) {
            cnt = 0
            generate()
        }
    }
    
    func removeAllObjects(){
        let num = arr.count
        for ( var i=0; i<num; i++ ) {
            arr[i].removeFromSuperview()
        }
        arr = []
    }
    
    func generate(){
        let w_num = arc4random_uniform(3) + 1
        let h_num = arc4random_uniform(3 - w_num) + 1
        let w = self.frame.width
        let h = self.frame.height
        //println(w)
        //println(h)
        
        var cw = w / CGFloat(w_num)
        var ch = h / CGFloat(h_num)
        
        removeAllObjects()
        
        for i in 0...(w_num-1) {
            for j in 0...(h_num-1) {
                var scissor = Scissor(frame: NSRect(x:CGFloat(i)*cw + 2.0, y:CGFloat(j)*ch + 2.0, width:cw - 4.0, height:ch - 4.0))
                arr.append(scissor)
                self.addSubview(scissor)
            }
        }
    }
    
}