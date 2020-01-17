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
        
        let url = Bundle.main.url(forResource: "投资的常识", withExtension: "pdf")
        
        let model = WRPDFModel(url!)
        
        let outlines = model.outlines
//        let pages = model.pages
        
        print("\(outlines)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

