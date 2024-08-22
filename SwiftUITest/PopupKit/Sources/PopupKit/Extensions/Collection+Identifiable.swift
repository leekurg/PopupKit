//
//  Collection+Identifiable.swift
//
//
//  Created by Илья Аникин on 23.08.2024.
//

extension Collection where Element: Identifiable {
    /// Finds first identifiable element within this collection by **id**.
    func find(_ id: Element.ID) -> Element? {
        first { $0.id == id }
    }
}
