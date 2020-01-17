//
//  WRPDFView.swift
//  WRPDFModel_Example
//
//  Created by 项辉 on 2020/1/17.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
func objectForPDFObject( object: CGPDFObjectRef) -> AnyObject? {
    let objectType: CGPDFObjectType = CGPDFObjectGetType(object)
    var ptrObjectValue:UnsafePointer<Int8>? = nil
    switch (objectType) {
    case .boolean:
        // Boolean
        var objectBoolean = CGPDFBoolean()
        if CGPDFObjectGetValue(object, objectType, &objectBoolean) {
            let testbool = NSNumber(value: objectBoolean)
            return testbool
        }
    case .integer:
        // Integer
        var objectInteger = CGPDFInteger()
        if CGPDFObjectGetValue(object, objectType, &objectInteger) {
            return objectInteger as AnyObject
        }
    case .real:
        // Real
        var objectReal = CGPDFReal()
        if CGPDFObjectGetValue(object, objectType, &objectReal) {
            return objectReal as AnyObject
        }
    case .string:
        _ = CGPDFObjectGetValue(object, objectType, &ptrObjectValue)
        let stringValue = CGPDFStringCopyTextString(OpaquePointer(ptrObjectValue!))
        return stringValue
    case .dictionary:
        // Dictionary
        var objectDictionary:CGPDFDictionaryRef? = nil
        if (CGPDFObjectGetValue(object, objectType, &objectDictionary)) {
            let count = CGPDFDictionaryGetCount(objectDictionary!)
            print("In array, found dictionary with \(count) entries")
            CGPDFDictionaryApplyFunction(objectDictionary!, { (key, object, info) -> Void in
//                printPDFKeys(key: key, object: object) // , info: info)
            }, nil)

            // CGPDFDictionaryApplyFunction(objectDictionary!, printPDFKeys as! CGPDFDictionaryApplierFunction, nil)
        }
    case .stream:
        // Stream
        var objectStream:CGPDFStreamRef? = nil
        if (CGPDFObjectGetValue(object, objectType, &objectStream)) {
            let _: CGPDFDictionaryRef = CGPDFStreamGetDictionary( objectStream! )!
            var fmt: CGPDFDataFormat = .raw
            let streamData: CFData = CGPDFStreamCopyData(objectStream!, &fmt)!;
            let data = NSData(data: streamData as Data)
            let dataString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
            print("data stream (length=\(CFDataGetLength(streamData))):")
            return dataString
        }
    default:
        return nil
    }
    return nil
}

// convert a PDF array into an objC one
func arrayFromPDFArray(pdfArray: CGPDFArrayRef ) -> NSMutableArray {
    var _:Int = 0
    let tmpArray: NSMutableArray = NSMutableArray()

    let count = CGPDFArrayGetCount(pdfArray)
    for i in 0..<count {
        var value:CGPDFObjectRef? = nil
        if (CGPDFArrayGetObject(pdfArray, i, &value)) {
            if let object = objectForPDFObject(object: value!) {
                tmpArray.add(object)
            }
        }
    }

    return tmpArray
}

