//
//  Constants.swift
//  GoGoTram
//
//  Created by Daniel Sykes-Turner on 8/9/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit

struct pc {
    static let none: UInt32 = 0x1 << 0
    static let tram: UInt32 = 0x1 << 1
    static let signalFault: UInt32 = 0x1 << 2
    static let passengers: UInt32 = 0x1 << 3
}

struct layers {
    static let background:CGFloat = 0
    static let actor:CGFloat = 1
    static let fire:CGFloat = 2
    static let text:CGFloat = 3
}
