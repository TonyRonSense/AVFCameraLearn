//
//  ViewController.swift
//  CameraLearnSwift
//
//  Created by taoran on 15/8/7.
//  Copyright (c) 2015年 taoran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var camera : TRCameraController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var frame = CGRectMake(0, 100, 320, 320)
//        var camera = LAVCamController(theOwner: self, andViewFrame: frame)
        self.camera = TRCameraController(owner: self, previewFrame: frame)
        self.view.addSubview(self.camera!.containerView)
        var buttonFrame = CGRectMake(160-50, 0, 100, 50)
        self.camera!.setTakePictureButtonWithFrame(buttonFrame)
        self.view.addSubview(self.camera!.pictureButton!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let c = self.camera {
            c.startSession()
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let c = self.camera {
            c.stopSession()
        }
    }

}

