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
        
//        let page = self.document?.page(at: 30)
//        if let dic = page?.dictionary {
//            parsePage(dic)
//        }
    }
        
    fileprivate var url : URL
    
    fileprivate var pdfOutlines : [WROutline]?
    fileprivate var pdfPages : [CGPDFObjectRef]?
    
    fileprivate var infos : Dictionary<String, Any>?
    
    public var document : CGPDFDocument?

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
            if let pdfOutlines = self.pdfOutlines, pdfOutlines.count > 0 {
                DispatchQueue.main.async {
                    completeBlock(self.pdfOutlines!)
                }
            }
            
            guard let document = self.document else {
                completeBlock([])
                return
            }
            if #available(iOS 11.0, *) {
                if let outlineDic : NSDictionary = document.outline {
                    if let children = outlineDic["Children"] as? Array<NSDictionary> {
                        self.pdfOutlines = children.map({ (info) -> WROutline in
                            return WROutline.init(info)
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
                self.pdfOutlines = rootNode.outlines
            }
            DispatchQueue.main.async {
                completeBlock(self.pdfOutlines!)
            }
        }
    }
    
    var outlines : [WROutline] {
        get {
            return self.pdfOutlines ?? []
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
