//
//  PhotoItem.swift
//  MxPhoto
//
//  Created by Max on 26.04.2025.
//

import SwiftUI

struct PhotoItem: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    
    init(id: UUID = UUID(), image: UIImage) {
        self.id = id
        self.image = image
    }
}
