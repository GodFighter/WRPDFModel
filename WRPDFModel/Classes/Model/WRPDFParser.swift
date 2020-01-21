//
//  WRPDFParser.swift
//  Pods
//
//  Created by 项辉 on 2020/1/15.
//
/*
 ObjectType is enum of:
   Null
   Boolean
   Integer
   Real
   Name
   String
   Array
   Dictionary
*/


var nodes : [WRPDFNode] = [WRPDFNode]()

func parsePDF(key: UnsafePointer<Int8>, object: CGPDFObjectRef) -> WRPDFNode? {
    
    let keyString = String(cString: UnsafePointer<CChar>(key), encoding: .isoLatin1)
        
    guard let name = keyString else {
        return nil
    }
    
    return WRPDFNode(object: object, name: name)
}

func parseDictionary(_ dictionary: CGPDFDictionaryRef) -> [WRPDFNode] {
    nodes = [WRPDFNode]()
    
    CGPDFDictionaryApplyFunction(dictionary, { (key, object, info) in
        guard let node = parsePDF(key: key, object: object) else {
            return
        }
        nodes.append(node)
    }, nil)
    
    return nodes
}


var pdfInfoDictionary = Dictionary<String, Any>()
func parseInfo(_ info: CGPDFDictionaryRef) -> Dictionary<String, Any> {
    pdfInfoDictionary = Dictionary<String, Any>()
    
    CGPDFDictionaryApplyFunction(info, { (key, object, info) in
        let keyString = String(cString: UnsafePointer<CChar>(key), encoding: .isoLatin1)
        
        let objectType = CGPDFObjectGetType(object)
        if let name = keyString, objectType == .string {
            var ptrObjectValue:UnsafePointer<Int8>? = nil
            _ = CGPDFObjectGetValue(object, objectType, &ptrObjectValue)
            let value = CGPDFStringCopyTextString(OpaquePointer(ptrObjectValue!))
            pdfInfoDictionary[name] = value
        }
    }, nil)
    
    return pdfInfoDictionary
}

func parsePage(_ pageInfo: CGPDFDictionaryRef) {
    CGPDFDictionaryApplyFunction(pageInfo, { (key, object, info) in
        let keyString = String(cString: UnsafePointer<CChar>(key), encoding: .isoLatin1)
        if keyString == "Resources" {
            var dict : CGPDFDictionaryRef? = nil

            CGPDFObjectGetValue(object, .dictionary, &dict)
            parsePage(dict!)
        }
        
    }, nil)
}

func parseArray(_ object: CGPDFObjectRef) -> [WRPDFNode] {
    nodes = [WRPDFNode]()

    var emptyArray : CGPDFArrayRef?
    CGPDFObjectGetValue(object, .array, &emptyArray)
    guard let array = emptyArray else {
        return nodes
    }
    let count = CGPDFArrayGetCount(array)
    for i in 0..<count {
        var obj : CGPDFObjectRef? = nil
        CGPDFArrayGetObject(array, i, &obj)
        if obj != nil {
            let node = WRPDFNode(object: obj!, name: "\(i)")
            nodes.append(node)
        }
    }

    return nodes
}

func parseStream(_ stream: CGPDFStreamRef) -> [WRPDFNode] {
    nodes = [WRPDFNode]()
    let dict = CGPDFStreamGetDictionary(stream)
    if let dictionary = dict {
        nodes = parseDictionary(dictionary)
    }
    return nodes
    
//    var objectStream:CGPDFStreamRef? = nil
//    if (CGPDFObjectGetValue(stream, .stream, &objectStream)) {
//        let _: CGPDFDictionaryRef = CGPDFStreamGetDictionary( objectStream! )!
//        var fmt: CGPDFDataFormat = .raw
//        let streamData: CFData = CGPDFStreamCopyData(objectStream!, &fmt)!;
//        let data = NSData(data: streamData as Data)
//        let dataString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
//        print("data stream (length=\(CFDataGetLength(streamData))):")
//
//    }
}

