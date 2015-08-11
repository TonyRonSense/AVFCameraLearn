//
//  ViewController.swift
//  CameraLearnSwift
//
//  Created by taoran on 15/8/7.
//  Copyright (c) 2015年 taoran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var frame = CGRectMake(0, 100, 320, 320)
//        var camera = LAVCamController(theOwner: self, andViewFrame: frame)
        var camera = TRCameraController(owner: self, previewFrame: frame)
        self.view.addSubview(camera.previewView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