func parsePage(_ pageInfo: CGPDFDictionaryRef) {
    CGPDFDictionaryApplyFunction(pageInfo, { (key, object, info) in
        let keyString = String(cString: UnsafePointer<CChar>(key), encoding: .isoLatin1)
        let objectType = CGPDFObjectGetType(object)

        print("--------------\(keyString)")
        var ptrObjectValue:UnsafePointer<Int8>? = nil
        switch objectType {
        case .boolean:
            // Boolean
            var objectBoolean:CGPDFBoolean = 0
            if CGPDFObjectGetValue(object, objectType, &objectBoolean) {
                let testbool = NSNumber(value: objectBoolean)
                print("Boolean value \(testbool)")
            }
        case .integer:
            // Integer
            var objectInteger:CGPDFInteger? = nil
            if CGPDFObjectGetValue(object, objectType, &objectInteger) {
                print("Integer value \(objectInteger)")
            }
        case .real:
            // Real
            var objectReal:CGPDFReal? = nil
            if CGPDFObjectGetValue(object, objectType, &objectReal) {
                print("Real value \(objectReal)")
            }
        case .name:
            // Name
            if (CGPDFObjectGetValue(object, objectType, &ptrObjectValue)) {
                let stringName = String(cString: UnsafePointer<CChar>(ptrObjectValue!), encoding: String.Encoding.isoLatin1)
                print("Name value: \(stringName!)")
            }
        case .string:
            // String
            _ = CGPDFObjectGetValue(object, objectType, &ptrObjectValue)
            let stringValue = CGPDFStringCopyTextString(OpaquePointer(ptrObjectValue!))
            print("String value: \(stringValue!)")
        case .array:
            // Array
            print("Array")
            var objectArray:CGPDFArrayRef? = nil
            if (CGPDFObjectGetValue(object, objectType, &objectArray))
            {
                print("array: \(arrayFromPDFArray(pdfArray: objectArray!))")
            }
        case .dictionary:
            // Dictionary
            var objectDictionary:CGPDFDictionaryRef? = nil
            if (CGPDFObjectGetValue(object, objectType, &objectDictionary)) {
                let count = CGPDFDictionaryGetCount(objectDictionary!)
                print("Found dictionary with \(count) entries")
                if !(keyString == "Parent") && !(keyString == "P") {
                    //catalogLevel = catalogLevel + 1
                    parsePage(objectDictionary!)
//                    CGPDFDictionaryApplyFunction(objectDictionary!, { (key, object, info) -> Void in
//                        printPDFKeys(key: key, object: object) // , info: info)
//                    }, nil)

                    // CGPDFDictionaryApplyFunction(objectDictionary!, printPDFKeys as! CGPDFDictionaryApplierFunction, nil)
                    //catalogLevel = catalogLevel - 1
                }
            }
        case .stream:
            // Stream
            print("Stream")
            var objectStream:CGPDFStreamRef? = nil
            if (CGPDFObjectGetValue(object, objectType, &objectStream)) {
                let dic: CGPDFDictionaryRef = CGPDFStreamGetDictionary( objectStream! )!
                CGPDFDictionaryApplyFunction(dic, { (key, object, info) in
                    let keyString = String(cString: UnsafePointer<CChar>(key), encoding: .isoLatin1)
                    print("123456+++++++++\(keyString)")
                    let objectType = CGPDFObjectGetType(object)

                            var ptrObjectValue:UnsafePointer<Int8>? = nil
                            switch objectType {
                            case .boolean:
                                // Boolean
                                var objectBoolean:CGPDFBoolean = 0
                                if CGPDFObjectGetValue(object, objectType, &objectBoolean) {
                                    let testbool = NSNumber(value: objectBoolean)
                                    print("Boolean value \(testbool)")
                                }
                            case .integer:
                                // Integer
                                var objectInteger:CGPDFInteger? = nil
                                if CGPDFObjectGetValue(object, objectType, &objectInteger) {
                                    print("Integer value \(objectInteger)")
                                }
                            case .real:
                                // Real
                                var objectReal:CGPDFReal? = nil
                                if CGPDFObjectGetValue(object, objectType, &objectReal) {
                                    print("Real value \(objectReal)")
                                }
                            case .name:
                                // Name
                                if (CGPDFObjectGetValue(object, objectType, &ptrObjectValue)) {
                                    let stringName = String(cString: UnsafePointer<CChar>(ptrObjectValue!), encoding: String.Encoding.isoLatin1)
                                    print("Name value: \(stringName!)")
                                }
                            case .string:
                                // String
                                _ = CGPDFObjectGetValue(object, objectType, &ptrObjectValue)
                                let stringValue = CGPDFStringCopyTextString(OpaquePointer(ptrObjectValue!))
                                print("String value: \(stringValue!)")
                            case .array:
                                // Array
                                print("Array")
                                var objectArray:CGPDFArrayRef? = nil
                                if (CGPDFObjectGetValue(object, objectType, &objectArray))
                                {
                                    print("array: \(arrayFromPDFArray(pdfArray: objectArray!))")
                                }
                            case .dictionary:
                                // Dictionary
                                var objectDictionary:CGPDFDictionaryRef? = nil
                                if (CGPDFObjectGetValue(object, objectType, &objectDictionary)) {
                                    let count = CGPDFDictionaryGetCount(objectDictionary!)
                                    print("Found dictionary with \(count) entries")
                                    if !(keyString == "Parent") && !(keyString == "P") {
                                        //catalogLevel = catalogLevel + 1
                                        parsePage(objectDictionary!)
                    //                    CGPDFDictionaryApplyFunction(objectDictionary!, { (key, object, info) -> Void in
                    //                        printPDFKeys(key: key, object: object) // , info: info)
                    //                    }, nil)

                                        // CGPDFDictionaryApplyFunction(objectDictionary!, printPDFKeys as! CGPDFDictionaryApplierFunction, nil)
                                        //catalogLevel = catalogLevel - 1
                                    }
                                }
                            case .stream:
                                // Stream
                                print("Stream")
                                var objectStream:CGPDFStreamRef? = nil
                                if (CGPDFObjectGetValue(object, objectType, &objectStream)) {
                                    let dic: CGPDFDictionaryRef = CGPDFStreamGetDictionary( objectStream! )!
                                    CGPDFDictionaryApplyFunction(dic, { (key, object, info) in
                                        let keyString = String(cString: UnsafePointer<CChar>(key), encoding: .isoLatin1)
                                        print("123456+++++++++\(keyString)")
                                        let objectType = CGPDFObjectGetType(object)

                                    }, nil)
                                    
                                    var fmt: CGPDFDataFormat = .raw
                                    let streamData: CFData = CGPDFStreamCopyData(objectStream!, &fmt)!;
                                    let data = NSData(data: streamData as Data)
                                    let dataString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
                                    let image = UIImage(data: data as Data)
                                    
                                    let dataLength: Int = CFDataGetLength(streamData)
                                    print("data stream (length=\(dataLength)):")
                                    if dataLength < 400 {
                                        print(dataString)
                                    }
                                }
                            default:
                                print("Null")
                            }

                }, nil)
                
                var fmt: CGPDFDataFormat = .raw
                let streamData: CFData = CGPDFStreamCopyData(objectStream!, &fmt)!;
                let data = NSData(data: streamData as Data)
                let dataString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
                let image = UIImage(data: data as Data)
                
                let dataLength: Int = CFDataGetLength(streamData)
                print("data stream (length=\(dataLength)):")
                if dataLength < 400 {
                    print(dataString)
                }
            }
        default:
            print("Null")
        }

    }, nil)
}

