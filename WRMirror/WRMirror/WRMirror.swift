//
//  Mirror.swift
//  反射
//
//  Created by 温锐 on 16/3/4.
//  Copyright © 2016年 wbg. All rights reserved.
//

import Foundation

public struct MirrorType {
    public let type: Any.Type
    public let value: Any
    init(type: Any.Type,value: Any){
        self.value=value
        self.type=type
        
    }
}

public struct MirrorItem {
    
    public let name: String
    public let type: Any.Type
    public let value: Any
    
    init(tup: (String, MirrorType)) {
        self.name = tup.0
        self.type = tup.1.type
        self.value = tup.1.value
    }
}

extension MirrorItem : CustomStringConvertible {
    public var description: String {
        return "\(name): \(type) = \(value)"
    }
}

public struct WRMirror<T> {
    
    let mirror: Mirror
    
    let instance: T
    
    public init (_ x: T) {
        instance = x
        mirror = Mirror(reflecting:x)
    }
    
    //MARK: - Type Info
    
    /// Instance type full name, include Module
    public var name: String {
        return "\(instance.dynamicType)"
    }
    
    /// Instance type short name, just a type name, without Module
    public var shortName: String {
        let name = "\(instance.dynamicType)".sortNameStyle
        return name
    }
    
}



// MARK: - Type detection
extension WRMirror {
    
//        public var isClass: Bool {
//            if let object = self.instance as? AnyObject {
//                struct.type
//                 return (ObjectIdentifier(object)==nil)
//            
//            }
//           
//        }
    
    //    public var isStruct: Bool {
    //        return mirror.objectIdentifier == nil
    //    }
    
    public var isOptional: Bool {
        return name.hasPrefix("Optional<")
    }
    
    public var isArray: Bool {
        return name.hasPrefix("Array<")
    }
    
    public var isDictionary: Bool {
        return name.hasPrefix("Dictionary<")
    }
    
    public var isSet: Bool {
        return name.hasPrefix("Set<")
    }
}



extension WRMirror {
    
    /// Type properties count
    public var childrenCount: IntMax {
        return self.mirror.children.count
    }
    
    public var memorySize: Int {
        return sizeofValue(instance)
    }
}



//MARK: - Children Inpection
extension WRMirror {
    
    /// Properties Names
    public var names: [String] {
        return self.mirror.children.map { $0.label! }
    }
    
    /// Properties Values
    public var values: [Any] {
        return self.mirror.children.map { $0.value }
    }
    
    /// Properties Types
    public var types: [Any.Type] {
        return self.mirror.children.map { $0.value.dynamicType }
    }
    
    /// Short style for type names
    public var typesShortName: [String] {
        return self.mirror.children.map {
            let conv = "\($0.value.dynamicType)".sortNameStyle
            return conv //.pathExtension
        }
    }
    
    // Mirror types for every children property
    public var children: [MirrorItem] {
        var result:[MirrorItem]=[MirrorItem]()
        for child in mirror.children {
            guard let _ = child.label else {
                continue
            }
            
            let ty=MirrorType(type: child.value.dynamicType, value: child.value )
            let item:MirrorItem=MirrorItem(tup: (child.label!, ty))
            result.append(item)
        }
        
        return result
    }
}





//MARK: - Quering
extension WRMirror {
    
    /// Returns a property value for a property name
    public subscript (key: String) -> Any? {
        for i in self.children{
            if(i.name==key){
                return i.value
            }
        }
        return nil
    }
    
    /// Returns a property value for a property name with a Genereci type
    /// No casting needed
    public func get<U>(key: String) -> U? {
        for child in mirror.children {
            guard let _ = child.label else {
                continue
            }
            if(child.label==key){
                return child.value as? U
            }
        }
        return nil
    }
}




// MARK: - Converting
extension WRMirror {
    
    /// Convert to a dicitonary with [PropertyName : PropertyValue] notation
    public var toDictionary: [String : Any] {
        
        var result: [String : Any] = [ : ]
        
        for child in mirror.children {
            guard let _ = child.label else {
                continue
            }
            result[child.label!] = child.value
        }
        
        return result
    }
    
    /// Convert to NSDictionary.
    /// Useful for saving it to Plist
    public var toNSDictionary: NSDictionary {
        
        var result: [String : AnyObject] = [ : ]
        for child in mirror.children {
            guard let _ = child.label else {
                continue
            }
            result[child.label!] = child.value as? AnyObject
        }
        
        return result
    }
}


// MARK: - CollectionType
extension WRMirror : CollectionType, SequenceType {
    
    public func generate() -> IndexingGenerator<[MirrorItem]> {
        return children.generate()
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return children.count
    }
    
    
    public subscript (i: Int) -> MirrorItem {
        
        
        var f=0
        for child in mirror.children {
            guard let _ = child.label else {
                continue
            }
            if(f==i){
                let s=MirrorType(type: child.value.dynamicType, value: child.value )
                let item:MirrorItem=MirrorItem(tup: (child.label!, s))
                return item
            }
            f++;
            
        }
        
        
        
        return MirrorItem(tup: ("", MirrorType(type: self.dynamicType, value: "")))
    }
    
}


// MARK: - Mirror helpers
extension String {
    
    func contains(x: String) -> Bool {
        return self.rangeOfString(x) != nil
    }
    
    func convertOptionals() -> String {
        var x = self
        while let start = x.rangeOfString("Optional<") {
            if let end = x.rangeOfString(">", range: start.startIndex..<x.endIndex) {
                let subtypeRange = start.endIndex..<end.startIndex
                let subType = x[subtypeRange]
                x.replaceRange(end, with: "?")
                x.replaceRange(subtypeRange, with: subType.sortNameStyle)
            }
            x.removeRange(start)
        }
        return x
    }
    
    func convertArray() -> String {
        var x = self
        while let start = x.rangeOfString("Array<") {
            if let end = x.rangeOfString(">", range: start.startIndex..<x.endIndex) {
                let subtypeRange = start.endIndex..<end.startIndex
                let arrayType = x[subtypeRange]
                x.replaceRange(end, with: "]")
                x.replaceRange(subtypeRange, with: arrayType.sortNameStyle)
                
            }
            x.replaceRange(start, with:"[")
        }
        return x
    }
    
    func removeTypeModuleName() -> String {
        var x = self
        if let range = self.rangeOfString(".") {
            x = self.substringFromIndex(range.endIndex)
        }
        return x
    }
    
    var sortNameStyle: String {
        return self
            .removeTypeModuleName()
            .convertOptionals()
            .convertArray()
    }
    
}







