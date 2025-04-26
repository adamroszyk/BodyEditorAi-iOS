//
//  PhotoContainerView.swift
//  HairStyle
//
//  Created by adam on 25/04/2025.
//

import SwiftUI

// MARK: - PhotoContainerView
struct PhotoContainerView: View {
    @Binding var inputImage: UIImage?
    let editedImage: UIImage?
    let depthMapImage: UIImage?
    @Binding var sliderPosition: CGFloat
    @Binding var showSlider: Bool
    let onAddTap: () -> Void
    let onReplaceTap: () -> Void
    let onSaveTap: () -> Void

    var body: some View {
        ZStack {
            backgroundView
                .ignoresSafeArea()

            PhotoWithRefreshOverlay(
                originalImage: inputImage,
                editedImage: editedImage,
                depthMapImage: depthMapImage,
                sliderPosition: $sliderPosition,
                showSlider: $showSlider,
                onReplaceTap: onReplaceTap,
                onAddTap: onAddTap,
                onSaveTap: onSaveTap
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if let img = inputImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .blur(radius: 120)
                .overlay(Color.black.opacity(0.4))
        } else {
            Color.black.opacity(0.6)
        }
    }
}
