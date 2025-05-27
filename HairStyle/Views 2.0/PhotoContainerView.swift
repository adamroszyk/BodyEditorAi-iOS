//
//  PhotoContainerView.swift
//  HairStyle
//
//  Created by adam on 25/04/2025.
//

import SwiftUI

// MARK: – Photo container
struct PhotoContainerView: View {
    @Binding var inputImage: UIImage?
    let isGenerating: Bool
    let editedImage: UIImage?
    let depthMapImage: UIImage?
    @Binding var sliderPosition: CGFloat
    @Binding var showSlider: Bool
    let onAddTap: () -> Void
    let onReplaceTap: () -> Void
    let onAvatarTap: () -> Void     // NEW
    let onSaveTap: () -> Void

    var body: some View {
           ZStack {
               // ── NEW: dynamic blurred background ──────────────────────────────
               if let bg = editedImage ?? inputImage {          // fall back if editedImage is nil
                   Image(uiImage: bg)
                       .resizable()
                       .scaledToFill()                          // fills width *and* height
                       .blur(radius: 7)                         // ⟵ requested blur
                       .ignoresSafeArea()                       // under status-/home-bars
               }

               // existing foreground content
               PhotoWithRefreshOverlay(
                   originalImage: inputImage,
                   editedImage: editedImage,
                   depthMapImage: depthMapImage,
                   isGenerating: isGenerating,
                   sliderPosition: $sliderPosition,
                   showSlider: $showSlider,
                   onReplaceTap: onReplaceTap,
                   onAddTap: onAddTap,
                   onAvatarTap: onAvatarTap,
                   onSaveTap: onSaveTap
               )
           }
       }


    @ViewBuilder private var backgroundView: some View {
        if let img = inputImage {
            Image(uiImage: img).resizable().scaledToFill().blur(radius: 120).overlay(Color.black.opacity(0.4))
        } else {
            Color.black.opacity(0.6)
        }
    }
}
