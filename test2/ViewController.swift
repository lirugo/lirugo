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
        let aPath = UIBezierPath()
        
        aPath.move(to: CGPoint(x: 0, y:0))
        aPath.addLine(to: CGPoint(x: 300, y: 300))
        
        // Keep using the method addLine until you get to the one where about to close the path
        aPath.close()
        
        // If you want to stroke it with a red color
        UIColor.green.set()
        aPath.lineWidth = 10
        aPath.stroke()
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
    
//    override func loadView() {
//        self.view = TestUIView(frame: UIScreen.main.bounds)
//        let previewView = TestUIView(frame: self.view.frame)
//        self.view.addSubview(previewView)
//    }
    
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
                    NSNumber(value:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
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
        let width = CVPixelBufferGetWidth(imageBuffer!);
        let height = CVPixelBufferGetHeight(imageBuffer!);
        
        print(String(width) + " x " + String(height))
    }
}
