//
//  WRPDFModel.swift
//  Pods
//
//  Created by 项辉 on 2020/1/15.
//

import UIKit

public class WRPDFModel {

    public convenience init(_ path : String) {
        self.init()
        self.path = path
        
        let rootNode = WRPDFParser.paser(url: NSURL(fileURLWithPath: self.path))
        print("\(rootNode?.outlines)")
    }
    
    init() {
        self.path = ""
    }
    
    fileprivate var path : String
    fileprivate var pdfOutlines : [WROutline]?
}

//MARK:-
fileprivate typealias WRPDFModel_Public = WRPDFModel
public extension WRPDFModel_Public {
//    var outlines : [WROutline] {
//        get {
//            if self.pdfOutlines == nil {
//                let rootNode = WRPDFParser.paser(url: NSURL(fileURLWithPath: self.path))
//                self.pdfOutlines = rootNode?.outlines
//            }
//            return self.pdfOutlines!
//        }
//    }
}

//MARK:-  
fileprivate typealias WRPDFModel_Private = WRPDFModel
fileprivate extension WRPDFModel_Private {
}
