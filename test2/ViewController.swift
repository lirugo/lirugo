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
    
        // Get the pixel buffer width and height
        var width = CVPixelBufferGetWidth(imageBuffer!);
        var height = CVPixelBufferGetHeight(imageBuffer!);

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
        var rgb:Utils.RGB = Utils.RGB(r:0, g:0, b:0);
        rgb.b = (output[(x*4)+(y*bytesPerRow)]);
        rgb.g = (output[((x*4)+(y*bytesPerRow))+1]);
        rgb.r = (output[((x*4)+(y*bytesPerRow))+2]);
//        print("R " + String(rgb.r) + " G " + String(rgb.g) + " B " + String(rgb.b));

        var hsv:Utils.HSV = Utils.HSV(h:0.0, s:0.0, v:0.0);
        hsv = Utils.rgb2hsv(rgb: rgb);
        
        print(
            "H " + String(round(100*hsv.h)/100) + " S " + String(round(100*hsv.s)/100) + " V " + String(round(100*hsv.v)/100) +
            " || R " + String(rgb.r) + " G " + String(rgb.g) + " B " + String(rgb.b)
        );
        
        
        free(myPixelBuf);
        
    }

}
