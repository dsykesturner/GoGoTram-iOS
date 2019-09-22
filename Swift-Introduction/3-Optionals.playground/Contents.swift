import UIKit
import PlaygroundSupport

/////////////////////////////////////////
/// 3. Optionals
/////////////////////////////////////////

// Swift has optionals which denote whether a variable can be nil.
//  !   ==> cannot be null
//  ?   ==> can be null
var myString: String? = "Hello"

// In most cases, before an optional (?) can be used it needs to be checked for nil
if myString != nil {
    myString! += " World"
    print(myString!)
} else {
    print("my string was nil")
}

// or a cleaner way of doing it...
if var mySafeString = myString {
    // Here (!) is not needed, because mySafeString will only exist if myString is not nil
    mySafeString += ". How are you?"
    print(mySafeString)
} else {
    print("my string was nil")
}

// This also works for checking the type of object
//  Any     => this thing can be any type
let mySomething: Any = "I could be anything"

if let mySafeInt = mySomething as? Int {
    print("I'm an int: \(mySafeInt)")
} else if let mySafeString = mySomething as? String {
    print("I'm a string: \(mySafeString)")
}

// Many of these can be chained together
let yourSomething: Any = 50

if let mySafeString = mySomething as? String, let yourSafeInt = yourSomething as? Int {
    print("mySomething is a string: \(mySafeString)")
    print("yourSomething is an int: \(yourSafeInt)")
}
