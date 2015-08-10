//
//  CamViewController.swift
//  CameraLearnSwift
//
//  Created by taoran on 15/8/10.
//  Copyright (c) 2015年 taoran. All rights reserved.
//

import UIKit
import AVFoundation

class CamViewController : UIViewController {
    var isSetFrame : Bool = false
    var viewFrame : CGRect?
    var captureSession : AVCaptureSession
    var captureDevice : AVCaptureDevice?
    var deviceInput : AVCaptureDeviceInput
    var stillImageOutput : AVCaptureStillImageOutput
    var previewLayer : AVCaptureVideoPreviewLayer
    init(){
        self.captureSession = AVCaptureSession()
        self.captureDevice = CamViewController.backDevice()
        self.deviceInput = AVCaptureDeviceInput(device: self.captureDevice!, error: nil)
        self.stillImageOutput = AVCaptureStillImageOutput()
        var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.stillImageOutput.outputSettings = outputSettings
        if self.captureSession.canAddInput(self.deviceInput) {
            self.captureSession.addInput(self.deviceInput)
        }
        if self.captureSession.canAddOutput(self.stillImageOutput) {
            self.captureSession.addOutput(self.stillImageOutput)
        }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        super.init(nibName: nil, bundle: nil)

    }
    convenience init(userFrame frame : CGRect) {
        self.init()
        self.isSetFrame = true
        self.viewFrame = frame
        if isSetFrame {
            if let newFrame = self.viewFrame {
                self.view.frame = newFrame
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        self.captureSession = AVCaptureSession()
        self.captureDevice = CamViewController.backDevice()
        self.deviceInput = AVCaptureDeviceInput(device: self.captureDevice!, error: nil)
        self.stillImageOutput = AVCaptureStillImageOutput()
        var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.stillImageOutput.outputSettings = outputSettings
        if self.captureSession.canAddInput(self.deviceInput) {
            self.captureSession.addInput(self.deviceInput)
        }
        if self.captureSession.canAddOutput(self.stillImageOutput) {
            self.captureSession.addOutput(self.stillImageOutput)
        }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupCameraLayer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.captureSession.startRunning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupCameraLayer(){
        if (self.captureDevice == nil) {
            return
        }
        
        var viewLayer = self.view.layer
        viewLayer.masksToBounds = true
        
        var bounds = viewLayer.bounds
        self.previewLayer.frame = bounds
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        viewLayer.insertSublayer(self.previewLayer, below: viewLayer.sublayers[0] as! CALayer)
        
    }
    
    class func cameraWithPosition(position : AVCaptureDevicePosition)-> AVCaptureDevice? {
        var devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for d in devices {
            if d.position == position {
                if let rd = d as? AVCaptureDevice {
                    return rd
                }
            }
        }
        return nil
    }
    
    class func frontDevice()->AVCaptureDevice? {
        return CamViewController.cameraWithPosition(AVCaptureDevicePosition.Front)
    }
    
    class func backDevice()->AVCaptureDevice? {
        return CamViewController.cameraWithPosition(AVCaptureDevicePosition.Back)
    }
}
