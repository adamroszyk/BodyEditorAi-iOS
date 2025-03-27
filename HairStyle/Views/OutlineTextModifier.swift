//
//  OutlineTextModifier.swift
//  HairStyle
//
//  Created by adam on 24/03/2025.
//

import SwiftUI
import PhotosUI
import Vision

struct OutlineTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.black.opacity(0.3))
                .offset(x: -1, y: -1)
            content
                .foregroundColor(.black.opacity(0.3))
                .offset(x: 1, y: -1)
            content
                .foregroundColor(.black.opacity(0.3))
                .offset(x: -1, y: 1)
            content
                .foregroundColor(.black.opacity(0.3))
                .offset(x: 1, y: 1)
            content
        }
    }
}

struct IdentityModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
