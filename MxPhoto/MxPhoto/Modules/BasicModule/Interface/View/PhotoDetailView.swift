//
//  PhotoDetailView.swift
//  MxPhoto
//
//  Created by Max on 26.04.2025.
//

import SwiftUI
import PencilKit

struct PhotoDetailView: View {
    private let allPhotos: [PhotoItem]
    @State private var windowedPhotos: [PhotoItem]
    @State private var currentGlobalIndex: Int
    @State private var loadedRange: Range<Int>
    @State private var toolPicker = PKToolPicker()
    
    private let windowSize = 5
    private let preloadThreshold = 2
    
    @EnvironmentObject private var photoManager: PhotoManager
    @State private var activeSheet: ActiveSheet?
    @Environment(\.dismiss) private var dismiss
    
    init(photos: [PhotoItem], currentIndex: Int) {
        self.allPhotos = photos
        let initialRange = Self.calculateRange(for: currentIndex, total: photos.count, windowSize: 5)
        self._windowedPhotos = State(initialValue: Array(photos[initialRange]))
        self._currentGlobalIndex = State(initialValue: currentIndex)
        self._loadedRange = State(initialValue: initialRange)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                TabView(selection: $currentGlobalIndex) {
                    ForEach(Array(windowedPhotos.enumerated()), id: \.element.id) { localIndex, photo in
                        ZoomableImageView(image: photo.image)
                            .tag(loadedRange.lowerBound + localIndex)
                            .onAppear {
                                checkForLoadMore(visibleIndex: loadedRange.lowerBound + localIndex)
                            }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .ignoresSafeArea()
                .onChange(of: currentGlobalIndex) { newValue in
                    updateWindowIfNeeded(newIndex: newValue)
                }
                
                controlOverlay
            }
            .navigationDestination(item: $activeSheet) { sheet in
                switch sheet {
                case .crop:
                    CropRotateView(image: currentPhoto.image, onSave: updateCurrentPhoto)
                case .draw:
                    DrawingView(image: currentPhoto.image, onSave: updateCurrentPhoto)
                case .text:
                    TextOverlayView(image: currentPhoto.image, onSave: updateCurrentPhoto)
                case .filter:
                    FilterView(image: currentPhoto.image, onSave: updateCurrentPhoto)
                }
            }
        }
        .onReceive(photoManager.$photos) { updatedPhotos in
            refreshPhotos(with: updatedPhotos)
        }
    }
    
    // MARK: - Computed Properties
    private var currentPhoto: PhotoItem {
        guard let index = windowedPhotos.firstIndex(where: { $0.id == allPhotos[currentGlobalIndex].id }) else {
            return windowedPhotos[0]
        }
        return windowedPhotos[index]
    }
    
    private var controlOverlay: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                
                Spacer()
                
                ShareLink(
                    item: Image(uiImage: currentPhoto.image),
                    preview: SharePreview("Фото", image: Image(uiImage: currentPhoto.image))
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
            }
            .padding()
            
            Spacer()
            
            editButtons
        }
        .foregroundColor(.white)
    }
    
    private var editButtons: some View {
        HStack(spacing: 20) {
            EditButton(icon: "crop.rotate", label: "Обрезка") { activeSheet = .crop }
            EditButton(icon: "pencil.tip", label: "Рисование") { activeSheet = .draw }
            EditButton(icon: "textformat", label: "Текст") { activeSheet = .text }
            EditButton(icon: "wand.and.stars", label: "Фильтры") { activeSheet = .filter }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Logic Methods
    private static func calculateRange(for index: Int, total: Int, windowSize: Int) -> Range<Int> {
        let lowerBound = max(0, index - windowSize)
        let upperBound = min(total, index + windowSize + 1)
        return lowerBound..<upperBound
    }
    
    private func checkForLoadMore(visibleIndex: Int) {
        let offsetFromStart = visibleIndex - loadedRange.lowerBound
        let offsetFromEnd = loadedRange.upperBound - visibleIndex
        
        if offsetFromStart <= preloadThreshold {
            loadMorePhotos(direction: .backward)
        } else if offsetFromEnd <= preloadThreshold {
            loadMorePhotos(direction: .forward)
        }
    }
    
    private func loadMorePhotos(direction: LoadDirection) {
        let newRange: Range<Int>
        switch direction {
        case .forward:
            newRange = loadedRange.lowerBound..<min(allPhotos.count, loadedRange.upperBound + windowSize)
        case .backward:
            newRange = max(0, loadedRange.lowerBound - windowSize)..<loadedRange.upperBound
        }
        
        guard newRange != loadedRange else { return }
        windowedPhotos = Array(allPhotos[newRange])
        loadedRange = newRange
    }
    
    private func updateWindowIfNeeded(newIndex: Int) {
        let targetRange = Self.calculateRange(for: newIndex, total: allPhotos.count, windowSize: windowSize)
        guard !targetRange.contains(loadedRange) else { return }
        windowedPhotos = Array(allPhotos[targetRange])
        loadedRange = targetRange
    }
    
    private func refreshPhotos(with updatedPhotos: [PhotoItem]) {
        guard let currentPhotoIndex = updatedPhotos.firstIndex(where: { $0.id == currentPhoto.id }) else { return }
        currentGlobalIndex = currentPhotoIndex
        let newRange = Self.calculateRange(for: currentGlobalIndex, total: updatedPhotos.count, windowSize: windowSize)
        windowedPhotos = Array(updatedPhotos[newRange])
        loadedRange = newRange
    }
    
    private func updateCurrentPhoto(_ image: UIImage) {
        photoManager.updatePhoto(withID: currentPhoto.id, newImage: image)
    }
}

// MARK: - Helper Types
enum LoadDirection {
    case forward, backward
}

enum ActiveSheet: Identifiable {
    case crop, draw, text, filter
    
    var id: Int {
        hashValue
    }
}

struct EditButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .padding(10)
            .background(Circle().fill(Color.black.opacity(0.7)))
        }
    }
}

