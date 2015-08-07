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
        var test = HideEyeCameraController(cameraOwner: self);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

