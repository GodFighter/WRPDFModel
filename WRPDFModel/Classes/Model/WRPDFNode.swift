//
//  WRPDFNode.swift
//  Pods
//
//  Created by 项辉 on 2020/1/15.
//

import UIKit

//MARK:-
class WROutline: NSObject {
    var title = ""
    var page = 0
    var subOutline = Array<WROutline>()
}

//MARK:-
class WRPDFNode {
    var type: CGPDFObjectType = .dictionary
    var object : CGPDFObjectRef?
    var catalog : CGPDFDictionaryRef?
    var name : String?
    var children = Array<WRPDFNode>()
    
    
    fileprivate var privateOutlines = Array<WROutline>()
    var outlines: Array<WROutline> {
        get {
            if self.privateOutlines.count == 0 {
                if let outlineNode = self.child(for: "Outlines") {
                    self.privateOutlines = self.outlines(from: outlineNode)
                }
            }
            return self.privateOutlines
        }
    }
    
    fileprivate var privatePageNodes = Array<WRPDFNode>()
    var pageNodes : Array<WRPDFNode>{
        get{
            if self.privatePageNodes.count == 0 {
                guard let pagesNode = self.child(for: "Pages") else {
                    return privatePageNodes
                }
                privatePageNodes = self.pageNodes(from: pagesNode)
            }
            return privatePageNodes
        }
    }
    
    var value : String {
        
        guard let object = self.object else {
            return ""
        }
        
        switch self.type {
        case .boolean:
            var boolean = CGPDFBoolean()
            CGPDFObjectGetValue(object, type, &boolean)
            return NSNumber(value: boolean).boolValue ? "true" : "false"
        case .integer:
            var integer = CGPDFInteger()
            CGPDFObjectGetValue(object, type, &integer)
            return "\(integer)"
        case .real:
            var real = CGPDFReal()
            CGPDFObjectGetValue(object, type, &real)
            return "\(real)"
        case .name:
            var ptrObjectValue:UnsafePointer<Int8>? = nil
            _ = CGPDFObjectGetValue(object, type, &ptrObjectValue)
            guard let value = ptrObjectValue else {
                return ""
            }
            return String(cString: UnsafePointer<CChar>(value), encoding: .isoLatin1) ?? ""
        case .string:
            var ptrObjectValue:UnsafePointer<Int8>? = nil
            _ = CGPDFObjectGetValue(object, type, &ptrObjectValue)
            guard let value = ptrObjectValue else {
                return ""
            }
            return String(cString: UnsafePointer<CChar>(value), encoding: .isoLatin1) ?? ""
            
        default:return ""
        }
    }
    
        
    convenience init(catalog : CGPDFDictionaryRef) {
        self.init()
        type = CGPDFObjectType.dictionary
        self.catalog = catalog
    }
    
    convenience init(object: CGPDFObjectRef, name: String) {
        self.init()
        self.object = object
        self.name = name
        self.type = CGPDFObjectGetType(object)
    }
    
    func child(for name: String) -> WRPDFNode? {
        return self.children.first { (node) -> Bool in
            return node.name == name
        }
    }
    
    func child() {
        if self.children.count > 0 {
            return
        }
        
        switch self.type {
        case .array:
            guard let object = self.object else {
                return
            }
            var emptyArray : CGPDFArrayRef?
            CGPDFObjectGetValue(object, .array, &emptyArray)
            guard let array = emptyArray else {
                return
            }
            let count = CGPDFArrayGetCount(array)
            for i in 0..<count {
                var obj : CGPDFObjectRef? = nil
                CGPDFArrayGetObject(array, i, &obj)
                if obj != nil {
                    let node = WRPDFNode(object: obj!, name: "\(i)")
                    self.children.append(node)
                }
            }
            
            break
            
        case .dictionary:
            var dict : CGPDFDictionaryRef? = self.catalog
            if dict == nil {
                guard let object = self.object else {
                    return
                }
                CGPDFObjectGetValue(object, .dictionary, &dict)
            }

            guard let dictionary = dict else {
                return
            }

//                let count = CGPDFDictionaryGetCount(dictionary)
            
            CGPDFDictionaryApplyFunction(dictionary, { (key, object, info) in
                guard let node = parsePDFK(key: key, object: object) else {
                    return
                }
                nodes.append(node)
            }, nil)
            self.children = nodes
            nodes.removeAll()
            break
        case .stream:
            
            break
        default:
            return
        }
    }
        
    fileprivate func pageNodes(from parentNode: WRPDFNode) -> [WRPDFNode] {
        parentNode.child()
        
        guard let kidsNode = parentNode.child(for: "Kids") else {
            return []
        }
        kidsNode.child()
        
        var pages = [WRPDFNode]()
        let _ = kidsNode.children.map { (node) -> WRPDFNode in
            if node.child(for: "Type")?.value == "Pages" {
                let kidsPageNodes = self.pageNodes(from: node)
                pages.append(contentsOf: kidsPageNodes)
            } else {
                pages.append(node)
            }
            return node
        }

        return pages
    }
    
    fileprivate func outlines(from parentNode: WRPDFNode) -> [WROutline] {

        parentNode.child()
        let firstNode = parentNode.child(for: "First")
        var outlineNode : WRPDFNode? = firstNode
        
        var pageOutlines = [WROutline]()
        while outlineNode != nil {
            outlineNode?.child()
            
            let outline = WROutline()
            if let title = outlineNode?.child(for: "Title")?.value {
                outline.title = title
            }
            
            let destNode = outlineNode?.child(for: "Dest")
            
            if destNode != nil {
                destNode?.child()

                if destNode!.type == .array, destNode?.children.count ?? 0 > 0 {
                    if let object = destNode?.children.first?.object {
                        outline.page = self.index(self.pageNodes, object: object)
                    }
                } else if destNode!.type == .name {
                    if let subNode = destNode!.child(for: destNode!.value) {
                        subNode.child()
                        if let grandsonNode = subNode.child(for: "D") {
                            grandsonNode.child()
                            if let object = grandsonNode.children.first?.object {
                                outline.page = self.index(self.pageNodes, object: object)
                            }
                        }
                    }
                }
            } else {
                if let aNode = outlineNode?.child(for: "A") {
                    aNode.child()
                    if let dNode = aNode.child(for: "D") {
                        dNode.child()
                        if let d0Node = dNode.children.first {
                            if d0Node.type == .dictionary, let object = d0Node.object {
                                outline.page = self.index(self.pageNodes, object: object)
                            }
                        }
                    }
                }
            }
                 
            outline.subOutline = self.outlines(from: outlineNode!)
            pageOutlines.append(outline)
            outlineNode = outlineNode?.child(for: "Next")
        }
        return pageOutlines
    }
    

    fileprivate func index(_ pages : Array<WRPDFNode>, object: CGPDFObjectRef) -> Int {
        return pages.firstIndex { (node) -> Bool in
            if node.object == object {
                print("\(node.name)")
            }
            return node.object == object
            } ?? 1
    }
    
}


