//
//  SettingsView.swift
//  HairStyle
//
//  Created by adam on 27/03/2025.
//

import SwiftUI
import PhotosUI
import Vision


struct SettingsView: View {
    @ObservedObject var viewModel: ImageEditingViewModel
    @Binding var sliderPosition: CGFloat
    
    var body: some View {
        List {
            Section(header: Text("Sharing Settings")) {
                Toggle(isOn: $viewModel.isPublicSharing) {
                    Text(viewModel.isPublicSharing ? "Share Generations Publicly: On" : "Share Generations Publicly: Off")
                }
            }
            
            Section(header: Text("Before/After Slider")) {
                Slider(value: $sliderPosition, in: 0...1)
                Text("Slider Position: \(sliderPosition, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Settings")
        .listStyle(InsetGroupedListStyle())
    }
}
