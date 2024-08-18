//
//  DPrint.swift
//
//
//  Created by Илья Аникин on 18.08.2024.
//

func dprint(_ verbose: Bool?, _ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    if verbose != false {
        print(items, separator: separator, terminator: terminator)
    }
    #endif
}
