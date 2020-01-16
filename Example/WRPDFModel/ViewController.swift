//
//  ViewController.swift
//  WRPDFModel
//
//  Created by GodFighter on 01/15/2020.
//  Copyright (c) 2020 GodFighter. All rights reserved.
//

import UIKit
import WRPDFModel

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "投资的常识", ofType: "pdf")
        
        let mModel = WRPDFModel(path!)
        
//        print("\(outlines)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

