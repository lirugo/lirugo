//
//  TestUIView.swift
//  test2
//
//  Created by user on 4/28/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import Foundation

class TestUIView:UIView {
    
    var detectedTL:Bool = false
    var detectedTR:Bool = false
    var detectedBR:Bool = false
    var detectedBL:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        let width = self.bounds.width
        let height = self.bounds.height
        let xLength = Int(width / 8)
        let yLength = Int(height / 14)
        
        drawSideMarker(xLength: xLength, yLength: yLength)
        
        drawAims(xLength: xLength, yLength: yLength)
        
    }
    
    func drawAims(xLength:Int, yLength:Int){
        //Top right
        drawRect(
            x:Int(self.bounds.width)-Int(self.bounds.width/3.3),
            y:Int(self.bounds.height)-Int(self.bounds.height/1.28),
            xLength:xLength, yLength:yLength,
            fill: false,
            color: detectedTR ? UIColor.green : UIColor.red
        )
        //Top left
        drawRect(
            x:Int(self.bounds.width/3.3),
            y:Int(self.bounds.height)-Int(self.bounds.height/1.28),
            xLength:xLength, yLength:yLength,
            fill: false,
            color: detectedTL ? UIColor.green : UIColor.red
        )
        //Bottom right
        drawRect(
            x:Int(self.bounds.width)-Int(self.bounds.width/3.3),
            y:Int(self.bounds.height)-Int(self.bounds.height/3.0),
            xLength:xLength, yLength:yLength,
            fill: false,
            color: detectedBR ? UIColor.green : UIColor.red
        )
        //Bottom left
        drawRect(
            x:Int(self.bounds.width/3.3),
            y:Int(self.bounds.height)-Int(self.bounds.height/3.0),
            xLength:xLength, yLength:yLength,
            fill: false,
            color: detectedBL ? UIColor.green : UIColor.red
        )
    }
    
    func drawSideMarker(xLength:Int, yLength:Int){
        var rect = CGRect(
            x: 0,
            y: 0,
            width: xLength*2,
            height: yLength*2
        )
        var rectPath = UIBezierPath(rect: rect)
        UIColor.green.setFill()
        rectPath.fill()
        
        rect = CGRect(
            x:Int(self.bounds.width)-xLength*2, y:Int(self.bounds.height)-yLength*2,
            width: xLength*2,
            height: yLength*2
        )
        rectPath = UIBezierPath(rect: rect)
        UIColor.green.setFill()
        rectPath.fill()
        
        rect = CGRect(
            x:0, y:Int(self.bounds.height)-yLength*2,
            width: xLength*2,
            height: yLength*2
        )
        rectPath = UIBezierPath(rect: rect)
        UIColor.green.setFill()
        rectPath.fill()
        
        rect = CGRect(
            x:Int(self.bounds.width)-xLength*2, y:0,
            width: xLength*2,
            height: yLength*2
        )
        rectPath = UIBezierPath(rect: rect)
        
        UIColor.green.setFill()
        
        rectPath.fill()
    }
    
    func drawRect(x:Int, y:Int, xLength:Int, yLength:Int, fill:Bool, color: UIColor){
        let rect = CGRect(
            x: x-xLength,
            y: y-yLength,
            width: xLength*2,
            height: yLength*2
        )
        let rectPath = UIBezierPath(rect: rect)
        
        // Fill or No
        if(fill){
            color.setFill();
            rectPath.fill()
        }else {
            color.set();
            rectPath.lineWidth = 3
            rectPath.stroke()
        }
    }
    
    func test(){
////        drawRect(x: 100, y: 100, xLength:10, yLength:10, fill:false, color:UIColor.blue);
//        print("sss")
//
//        var rect = CGRect(
//            x: 100,
//            y: 100,
//            width: 100*2,
//            height: 100*2
//        )
//        var rectPath = UIBezierPath(rect: rect)
////        UIColor.green.setFill()
//        rectPath.fill()
    }
}
