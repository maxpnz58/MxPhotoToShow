//
//  PhotoGridView.swift
//  MxPhoto
//
//  Created by Max on 26.04.2025.
//
//
import SwiftUI
import PhotosUI
import AVFoundation

struct PhotoGridView: View {
    @StateObject private var photoManager = PhotoManager()
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isShowingPicker = false
    @State private var isShowingCamera = false
    @State private var isSelectionMode = false
    @State private var selectedPhotoIDs = Set<UUID>()
    @State private var isShowingDetailView = false
    @State private var previewIndex = 0
    @State private var showCameraAccessAlert = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 1) {
                    if !isSelectionMode {
                        AddPhotoButton { isShowingPicker = true }
                        CameraButton { checkCameraPermission() }
                        EditListButton { isSelectionMode = true }
                    }
                    
                    ForEach(Array(photoManager.photos.enumerated()), id: \.element.id) { index, photo in
                        PhotoGridCell(
                            photo: photo,
                            isSelectionMode: isSelectionMode,
                            isSelected: selectedPhotoIDs.contains(photo.id)
                        )
                        .onTapGesture {
                            if isSelectionMode {
                                toggleSelection(for: photo.id)
                            } else {
                                previewIndex = index
                                isShowingDetailView = true
                            }
                        }
                        .onLongPressGesture {
                            if !isSelectionMode {
                                isSelectionMode = true
                                toggleSelection(for: photo.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isSelectionMode ? "Выбрано: \(selectedPhotoIDs.count)" : "Мои фото")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .photosPicker(
                isPresented: $isShowingPicker,
                selection: $selectedItems,
                maxSelectionCount: 10,
                matching: .images
            )
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraView { image in
                    if let image {
                        photoManager.addPhoto(image)
                    }
                    isShowingCamera = false
                }
            }
            .fullScreenCover(isPresented: $isShowingDetailView) {
                PhotoDetailView(photos: photoManager.photos, currentIndex: previewIndex)
                    .environmentObject(photoManager) // Передаем PhotoManager
            }
            .onChange(of: selectedItems) { newItems, _ in
                Task {
                    for item in newItems {
                        try? await photoManager.addPhoto(from: item)
                    }
                    selectedItems.removeAll()
                }
            }
            .alert("Доступ к камере", isPresented: $showCameraAccessAlert) {
                Button("Настройки") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(settingsURL) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Приложению нужен доступ к камере. Пожалуйста, предоставьте разрешение в настройках.")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if isSelectionMode {
                Button("Готово") {
                    isSelectionMode = false
                    selectedPhotoIDs.removeAll()
                }
                
                if !selectedPhotoIDs.isEmpty {
                    Button(role: .destructive) {
                        photoManager.deletePhotos(withIDs: selectedPhotoIDs)
                        isSelectionMode = false
                        selectedPhotoIDs.removeAll()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        
        ToolbarItemGroup(placement: .topBarLeading) {
            if !isSelectionMode {
                Button(role: .destructive) {
                    authViewModel.isAuthenticated = false
                } label: {
                    Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .tint(.red)
            }
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isShowingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        isShowingCamera = true
                    }
                }
            }
        case .denied, .restricted:
            showCameraAccessAlert = true
        @unknown default:
            break
        }
    }
    
    private func toggleSelection(for id: UUID) {
        if selectedPhotoIDs.contains(id) {
            selectedPhotoIDs.remove(id)
        } else {
            selectedPhotoIDs.insert(id)
        }
    }
}

// MARK: - Subviews

struct AddPhotoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fill)
                VStack {
                    Image(systemName: "photo")
                        .font(.title)
                    Text("Галерея")
                        .font(.caption)
                }
                .foregroundColor(.gray)
            }
        }
    }
}

struct CameraButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fill)
                VStack {
                    Image(systemName: "camera")
                        .font(.title)
                    Text("Камера")
                        .font(.caption)
                }
                .foregroundColor(.gray)
            }
        }
    }
}

struct EditListButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fill)
                VStack {
                    Image(systemName: "trash")
                        .font(.title)
                    Text("Удалить")
                        .font(.caption)
                }
                .foregroundColor(.red)
            }
        }
    }
}


