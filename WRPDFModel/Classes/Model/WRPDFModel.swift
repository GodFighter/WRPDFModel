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
    fileprivate var stopSearch: Bool = false

    public var document : CGPDFDocument?
    public var outlines : [WROutline] = [WROutline]()
    
    deinit {
        debugPrint("WRPDFModel release")
    }
}

extension WRPDFModel: ParserDelegate {
    public func parser(p: Parser, didParse page: Int, outOf nbPages: Int) {
//        print("parsing \(page) outOf \(nbPages)")
    }

    public func parser(p: Parser, didCompleteWithError error: Error?, cgPDFDocument: CGPDFDocument?) {
//        if let error = error {
//            print(error)
//        }
    }
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
    
    func search(_ text: String, result block:@escaping (Int, [String], Bool) -> ()) {
        
        self.stopSearch = false
        let totalPage = self.document?.numberOfPages ?? 0

        DispatchQueue.global().async { [weak self] in
            
            var currentPage = 0

            while currentPage < totalPage {
                if self?.stopSearch ?? true {
                    DispatchQueue.main.async {
                        block(currentPage, [], true)
                    }
                    break
                }
                guard let strong_self = self else {
                    return
                }

                let lineContents = strong_self.contentOf(page: currentPage)
                
                var results = [String]()
                lineContents.forEach { (lineContent) in
                    if lineContent.contains(text) {
                        results.append(lineContent)
                    }
                }
                DispatchQueue.main.async {
                    block(currentPage, results, currentPage == totalPage)
                }
                currentPage += 1
            }
        }
    }
    
    func searchStop() {
        stopSearch = true
    }
}

//MARK:-  
fileprivate typealias WRPDFModel_Private = WRPDFModel
fileprivate extension WRPDFModel_Private {
    func contentOf(page pageNumber: Int) -> [String] {
        guard let document = self.document else {
            return []
        }

        let documentIndexer = SimpleDocumentIndexer()
        
        let parser = try! Parser(document: document, pageNumber: pageNumber, delegate:self, indexer: documentIndexer, log:false)
        parser.parse()
        
        guard let pageIndex = documentIndexer.pageIndexes[pageNumber] else {
            return []
        }

        var lineContent = [String]()
        for lineCount in 0..<pageIndex.lines.count {
            lineContent.append(pageIndex.lineDescription(lineCount))
        }

        return lineContent
    }
}
