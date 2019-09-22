import UIKit
import PlaygroundSupport

/////////////////////////////////////////
/// 1. Functions, variables, comments
/////////////////////////////////////////

// Single line comment
/*
 Multiple lines comment
*/

// Declare a function
/*
 func           => this is a function
 multiply       => name of the function (first letter lowercase)
 num1 and num2  => these are our parameters (first letter lowercase)
 num1: Int      => num1 is an Int type. Also available: Float, Bool, Double, String, or any other class type
 -> Int         => this function returns an Int
*/
func multiply(num1: Int, num2: Int) -> Int {
    return num1 * num2
}

// Call the function to find 5 * 10, and put the result into the constant `product`
//  Use `let` for constants, and `var` for variables
//  product = 50
let product = multiply(num1: 5, num2: 10)

// Print "The product of 5 and 10 is 50" to the debug console.
//  Using \(someVariable) inside a string will print it's description
print("The product of 5 and 10 is \(product)")

// Initialise an array
/*
 [Int]      => this array will contain only integers
*/
let fibArray:[Int] = [1,1,3,5,8]

// Loop through each item in the array
for number in fibArray {
    print(number)
}

// Loop through each index in the array
/*
 0 ..< fibArray.count   => creates a range from 0 to fibArray.count-1
 0 ... fibArray.count   => create a range from 0 to fibArray.count (but this would go out of range here, since the last index is at fibArray.count-1)
*/
for i in 0 ..< fibArray.count {
    let number = fibArray[i]
    print("number \(number) is at index \(i)")
}
