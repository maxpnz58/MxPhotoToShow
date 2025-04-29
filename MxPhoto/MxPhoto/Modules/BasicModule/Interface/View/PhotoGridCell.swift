//
//  PhotoGridCell.swift
//  MxPhoto
//
//  Created by Max on 26.04.2025.
//

import SwiftUI

struct PhotoGridCell: View {
    let photo: PhotoItem
    let isSelectionMode: Bool
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: photo.image)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .clipped()
            
            if isSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundColor(isSelected ? .blue : .white)
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
                    .padding(4)
            }
        }
    }
}
