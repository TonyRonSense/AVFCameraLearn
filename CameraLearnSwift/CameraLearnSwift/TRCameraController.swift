//
//  TRCameraController.swift
//  CameraLearnSwift
//
//  Created by taoran on 15/8/11.
//  Copyright (c) 2015年 taoran. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum CameraSetupResultType : Int {
    case Success = 1
    case Denied, Failed
}

class TRCameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    // The properties
    // The owner
    weak var ownerController : UIViewController?
    // UI contents
    var previewView : UIView
    var pictureButton : UIButton?
    var recordButton : UIButton?
    // Session Management
    var sessionQueue : dispatch_queue_t
    var captuerSession : AVCaptureSession
    var videoInput : AVCaptureDeviceInput?
    var stillImageOutput : AVCaptureStillImageOutput
    var movieOutput : AVCaptureMovieFileOutput
    var videoDataOutput : AVCaptureVideoDataOutput
    // Utilities
    var cameraSetupResult : CameraSetupResultType = CameraSetupResultType.Success
    
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
    
    class func frontCamera()->AVCaptureDevice? {
        return CamViewController.cameraWithPosition(AVCaptureDevicePosition.Front)
    }
    
    class func backCamera()->AVCaptureDevice? {
        return CamViewController.cameraWithPosition(AVCaptureDevicePosition.Back)
    }
    
    class func audioDevice()->AVCaptureDevice? {
        return AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
    }
    // The initiaters
    init(owner : UIViewController, previewView view : UIView) {
        self.ownerController = owner
        self.sessionQueue = dispatch_queue_create("session_queue", DISPATCH_QUEUE_SERIAL)
        self.captuerSession = AVCaptureSession()
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.movieOutput = AVCaptureMovieFileOutput()
        self.videoDataOutput = AVCaptureVideoDataOutput()
        self.previewView = view
        self.previewView.backgroundColor = UIColor.blueColor()
        super.init()
        self.videoDataOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
        self.setupSession()
        self.startSession()
    }
    
    convenience init(owner : UIViewController, previewFrame frame : CGRect) {
        var previewView = UIView(frame: frame)
        self.init(owner: owner, previewView: previewView)
        
    }
    
    // The setups
    func setupSession(){
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .Authorized:
            break
        case .NotDetermined:
            dispatch_suspend(self.sessionQueue)
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
                (granted : Bool)->Void in
                if !(granted) {
                    self.cameraSetupResult = CameraSetupResultType.Denied
                }
                dispatch_resume(self.sessionQueue)
            })
        default:
            self.cameraSetupResult = CameraSetupResultType.Denied
        }
        dispatch_async(self.sessionQueue, {
            if self.cameraSetupResult != CameraSetupResultType.Success {
                return
            }
            var error : NSError? = nil
            var frontCamera =  TRCameraController.frontCamera()
            self.videoInput = AVCaptureDeviceInput(device: frontCamera!, error: &error)
            if self.videoInput == nil {
                print("Open camera error: \(error)\n")
            }
            self.captuerSession.beginConfiguration()
            if self.captuerSession.canAddInput(self.videoInput!) {
                self.captuerSession.addInput(self.videoInput!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    var statusBarOrientation = UIApplication.sharedApplication().statusBarOrientation
                    var initialOrientation = AVCaptureVideoOrientation.Portrait
//                    if statusBarOrientation != UIInterfaceOrientation.Unknown {
//                        initialOrientation = statusBarOrientation as! AVCaptureVideoOrientation
//                    }
                    
                    var previewLayer = AVCaptureVideoPreviewLayer(session: self.captuerSession)
                    previewLayer.connection.videoOrientation = initialOrientation
                    var height = self.previewView.frame.height
                    var width = self.previewView.frame.width
                    previewLayer.frame = CGRectMake(0, 0, width, height)
                    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    self.previewView.layer.addSublayer(previewLayer)
                    self.captuerSession.commitConfiguration()
                })
            }
            
            if self.captuerSession.canAddOutput(self.videoDataOutput) {
                self.captuerSession.addOutput(self.videoDataOutput)
            } else {
                println("Can't add the video data output")
                self.cameraSetupResult = CameraSetupResultType.Failed
            }
            
            if self.captuerSession.canAddOutput(self.stillImageOutput) {
                self.captuerSession.addOutput(self.stillImageOutput)
            } else {
                println("Can't add the still image output")
                self.cameraSetupResult = CameraSetupResultType.Failed
            }
            self.captuerSession.commitConfiguration()
        })
        
    }
    
    func startSession(){
        dispatch_async(self.sessionQueue, {
            switch self.cameraSetupResult {
            case CameraSetupResultType.Success:
                if !self.captuerSession.running {
                    self.captuerSession.startRunning()
                }
            //TODO: - Add the handling mechanism
            case CameraSetupResultType.Denied:
                break
            default:
                break
            }
        })
    }
    
    func stopSession(){
        dispatch_async(self.sessionQueue, {
            if self.cameraSetupResult == CameraSetupResultType.Success {
                if self.captuerSession.running {
                    self.captuerSession.stopRunning()
                }
            }
        })
    }
}
