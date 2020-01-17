//
//  WRPDFModel.swift
//  Pods
//
//  Created by 项辉 on 2020/1/15.
//

import UIKit

public class WRPDFModel {

    public init(_ url : URL) {
        self.url = url
    }
        
    fileprivate var url : URL
    fileprivate var document : CGPDFDocument?
    
    fileprivate var pdfOutlines : [WROutline]?
    fileprivate var pdfPages : [CGPDFObjectRef]?
    
    fileprivate var infos : Dictionary<String, Any>?
    
}

//MARK:-
fileprivate typealias WRPDFModel_Public = WRPDFModel
public extension WRPDFModel_Public {
    var pagesCount : Int {
        let myDocument = CGPDFDocument(self.url as CFURL)
        guard let document = myDocument else {
            return 0
        }
        return document.numberOfPages
    }
    
    var outlines : [WROutline] {
        get {
            if self.pdfOutlines == nil {
                self.pdfOutlines = []
                let myDocument = CGPDFDocument(self.url as CFURL)
                guard let document = myDocument else {
                    return []
                }
                      
                if #available(iOS 11.0, *) {
                    if let outlineDic : NSDictionary = document.outline {
                        if let children = outlineDic["Children"] as? Array<NSDictionary> {
                            self.pdfOutlines = children.map({ (info) -> WROutline in
                                return WROutline.init(info)
                            })
                        }
                    }
                } else {
                    guard let catalog = document.catalog else {
                        return []
                    }

                    let rootNode = WRPDFNode(catalog: catalog)
                    rootNode.child()
                    self.pdfOutlines = rootNode.outlines
                }
            }
            return self.pdfOutlines!
        }
    }
    var pages: [CGPDFObjectRef] {
        get {
            if self.pdfPages == nil {
                let myDocument = CGPDFDocument(self.url as CFURL)
                guard let document = myDocument else {
                    return []
                }
                guard let catalog = document.catalog else {
                    return []
                }

                let rootNode = WRPDFNode(catalog: catalog)
                rootNode.child()

                self.pdfPages = rootNode.pageNodes.filter({ (node) -> Bool in
                    return node.object != nil
                }).map({ (node) -> CGPDFObjectRef in
                    return node.object!
                })
            }
            return self.pdfPages!
        }
    }
    
    var info : Dictionary<String, Any> {
        if self.infos == nil {
            let myDocument = CGPDFDocument(self.url as CFURL)
            self.infos = [:]
            guard let document = myDocument else {
                return self.infos!
            }
            if let pdfInfo = document.info {
                self.infos = parseInfo(pdfInfo)
            }
        }
        return self.infos!
    }

}

//MARK:-  
fileprivate typealias WRPDFModel_Private = WRPDFModel
fileprivate extension WRPDFModel_Private {
}
