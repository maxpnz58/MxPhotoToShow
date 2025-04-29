//
//  CameraView.swift
//  MxPhoto
//
//  Created by Max on 26.04.2025.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    var didCaptureImage: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didCaptureImage: didCaptureImage)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var didCaptureImage: (UIImage?) -> Void
        
        init(didCaptureImage: @escaping (UIImage?) -> Void) {
            self.didCaptureImage = didCaptureImage
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                didCaptureImage(image)
            } else {
                didCaptureImage(nil)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            didCaptureImage(nil)
            picker.dismiss(animated: true)
        }
    }
}

struct PreviewView: View {
    let image: UIImage
    var onRetake: () -> Void
    var onUse: () -> Void

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
            
            HStack(spacing: 40) {
                Button("Переснять", action: onRetake)
                Button("Использовать", action: onUse)
            }
            .padding()
        }
    }
}
