//
//  ViewController.swift
//  反射
//
//  Created by 温锐 on 16/3/4.
//  Copyright © 2016年 wbg. All rights reserved.
//

import UIKit

//
//class Person : AnyObject {
//    let name: String = "wenrui"
//    var age: Int?
//}

struct Person {
    let name: String
    var age: Int
}




class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let person = Person(name: "Jon", age: 27)
        let mirror = WRMirror(person)
        
        
        
        let mirP = mirror[1]
        print(mirP.name)   // "age"
        print(mirP.value)  // 27
        print(mirP.type)   // Swift.Int
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

