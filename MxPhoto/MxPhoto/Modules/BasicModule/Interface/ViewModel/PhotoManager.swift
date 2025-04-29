//
//  PhotoManager.swift
//  MxPhoto
//
//  Created by Max on 28.04.2025.
//

import Foundation
import UIKit
import SwiftUI
import PhotosUI

@MainActor
class PhotoManager: ObservableObject {
    @Published private(set) var photos: [PhotoItem] = []
    private let photosDirectory: URL
    
    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        photosDirectory = paths[0].appendingPathComponent("SavedPhotos")
        createPhotosDirectoryIfNeeded()
        loadSavedPhotos()
    }
    
    func addPhoto(from pickerItem: PhotosPickerItem) async throws {
        guard let data = try await pickerItem.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            throw PhotoError.invalidImageData
        }
        let photo = PhotoItem(image: image)
        photos.append(photo)
        savePhotoToDisk(photo: photo)
    }
    
    func addPhoto(_ image: UIImage) {
        let photo = PhotoItem(image: image)
        photos.append(photo)
        savePhotoToDisk(photo: photo)
    }
    
    func updatePhoto(withID id: UUID, newImage: UIImage) {
        if let index = photos.firstIndex(where: { $0.id == id }) {
            let updatedPhoto = PhotoItem(id: id, image: newImage)
            photos[index] = updatedPhoto
            savePhotoToDisk(photo: updatedPhoto)
        }
    }
    
    func deletePhotos(withIDs ids: Set<UUID>) {
        for id in ids {
            if let index = photos.firstIndex(where: { $0.id == id }) {
                deletePhotoFromDisk(photo: photos[index])
                photos.remove(at: index)
            }
        }
    }
    
    // MARK: - File System
    private func createPhotosDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: photosDirectory.path) {
            try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func savePhotoToDisk(photo: PhotoItem) {
        let fileURL = photosDirectory.appendingPathComponent("\(photo.id).jpg")
        if let data = photo.image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
    
    private func loadSavedPhotos() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil) else { return }
        
        photos = files
            .filter { $0.pathExtension == "jpg" }
            .compactMap { file in
                guard let data = try? Data(contentsOf: file),
                      let image = UIImage(data: data),
                      let uuid = UUID(uuidString: file.deletingPathExtension().lastPathComponent) else {
                    return nil
                }
                return PhotoItem(id: uuid, image: image)
            }
    }
    
    private func deletePhotoFromDisk(photo: PhotoItem) {
        let fileURL = photosDirectory.appendingPathComponent("\(photo.id).jpg")
        try? FileManager.default.removeItem(at: fileURL)
    }
}

enum PhotoError: Error {
    case invalidImageData
}
