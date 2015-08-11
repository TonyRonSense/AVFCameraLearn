//
//  TRCameraController.swift
//  CameraLearnSwift
//
//  Created by taoran on 15/8/11.
//  Copyright (c) 2015年 taoran. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
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
    var containerView : UIView
    var imageAccpetView : UIImageView
    var acceptButton : UIButton
    var declineButton : UIButton
    var previewLayer : AVCaptureVideoPreviewLayer?
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
    var capturedImage : UIImage?
    
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
    
    class func setFlashMode(mode : AVCaptureFlashMode, fordevice device: AVCaptureDevice){
        if device.hasFlash && device.isFlashModeSupported(mode) {
            var error : NSError? = nil
            if( device.lockForConfiguration(&error)) {
                device.flashMode = mode
                device.unlockForConfiguration()
            } else {
                println("Can't configure flash for the error: \(error)")
            }
        }
    }
    // The initiaters
    init(owner : UIViewController, previewView view : UIView) {
        self.ownerController = owner
        self.sessionQueue = dispatch_queue_create("session_queue", DISPATCH_QUEUE_SERIAL)
        self.captuerSession = AVCaptureSession()
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.movieOutput = AVCaptureMovieFileOutput()
        self.videoDataOutput = AVCaptureVideoDataOutput()
        self.containerView = view
        var viewFrame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        self.previewView = UIView(frame: viewFrame)
        self.previewView.backgroundColor = UIColor.blueColor()
        self.imageAccpetView = UIImageView(frame: viewFrame)
        self.acceptButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        self.declineButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        super.init()
        self.videoDataOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
        self.acceptButton.setTitle("√", forState: UIControlState.Normal)
        self.declineButton.setTitle("×", forState: UIControlState.Normal)
        var height = view.frame.height
        var width = view.frame.width
        self.declineButton.frame = CGRectMake(0, height-40, width/2, 40)
        self.acceptButton.frame = CGRectMake(width/2, height-40, width/2, 40)
        self.containerView.addSubview(self.imageAccpetView)
        self.containerView.addSubview(self.acceptButton)
        self.containerView.addSubview(self.declineButton)
        self.containerView.addSubview(self.previewView)
        self.containerView.bringSubviewToFront(self.previewView)
        self.acceptButton.addTarget(self, action: "acceptPic:", forControlEvents: UIControlEvents.TouchUpInside)
        self.declineButton.addTarget(self, action: "declinePic:", forControlEvents: UIControlEvents.TouchUpInside)
        self.setupSession()
        self.startSession()
    }
    
    convenience init(owner : UIViewController, previewFrame frame : CGRect) {
        var previewView = UIView(frame: frame)
        self.init(owner: owner, previewView: previewView)
        
    }
    
    //MARK:- The setups -
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
                    self.previewLayer = previewLayer
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
    //MARK:- Setup Buttons -
    func setTakePictureButtonWithFrame(frame : CGRect?){
        var buttonFrame : CGRect
        if let f = frame {
            buttonFrame = f
        } else {
            buttonFrame = CGRectMake(0, 0, 50, 50)
        }
        var button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = buttonFrame
        button.setTitle("Take Picture", forState: UIControlState.Normal)
        self.setTakePictureButtonWithButton(button)
    }
    
    func setTakePictureButtonWithButton(button : UIButton){
        self.pictureButton = button
        self.pictureButton!.addTarget(self, action: "takePicture:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    //MARK:- The Actions -
    func takePicture(sender : AnyClass) {
        dispatch_async(self.sessionQueue, {
            var connection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
            if let pLayer = self.previewLayer {
                connection.videoOrientation = pLayer.connection.videoOrientation
                TRCameraController.setFlashMode(AVCaptureFlashMode.Auto, fordevice: self.videoInput!.device)
                self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: {
                    (imageDataBuffer, error)->Void in
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                    self.capturedImage = UIImage(data: imageData)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.previewPic(self.capturedImage!)
                    })
                })
            }
        })
    }
    
    func previewPic(image : UIImage){
        self.imageAccpetView.image = image
        self.imageAccpetView.contentMode = UIViewContentMode.Center
        self.imageAccpetView.clipsToBounds = true
//        self.previewView.removeFromSuperview()
        self.containerView.bringSubviewToFront(self.imageAccpetView)
        self.containerView.bringSubviewToFront(self.acceptButton)
        self.containerView.bringSubviewToFront(self.declineButton)
    }
    
    func declinePic(sender : AnyClass){
        dispatch_async(dispatch_get_main_queue(), {
            self.imageAccpetView.image = nil
            self.containerView.bringSubviewToFront(self.previewView)
        })
    }
    
    func acceptPic(sender : AnyClass){
        dispatch_async(self.sessionQueue, {
            PHPhotoLibrary.requestAuthorization({
                (status)->Void in
                if status == PHAuthorizationStatus.Authorized {
                    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromImage(self.capturedImage)
                        }, completionHandler: {
                            (success, error)->Void in
//                            self.capturedImage = nil
                            dispatch_async(dispatch_get_main_queue(), {
//                                self.imageAccpetView.image = nil
                                self.containerView.bringSubviewToFront(self.previewView)
                            })
                            if !success {
                                println("There's an error that: \(error)")
                            }
                    })
                }
            })
        })
    }
}
