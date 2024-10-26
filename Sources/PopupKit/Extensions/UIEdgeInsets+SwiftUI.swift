//
//  UIEdgeInsets+SwiftUI.swift
//  PopupKit
//
//  Created by Илья Аникин on 30.09.2024.
//

import SwiftUI

extension UIEdgeInsets {
    var toSwiftUIInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
