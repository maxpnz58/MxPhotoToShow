//
//  CropRotateView.swift
//  MxPhoto
//
//  Created by Max on 29.04.2025.
//

import SwiftUI
import TOCropViewController

struct CropRotateView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        CropViewControllerRepresentable(
            image: image,
            onSave: { updatedImage in
                onSave(updatedImage)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
        .ignoresSafeArea()
    }
}

struct CropViewControllerRepresentable: UIViewControllerRepresentable {
    let image: UIImage
    let onSave: (UIImage) -> Void
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }
    
    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSave: onSave, onCancel: onCancel)
    }
    
    class Coordinator: NSObject, TOCropViewControllerDelegate {
        let onSave: (UIImage) -> Void
        let onCancel: () -> Void
        
        init(onSave: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onSave = onSave
            self.onCancel = onCancel
        }
        
        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with rect: CGRect, angle: Int) {
            onSave(image)
        }
        
        func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
            onCancel()
        }
    }
}
