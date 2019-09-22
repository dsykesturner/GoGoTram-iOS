import UIKit
import PlaygroundSupport

/////////////////////////////////////////
/// 2. Classes, initalisers, structs
/////////////////////////////////////////

// Classes group together ownership of functions, variables, etc
/*
 class                  => this is a class
 Calculator             => name of the class (first letter uppercase)
 Calculator: NSObject   => this class inherits from an NSObject (basic class, good for starting on a blank slate)
 */
class Calculator: NSObject {
    
    func multiply(num1: Int, num2: Int) -> Int {
        return num1 * num2
    }
    
    // All classes have an initialiser. But you can also create your own, as long as you also call the original initialiser using `super.init`
    /*
     init           => this is an initialiser function
     darkMode: Bool => this calculator can be initialised in either dark or light mode
     super          => super is the parent NSObject
     super.init()   => this calls the parent initialiser
    */
    init(darkMode: Bool) {
        super.init()
        if darkMode {
            print("Calculator started in dark mode")
        } else {
            print("Calculator started in light mode")
        }
    }
}

// Create a calculator by calling its initaliser
let myCalc = Calculator(darkMode: true)

// A struct is like an object, but when it is copied, it is copied by value instead of reference
//  what? --> https://i.stack.imgur.com/mzMfb.gif
struct CoffeeCup {
    // This has a default value of 0
    var fillLevel: Double = 0
    var coffeeType: String
}

// Create a latte. Since `fillLevel` has a default value there's no need give it a value
let latte = CoffeeCup(coffeeType: "Latte")
print(latte)
