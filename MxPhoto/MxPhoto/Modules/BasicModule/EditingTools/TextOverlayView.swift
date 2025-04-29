//
//  TextOverlayView.swift
//  MxPhoto
//
//  Created by Max on 29.04.2025.
//

import SwiftUI

struct TextOverlayView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    @State private var textItems: [TextItem] = []
    @State private var selectedText: UUID?
    @State private var isEditingText = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                
                ForEach(textItems) { item in
                    Text(item.text)
                        .font(.custom(item.font, size: item.size))
                        .foregroundColor(item.color)
                        .position(item.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    updateTextPosition(id: item.id, position: value.location)
                                }
                        )
                        .onTapGesture {
                            selectedText = item.id
                            isEditingText = true
                        }
                }
            }
            
            HStack {
                Button("Добавить текст") {
                    textItems.append(TextItem())
                    selectedText = textItems.last?.id
                    isEditingText = true
                }
                Spacer()
                Button("Отмена") { dismiss() }
                Button("Сохранить") {
                    let renderedImage = renderImage()
                    onSave(renderedImage)
                    dismiss()
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $isEditingText) {
            if let selectedID = selectedText,
               let index = textItems.firstIndex(where: { $0.id == selectedID }) {
                TextEditorView(
                    textItem: $textItems[index],
                    isPresented: $isEditingText
                )
            }
        }
    }
    
    private func updateTextPosition(id: UUID, position: CGPoint) {
        if let index = textItems.firstIndex(where: { $0.id == id }) {
            textItems[index].position = position
        }
    }
    
    private func renderImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(at: .zero)
            for item in textItems {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: item.font, size: item.size) ?? UIFont.systemFont(ofSize: item.size),
                    .foregroundColor: UIColor(item.color)
                ]
                let text = NSAttributedString(string: item.text, attributes: attributes)
                text.draw(at: item.position)
            }
        }
    }
}

struct TextItem: Identifiable {
    let id = UUID()
    var text: String = "Текст"
    var font: String = "Helvetica"
    var size: CGFloat = 20
    var color: Color = .white
    var position: CGPoint = CGPoint(x: 100, y: 100)
}

struct TextEditorView: View {
    @Binding var textItem: TextItem
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Текст", text: $textItem.text)
                Picker("Шрифт", selection: $textItem.font) {
                    Text("Helvetica").tag("Helvetica")
                    Text("Times New Roman").tag("Times New Roman")
                    Text("Arial").tag("Arial")
                }
                Slider(value: $textItem.size, in: 10...50, step: 1) {
                    Text("Размер")
                }
                ColorPicker("Цвет", selection: $textItem.color)
            }
            .navigationTitle("Редактировать текст")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { isPresented = false }
                }
            }
        }
    }
}

