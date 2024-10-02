//
//  EdgeInsets+Extensions.swift
//  PopupKit
//
//  Created by Илья Аникин on 24.09.2024.
//

import SwiftUI

extension EdgeInsets {
    func resolvingInSet(_ ignoresEdges: Edge.Set) -> Self {
        EdgeInsets(
            top: ignoresEdges.contains(.top) ? 0 : self.top,
            leading: ignoresEdges.contains(.leading) ? 0 : self.leading,
            bottom: ignoresEdges.contains(.bottom) ? 0 : self.bottom,
            trailing: ignoresEdges.contains(.trailing) ? 0 : self.trailing
        )
    }
}
