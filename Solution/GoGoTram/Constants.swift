//
//  Constants.swift
//  GoGoTram
//
//  Created by Daniel Sykes-Turner on 22/9/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit

struct layers {
    static let background:CGFloat = 0
    static let actor:CGFloat = 1
    static let text:CGFloat = 2
}

struct pc {
    static let none: UInt32 = 0x1 << 0
    static let signalFault: UInt32 = 0x1 << 1
    static let passengers: UInt32 = 0x1 << 2
}
