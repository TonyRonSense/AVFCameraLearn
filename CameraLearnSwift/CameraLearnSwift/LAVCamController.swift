//
//  AVCamController.swift
//  CameraLearnSwift
//
//  Created by taoran on 15/8/10.
//  Copyright (c) 2015年 taoran. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit



class LAVCamController: NSObject {
    var previewLayer : AVCaptureVideoPreviewLayer
    var previewView : UIView?
    var captureSession : AVCaptureSession
    var captureDevice : AVCaptureDevice?
    var deviceInput : AVCaptureDeviceInput
    var stillIamgeOutput : AVCaptureStillImageOutput
    var movieOutput : AVCaptureMovieFileOutput
    weak var ownerController : UIViewController?
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
    init(theOwer owner : UIViewController){
        self.ownerController = owner
        self.captureDevice = LAVCamController.frontDevice()
        self.captureSession = AVCaptureSession()
        self.deviceInput = AVCaptureDeviceInput(device: self.captureDevice!, error: nil)
        self.stillIamgeOutput = AVCaptureStillImageOutput()
        self.movieOutput = AVCaptureMovieFileOutput()
        if self.captureSession.canAddInput(self.deviceInput) {
            self.captureSession.addInput(self.deviceInput)
        }
        if self.captureSession.canAddOutput(self.stillIamgeOutput) {
            self.captureSession.addOutput(self.stillIamgeOutput)
        }
        if self.captureSession.canAddOutput(self.movieOutput) {
            self.captureSession.addOutput(self.movieOutput)
        }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        super.init()
        
        
    }
    convenience init(theOwner owner : UIViewController, andView cameraView : UIView) {
        self.init(theOwer: owner)
        self.previewView = cameraView
        self.setupCameraLayer()
        self.startSession()
    }
    convenience init(theOwner owner : UIViewController, andViewFrame cameraFrame : CGRect) {
        self.init(theOwer: owner)
        self.previewView = UIView(frame: cameraFrame)
        self.setupCameraLayer()
        self.startSession()
    }
    func startSession() {
        if !self.captureSession.running {
            self.captureSession.startRunning()
        }
    }
    func stopSession() {
        if self.captureSession.running {
            self.captureSession.stopRunning()
        }
    }
    func setupCameraLayer(){
        if let view = self.previewView {
            var viewLayer = view.layer
            viewLayer.masksToBounds = true
            var bounds = view.bounds
            self.previewLayer.frame = bounds
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            viewLayer.insertSublayer(self.previewLayer, atIndex: 0)
        }
    }
}
