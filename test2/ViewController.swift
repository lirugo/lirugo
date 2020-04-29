//
//  ViewController.swift
//  test2
//
//  Created by user on 3/30/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    var testUIView:TestUIView!
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
            testUIView = TestUIView(frame: UIScreen.main.bounds)

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
    
        // Get the pixel buffer width and height
        var width = CVPixelBufferGetWidth(imageBuffer!);
        var height = CVPixelBufferGetHeight(imageBuffer!);

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
        
        let xTL = 0
        let yTL = 0
        let detectedTL = isGreenXY(xTL, yTL, output, bytesPerRow)
        
        let xTR = Int(width)-Int(Double(width)/3.3)
        let yTR = Int(height)-Int(Double(height)/1.28)
        let detectedTR = isGreenXY(xTR, yTR, output, bytesPerRow)
        
        let xBR = 0
        let yBR = 0
        let detectedBR = isGreenXY(xBR, yBR, output, bytesPerRow)
        
        let xBL = 0
        let yBL = 0
        let detectedBL = isGreenXY(xBL, yBL, output, bytesPerRow)
        
        
        free(myPixelBuf)
        
        DispatchQueue.main.async {
            self.testUIView.detectedTL = detectedTL
            self.testUIView.detectedTR = detectedTR
            self.testUIView.detectedBR = detectedBR
            self.testUIView.detectedBL = detectedBL
            self.testUIView.setNeedsDisplay()
        }
    }
    
    func isGreenXY(_ x:Int,_ y:Int,_ output:Array<UInt8>,_ bytesPerRow:Int) -> Bool{
        var rgb:Utils.RGB = Utils.RGB(r:0, g:0, b:0);
        rgb.b = (output[(x*4)+(y*bytesPerRow)]);
        rgb.g = (output[((x*4)+(y*bytesPerRow))+1]);
        rgb.r = (output[((x*4)+(y*bytesPerRow))+2]);
        
        var hsv:Utils.HSV = Utils.HSV(h:0.0, s:0.0, v:0.0);
        hsv = Utils.rgb2hsv(rgb: rgb)
        
        return isGreen(hsv)
    }
    
    func isGreen(_ hsv: Utils.HSV) -> Bool {
        if (
            hsv.h > 70 && hsv.h < 160 &&
            hsv.s >= 0.50 && hsv.v >= 0.30
        ){
            return true
        }else{
            return false
        }
    }

}
