//
//  ViewController.swift
//  test2
//
//  Created by user on 3/30/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import AVFoundation

class TestUIView:UIView {
    
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
        print(self.bounds.width)
        print(self.bounds.height)
        
        let xLength = Int(self.bounds.width / 8)
        let yLength = Int(self.bounds.height / 14)
        
        drawSideMarker(xLength: xLength, yLength: yLength)
        
        drawAim(xLength: xLength, yLength: yLength)
    }
    
    func drawAim(xLength:Int, yLength:Int){
        drawRect(
            x:Int(self.bounds.width)-Int(self.bounds.width/3.3),
            y:Int(self.bounds.height)-Int(self.bounds.height/1.28),
            xLength:xLength, yLength:yLength,
            fill: false
        )
        drawRect(
            x:Int(self.bounds.width/3.3),
            y:Int(self.bounds.height)-Int(self.bounds.height/1.28),
            xLength:xLength, yLength:yLength,
            fill: false
        )
        
        drawRect(
            x:Int(self.bounds.width)-Int(self.bounds.width/3.3),
            y:Int(self.bounds.height)-Int(self.bounds.height/3.0),
            xLength:xLength, yLength:yLength,
            fill: false
        )
        drawRect(
            x:Int(self.bounds.width/3.3),
            y:Int(self.bounds.height)-Int(self.bounds.height/3.0),
            xLength:xLength, yLength:yLength,
            fill: false
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
    
    func drawRect(x:Int, y:Int, xLength:Int, yLength:Int, fill:Bool){
        let rect = CGRect(
            x: x-xLength,
            y: y-yLength,
            width: xLength*2,
            height: yLength*2
        )
        let rectPath = UIBezierPath(rect: rect)
        
        // Fill or No
        if(fill){
            UIColor.green.setFill()
            rectPath.fill()
        }else {
            UIColor.red.set()
            rectPath.lineWidth = 3
            rectPath.stroke()
        }
    }
}

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var testUIView: TestUIView {return self.view as! TestUIView!}
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        if let availableDevices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front
            ).devices as [AVCaptureDevice]? {
            captureDevice = availableDevices.first
            beginSession()
        }
    }
    
    func beginSession(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        }catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) as AVCaptureVideoPreviewLayer?{
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.view.layer.frame
            
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings =
                [
                    (kCVPixelBufferPixelFormatTypeKey as NSString) :
                        NSNumber(value:kCVPixelFormatType_32BGRA)
                ] as [String:Any]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput){
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.lirugo.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
            //Show TestUIView
            let testUIView = TestUIView(frame: UIScreen.main.bounds)
            self.view.addSubview(testUIView)
        }
    }
    
    // Function to capture the frames again and again
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
    }
    
    // Function to process the buffer
    func imageFromSampleBuffer(sampleBuffer : CMSampleBuffer){
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        //CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly);
        
        // Get the number of bytes per row for the pixel buffer
        //let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!);
        
        // Get the number of bytes per row for the pixel buffer
        //let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!);
        
        // Get the pixel buffer width and height
        var width = CVPixelBufferGetWidth(imageBuffer!);
        var height = CVPixelBufferGetHeight(imageBuffer!);
        
        //        print(String(width) + " x " + String(height))
        
        
        let x = width/2;
        let y = height/2;
        let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(cvImageBuffer!,[]);
        var tempAddress = CVPixelBufferGetBaseAddress(cvImageBuffer!);
        let bytesPerRow = CVPixelBufferGetBytesPerRow(cvImageBuffer!);
        width = CVPixelBufferGetWidth(cvImageBuffer!);
        height = CVPixelBufferGetHeight(cvImageBuffer!);
        CVPixelBufferUnlockBaseAddress(cvImageBuffer!,[]);
        let bufferSize = bytesPerRow * height;
        let myPixelBuf = malloc(bufferSize);
        memmove(myPixelBuf, tempAddress, bufferSize);
        tempAddress = nil;
        
        let bTypedPtr = myPixelBuf!.bindMemory(to: UInt8.self, capacity: bufferSize)
        let UInt32Buffer = UnsafeBufferPointer(start: bTypedPtr, count: bufferSize)
        let output = Array(UInt32Buffer)
        
        // remember it's BGRA data
        var rgb:RGB = RGB(r:0.0, g:0.0, b:0.0);
        rgb.b = Float(output[(x*4)+(y*bytesPerRow)]);
        rgb.g = Float(output[((x*4)+(y*bytesPerRow))+1]);
        rgb.r = Float(output[((x*4)+(y*bytesPerRow))+2]);
//        print("R " + String(rgb.r) + " G " + String(rgb.g) + " B " + String(rgb.b));
        
        var hsv:HSV = HSV(h:0.0, s:0.0, v:0.0);
        hsv = rgb2hsv(rgb: RGB(r:191, g:191, b:191));
        
//        print("H " + String(hsv.h) + " S " + String(hsv.s) + " V " + String(hsv.v));
    }
    
    struct RGB {
        var r: Float = 0.0
        var g: Float = 0.0
        var b: Float = 0.0
    }
    
    struct HSV {
        var h: Float = 0.0
        var s: Float = 0.0
        var v: Float = 0.0
    }
    
    func rgb2hsv(rgb: RGB) -> HSV{
        var hsv:HSV = HSV(h:0.0, s:0.0, v:0.0);
        var min:Float, max:Float, delta:Float;
        
        min = rgb.r < rgb.g ? rgb.r : rgb.g;
        min = min  < rgb.b ? min  : rgb.b;
        
        max = rgb.r > rgb.g ? rgb.r : rgb.g;
        max = max  > rgb.b ? max  : rgb.b;
        
        hsv.v = max/255;                                // v
        delta = max - min;
        if (delta < 0.00001)
        {
            hsv.s = 0;
            hsv.h = 0; // undefined, maybe nan?
            return hsv;
        }
        if( max > 0.0 ) { // NOTE: if Max is == 0, this divide would cause a crash
            hsv.s = (delta / max);                  // s
        } else {
            // if max is 0, then r = g = b = 0
            // s = 0, h is undefined
            hsv.s = 0.0;
            hsv.h = 0.0;                            // its now undefined
        }
        if( rgb.r >= max ){                           // > is bogus, just keeps compilor happy
            hsv.h = ( rgb.g - rgb.b ) / delta;        // between yellow & magenta
        }else if( rgb.g >= max ){
            hsv.h = 2.0 + ( rgb.b - rgb.r ) / delta;  // between cyan & yellow
        }else{
            hsv.h = 4.0 + ( rgb.r - rgb.g ) / delta;  // between magenta & cyan
        }
        
        hsv.h *= 60.0;                              // degrees
        
        if( hsv.h < 0.0 ){
            hsv.h += 360.0;
        }
        
        return hsv;
    }
}
