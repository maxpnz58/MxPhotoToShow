//
//  FilterView.swift
//  MxPhoto
//
//  Created by Max on 29.04.2025.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct FilterView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    @State private var selectedFilter: String = "None"
    @Environment(\.dismiss) private var dismiss
    
    private let filters: [String: CIFilter?] = [
        "None": nil,
        "Sepia": CIFilter.sepiaTone(),
        "Blur": CIFilter.gaussianBlur(),
        "Vignette": CIFilter.vignette()
    ]
    
    var body: some View {
        VStack {
            Image(uiImage: applyFilter(to: image))
                .resizable()
                .scaledToFit()
            
            Picker("Фильтр", selection: $selectedFilter) {
                ForEach(filters.keys.sorted(), id: \.self) { filter in
                    Text(filter)
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                Button("Отмена") { dismiss() }
                Spacer()
                Button("Сохранить") {
                    onSave(applyFilter(to: image))
                    dismiss()
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    private func applyFilter(to image: UIImage) -> UIImage {
        guard selectedFilter != "None",
              let ciImage = CIImage(image: image),
              let filter = filters[selectedFilter] as? CIFilter else {
            return image
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        switch selectedFilter {
        case "Sepia":
            filter.setValue(0.8, forKey: kCIInputIntensityKey)
        case "Blur":
            filter.setValue(10.0, forKey: kCIInputRadiusKey)
        case "Vignette":
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            filter.setValue(1.0, forKey: kCIInputRadiusKey)
        default:
            break
        }
        
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
}
