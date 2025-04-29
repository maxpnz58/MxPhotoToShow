//
//  DrawingView.swift
//  MxPhoto
//
//  Created by Max on 29.04.2025.
//

import SwiftUI
import PencilKit

struct DrawingView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    @State private var canvas = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .background(Color.white)
                    
                    CanvasView(canvasView: $canvas, toolPicker: toolPicker)
                        .allowsHitTesting(true)
                }
                .onAppear {
                    setupCanvas(size: geometry.size)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        DispatchQueue.global(qos: .userInitiated).async {
                            if let renderedImage = renderImage() {
                                DispatchQueue.main.async {
                                    onSave(renderedImage)
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    private func setupCanvas(size: CGSize) {
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        let imageSize = image.size
        canvas.frame = CGRect(origin: .zero, size: imageSize)
    }
    
    private func renderImage() -> UIImage? {
        autoreleasepool {
            let renderer = UIGraphicsImageRenderer(size: image.size)
            return renderer.image { ctx in
                image.draw(in: CGRect(origin: .zero, size: image.size))
                canvas.drawing.image(from: CGRect(origin: .zero, size: image.size), scale: 1.0)
                    .draw(in: CGRect(origin: .zero, size: image.size))
            }
        }
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let toolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        DispatchQueue.main.async {
            canvasView.becomeFirstResponder()
        }
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        let imageSize = uiView.superview?.bounds.size ?? .zero
        uiView.frame = CGRect(origin: .zero, size: imageSize)
    }
}