class WRPDFView: UIView {
    
    var pdfPage: CGPDFPage?
    var myScale: CGFloat!
    
    var pdfImage: UIImage?

    init(frame: CGRect, scale: CGFloat) {
        super.init(frame: frame)
        
        let tiledLayer = CATiledLayer(layer: self)
        tiledLayer.levelsOfDetail = 4
        tiledLayer.levelsOfDetailBias = 3
        
//        tiledLayer.tileSize = CGSize(width: 200, height: 200)
        myScale = scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static var layerClass: AnyClass {
        get {
//            return CALayer.self
            return CATiledLayer.self
        }
    }
    
    
    fileprivate func image() -> UIImage {
        var image = UIImage()

        guard let pdfPage = self.pdfPage else {
            return image
        }
        
        parsePage(pdfPage.dictionary!)
        
        let pageRect = pdfPage.getBoxRect(.mediaBox)

        let pageSize = pageRect.size
        
        if #available(iOS 10.0, *) {
            let render = UIGraphicsImageRenderer(size: pageSize)
            image = render.image { (ctx) in
                UIColor.white.set()
                ctx.fill(pageRect)

                ctx.cgContext.translateBy(x: 0.0, y: pageSize.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                ctx.cgContext.drawPDFPage(pdfPage)
            }
        } else {

            UIGraphicsBeginImageContextWithOptions(pageSize, false, UIScreen.main.scale)

            let ctx: CGContext = UIGraphicsGetCurrentContext()!
            ctx.saveGState()
            
            ctx.translateBy(x: 0, y: pageSize.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.scaleBy(x: self.myScale, y: self.myScale)

            ctx.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
            ctx.drawPDFPage(pdfPage)
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return image
    }
    
    override func draw(_ rect: CGRect) {
           
    }
    
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        if self.pdfImage == nil {
            if self.layer.isKind(of: CATiledLayer.self) {
                DispatchQueue.main.sync {
//                    self.pdfImage = self.image()
                    
//                    let data = self.image().pngData()
                    
                    let image = WRPDFView.grayImage(self.image())

                    self.pdfImage = WRPDFView.tintColor(image!, tintColor: .black)

//                    self.pdfImage = WRPDFView.tintColor(self.image(), tintColor: .clear)
                }
            } else {
//                self.pdfImage = self.image()
                self.pdfImage = WRPDFView.tintColor(self.image(), tintColor: .red)
            }
        }
        
        ctx.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ctx.setStrokeColor(UIColor.clear.cgColor)
//        
        ctx.fill(self.bounds)
        ctx.stroke(self.bounds)

        // Print a blank page and return if our page is nil.
        if ( self.pdfPage == nil )
        {
            print("page nil")
            return
        }

        // save the cg state
        ctx.saveGState()
        

        // Flip the context so that the PDF page is rendered right side up.
        ctx.translateBy(x: 0.0, y: self.bounds.size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)

        // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
//        ctx.scaleBy(x: self.myScale, y: self.myScale)

//        ctx.setBlendMode(.darken)


        // draw the page, restore and exit
        
        let height = self.pdfImage!.size.height / self.pdfImage!.size.width * self.bounds.width
        let y : Int = Int((self.bounds.height - height) / 2.0)
//
        ctx.draw((self.pdfImage?.cgImage)!, in: CGRect(x: 0, y:  CGFloat(y), width: self.bounds.width, height: ceil(height)), byTiling: false)
//        ctx.drawPDFPage(self.pdfPage!)
//        ctx.setBlendMode(.exclusion)
//        ctx.drawPDFPage(self.pdfPage!)

        ctx.restoreGState()
    }

    
    fileprivate static func tintColor(_ image : UIImage, tintColor: UIColor) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height) as CGRect
        if let cgImage = image.cgImage {
            context?.clip(to: rect, mask:  cgImage)
        }
        
        tintColor.setFill()
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    static func grayImage(_ image: UIImage) -> UIImage?
        {
            UIGraphicsBeginImageContext(image.size)
            let colorSpace = CGColorSpaceCreateDeviceGray()
            let context = CGContext(data: nil , width: Int(image.size.width), height: Int(image.size.height),bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
            context?.draw(image.cgImage!, in: CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height))
            let cgImage = context!.makeImage()
            let grayImage = UIImage(cgImage: cgImage!, scale: image.scale, orientation: image.imageOrientation)
            return grayImage
            
        }
    
}
