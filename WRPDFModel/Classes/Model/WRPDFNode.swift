//
//  WRPDFNode.swift
//  Pods
//
//  Created by 项辉 on 2020/1/15.
//

import UIKit

//MARK:-
public class WROutline: NSObject {
    public var title = ""
    public var page = 0
    public var subOutlines = Array<WROutline>()
    public var isOpen = false
    public var level: Int = -1

    public override init() {
        
    }
    
    public init(_ info: NSDictionary) {
        super.init()
        self.title = info["Title"] as? String ?? ""
        self.page = info["Destination"] as? Int ?? 0
        if let level = info["level"] as? Int, level > 0 {
            self.level = info["level"] as? Int ?? 0
        }
        if let subInfos = info["Children"] as? Array<NSDictionary> {
            self.subOutlines = subInfos.map({ [weak self] (info) -> WROutline in
                let subOutline = WROutline.init(info)
                subOutline.level = (self?.level ?? -1) + 1
                return subOutline
            })
        }
    }    
}

//MARK:-
class WRPDFNode {
    var type: CGPDFObjectType = .dictionary
    var object : CGPDFObjectRef?
    var catalog : CGPDFDictionaryRef?
    var name : String?
    var children = Array<WRPDFNode>()
    
    fileprivate var privateOutlines: Array<WROutline>?
    var outlines: Array<WROutline> {
        get {
            if self.privateOutlines == nil {
                if let outlineNode = self.child(for: "Outlines") {
                    let outlines = self.outlines(from: outlineNode).map { (info) -> NSDictionary in
                        let mutableDic = NSMutableDictionary(dictionary: info)
                        mutableDic["level"] = 1
                        return mutableDic
                    }
                    self.privateOutlines = outlines.map({ (info) -> WROutline in
                        return WROutline.init(info)
                    })
                }
            }
            return self.privateOutlines!
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
            let stringValue = CGPDFStringCopyTextString(OpaquePointer(ptrObjectValue!))

            guard ptrObjectValue != nil else {
                return ""
            }
            return "\(stringValue!)"
            
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
    
    internal func child() {
        if self.children.count > 0 {
            return
        }
        
        switch self.type {
        case .array:
            guard let object = self.object else {
                return
            }
            self.children = parseArray(object)
            
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
            
            self.children = parseDictionary(dictionary)
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
    
    fileprivate func outlines(from parentNode: WRPDFNode) ->  [[String : Any]] {

        parentNode.child()
        let firstNode = parentNode.child(for: "First")
        var outlineNode : WRPDFNode? = firstNode
        
        var pageOutlines = [[String : Any]]()
        
        while outlineNode != nil {
            outlineNode?.child()
            
            var outline = [String : Any]()
            if let title = outlineNode?.child(for: "Title")?.value {
                outline["Title"] = title
            }
            
            let destNode = outlineNode?.child(for: "Dest")
            
            if destNode != nil {
                destNode?.child()

                if destNode!.type == .array, destNode?.children.count ?? 0 > 0 {
                    if let object = destNode?.children.first?.object {
                        outline["Destination"] = self.index(self.pageNodes, object: object)
                    }
                } else if destNode!.type == .name {
                    if let subNode = destNode!.child(for: destNode!.value) {
                        subNode.child()
                        if let grandsonNode = subNode.child(for: "D") {
                            grandsonNode.child()
                            if let object = grandsonNode.children.first?.object {
                                outline["Destination"] = self.index(self.pageNodes, object: object)
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
                                outline["Destination"] = self.index(self.pageNodes, object: object)
                            }
                        }
                    }
                }
            }
                 
            outline["Children"] = self.outlines(from: outlineNode!)
            pageOutlines.append(outline)
            outlineNode = outlineNode?.child(for: "Next")
        }
        return pageOutlines
    }
    

    fileprivate func index(_ pages : Array<WRPDFNode>, object: CGPDFObjectRef) -> Int {
        return 1 + (pages.firstIndex { (node) -> Bool in
            return node.object == object
            } ?? 1)
    }
    
}


