//
//  AspectLimitedSingleImageView.swift
//  HairStyle
//
//  Created by Adam Roszyk on 3/22/25.
//
import SwiftUI
import PhotosUI
import Vision

struct AspectLimitedSingleImageView: View {
    let image: UIImage
    @Binding var showSlider: Bool
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .onTapGesture {
                withAnimation {
                    showSlider = false
                }
            }
    }
}
