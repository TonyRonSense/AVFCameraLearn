//
//  HideEyeCameraController.swift
//  CameraLearnSwift
//
//  Created by taoran on 15/8/7.
//  Copyright (c) 2015年 taoran. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol HideEyeCameraDelegate : NSObjectProtocol{
//    optional func getPic();
}

enum CamSetupResult : Int {
    case Success = 1
    case Denied
    case Fail
}

class HideEyeCameraController: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    var ownerController : UIViewController
    weak var cameraDelegate : HideEyeCameraDelegate?
    var captureSession : AVCaptureSession?
    var setupResult : CamSetupResult?
    private var videoCaputureInput : AVCaptureDeviceInput?
    private var movieFileOutput : AVCaptureMovieFileOutput?
    private var stillImageOutput : AVCaptureStillImageOutput?
    private var sessionQueue : dispatch_queue_t
    init(cameraOwner : UIViewController){
        self.ownerController = cameraOwner;
//        self.cameraDelegate = cameraOwner;
        self.captureSession = AVCaptureSession();
        self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        self.setupResult = CamSetupResult.Success
        super.init()
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case AVAuthorizationStatus.Authorized:
            break
        case AVAuthorizationStatus.NotDetermined:
            dispatch_suspend(self.sessionQueue)
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
                (granted : Bool) in
                if !granted {
                    self.setupResult = CamSetupResult.Denied
                }
                dispatch_resume(self.sessionQueue)
            })
        default:
            self.setupResult = CamSetupResult.Denied
        }
    }
}