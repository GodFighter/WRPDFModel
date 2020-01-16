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

class WRPDFParser {

    static func paser(url : NSURL) -> WRPDFNode? {

        let myDocument = CGPDFDocument(url)
        guard let document = myDocument else {
            return nil
        }
//        self.pageCount = document.numberOfPages
        guard let catalog = document.catalog else {
            return nil
        }
        
        let rootNode = WRPDFNode(catalog: catalog)
        rootNode.child()
        
        let pagesNode = rootNode.child(for: "Pages")
        pagesNode?.child()
        
        print("\(rootNode.outlines)")

        
        return rootNode
    }
    
    static func children(for name: String) -> Array<Any> {
        
        return []
    }
    
    func child() -> [WRPDFNode] {
        
        return[]
    }
    
}

var nodes : [WRPDFNode] = [WRPDFNode]()


func parsePDFK(key: UnsafePointer<Int8>, object: CGPDFObjectRef) -> WRPDFNode? {
    
    let keyString = String(cString: UnsafePointer<CChar>(key), encoding: .isoLatin1)
        
    let objectType = CGPDFObjectGetType(object)
    guard let name = keyString else {
        return nil
    }
    if objectType == .string {
        var ptrObjectValue:UnsafePointer<Int8>? = nil
        _ = CGPDFObjectGetValue(object, objectType, &ptrObjectValue)
        let stringValue = CGPDFStringCopyTextString(OpaquePointer(ptrObjectValue!))
        print("String value: \(stringValue!)")
    }
    
    return WRPDFNode(object: object, name: name)

//    var ptrObjectValue:UnsafePointer<Int8>? = nil
//    switch objectType {
//    //   Stream
//    case .boolean:
//        // Boolean
//        var objectBoolean:CGPDFBoolean = 0
//        if CGPDFObjectGetValue(object, objectType, &objectBoolean) {
//            let testbool = NSNumber(value: objectBoolean)
//            print("Boolean value \(testbool)")
//        }
//    case .integer:
//        // Integer
//        var objectInteger:CGPDFInteger? = nil
//        if CGPDFObjectGetValue(object, objectType, &objectInteger) {
//            print("Integer value \(objectInteger)")
//        }
//    case .real:
//        // Real
//        var objectReal:CGPDFReal? = nil
//        if CGPDFObjectGetValue(object, objectType, &objectReal) {
//            print("Real value \(objectReal)")
//        }
//    case .name:
//        // Name
//        if (CGPDFObjectGetValue(object, objectType, &ptrObjectValue)) {
//            let stringName = String(cString: UnsafePointer<CChar>(ptrObjectValue!), encoding: String.Encoding.isoLatin1)
//            print("Name value: \(stringName!)")
//        }
//    case .string:
//        // String
//        _ = CGPDFObjectGetValue(object, objectType, &ptrObjectValue)
//        let stringValue = CGPDFStringCopyTextString(OpaquePointer(ptrObjectValue!))
//        print("String value: \(stringValue!)")
//    case .array:
//        // Array
//        print("Array")
//        var objectArray:CGPDFArrayRef? = nil
//        if (CGPDFObjectGetValue(object, objectType, &objectArray))
//        {
////            print("array: \(arrayFromPDFArray(pdfArray: objectArray!))")
//        }
//    case .dictionary:
//        // Dictionary
//        var objectDictionary:CGPDFDictionaryRef? = nil
//        if (CGPDFObjectGetValue(object, objectType, &objectDictionary)) {
//            let count = CGPDFDictionaryGetCount(objectDictionary!)
//            print("Found dictionary with \(count) entries")
//            if !(keyString == "Parent") && !(keyString == "P") {
//                //catalogLevel = catalogLevel + 1
//                CGPDFDictionaryApplyFunction(objectDictionary!, { (key, object, info) -> Void in
//                    let keyString = String(cString: UnsafePointer<CChar>(key), encoding: .isoLatin1)
////                    print("key = \(keyString)")
////                    parsePDFK(key: key, object: object) // , info: info)
//                }, nil)
//
//                // CGPDFDictionaryApplyFunction(objectDictionary!, printPDFKeys as! CGPDFDictionaryApplierFunction, nil)
//                //catalogLevel = catalogLevel - 1
//            }
//        }
//    case .stream:
//        // Stream
//        print("Stream")
//        var objectStream:CGPDFStreamRef? = nil
//        if (CGPDFObjectGetValue(object, objectType, &objectStream)) {
//            let _: CGPDFDictionaryRef = CGPDFStreamGetDictionary( objectStream! )!
//            var fmt: CGPDFDataFormat = .raw
//            let streamData: CFData = CGPDFStreamCopyData(objectStream!, &fmt)!;
//            let data = NSData(data: streamData as Data)
//            let dataString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
//            let dataLength: Int = CFDataGetLength(streamData)
//            print("data stream (length=\(dataLength)):")
//            if dataLength < 400 {
////                print(dataString)
//            }
//        }
//    default:
//        print("Null")
//    }
}
