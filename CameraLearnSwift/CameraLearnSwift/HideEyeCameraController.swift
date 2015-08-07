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

class HideEyeCameraController: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    var ownerController : UIViewController
    weak var cameraDelegate : HideEyeCameraDelegate?
    var captureSession : AVCaptureSession?
    private var videoCaputureInput : AVCaptureDeviceInput?
    private var movieFileOutput : AVCaptureMovieFileOutput?
    private var stillImageOutput : AVCaptureStillImageOutput?
    private var sessionQueue : dispatch_queue_t?
    init(cameraOwner : UIViewController){
        self.ownerController = cameraOwner;
        super.init()
//        self.cameraDelegate = cameraOwner;
        self.captureSession = AVCaptureSession();
        self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case AVAuthorizationStatus.Authorized:
            break
        case AVAuthorizationStatus.NotDetermined:
            dispatch_suspend(self.sessionQueue!);
        }
    }
}