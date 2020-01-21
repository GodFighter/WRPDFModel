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
        
        self.document = CGPDFDocument(self.url as CFURL)
                
    }
        
    fileprivate var url : URL
    
    fileprivate var pdfPages : [CGPDFObjectRef]?
    
    fileprivate var infos : Dictionary<String, Any>?
    
    public var document : CGPDFDocument?
    public var outlines : [WROutline] = [WROutline]()

}

//MARK:-
fileprivate typealias WRPDFModel_Public = WRPDFModel
public extension WRPDFModel_Public {
    var pagesCount : Int {

        guard let document = self.document else {
            return 0
        }
        return document.numberOfPages
    }
    
    func getOutlines(_ completeBlock: @escaping ([WROutline]) -> ()) {
        let queue = DispatchQueue.global()
        queue.async {
            if self.outlines.count > 0 {
                DispatchQueue.main.async {
                    completeBlock(self.outlines)
                }
            }
            
            guard let document = self.document else {
                completeBlock([])
                return
            }
            if #available(iOS 11.0, *) {
                if let outlineDic : NSDictionary = document.outline {
                    if let children = outlineDic["Children"] as? Array<NSDictionary> {
                        self.outlines = children.map({ (info) -> WROutline in
                            let modifyInfo: NSMutableDictionary = NSMutableDictionary(dictionary: info)
                            modifyInfo["level"] = 1
                            return WROutline.init(modifyInfo)
                        })
                    } else {
                        completeBlock([])
                        return
                    }
                }
            } else {
                guard let catalog = document.catalog else {
                    completeBlock([])
                    return
                }

                let rootNode = WRPDFNode(catalog: catalog)
                rootNode.child()
                self.outlines = rootNode.outlines
            
            }
            DispatchQueue.main.async {
                completeBlock(self.outlines)
            }
        }
    }
    
    var pages: [CGPDFObjectRef] {
        get {
            if self.pdfPages == nil {

                guard let document = self.document else {
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

            self.infos = [:]
            guard let document = self.document else {
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
