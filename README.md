
I am a beginner, I hope my code can give more inspiration for beginners. If you find that the code has bug, or want to communicate with me, please contact: 1505482941@qq.com





##swift2.0+
##xcode7+




swift1.2
OC:- https://github.com/kostiakoval/Mirror 

**WRMirror** - Swift objects Reflection API. 



## Usage
If you want to try it, there is a demo Playground available, just run 

```ruby
drop WRMirror.swift to your priject
```

###Create a mirror for an instance   

```swift
struct Person {
  let name: String
  var age: Int
}

var person = Person(name: "Jon", age: 27)
let mirror = Mirror(person)
```

### Inspect it  

```swift
//Get information about the type of an instance

mirror.name
//"MirrorTest.Person"

mirror.shortName
//Person

mirror.memorySize
// 32

mirror.isClass
//false

mirror.isStruct
//true
```

### Type Properties Inspection  
Get information about content of the type, its properties

```swift
mirror.names
//["name", "age"]

mirror.values
//["Jon", 27]

mirror.types
//[Swift.String, Swift.Int]

mirror.typesShortName
//["String", "Int"]

mirror["name"] //"Jon"
mirror["age"]  //27

mirror.toDictionary
//["age": 27, "name": "Jon"]
```

### Mirror is a CollectionType  
All the CollectionType methods are available for use with mirror  
Iterating, count, map, filter and other  

```swift
// Iterate over its children MirrorItems
for item in mirror {
  println(item)
}
//name: Swift.String = Jon
//age: Swift.Int = 27

let children = mirror.children //Array of MirrorItem
let firstKid = children[0]
//{name: "name", type: Swift.String, value: "Jon" }

var mirP = mirror[1]
mirP.name   // "age"
mirP.value  // 27
mirP.type   // Swift.Int
```
