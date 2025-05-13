//
//  Transformation.swift
//  HairStyle
//
//  Created by adam on 12/05/2025.
//


//
//  Transformations.swift
//

import Foundation

/// One transformation shown in onboarding (3 total for now)
struct Transformation: Identifiable {
    let id = UUID()
    let beforeImageName: String   // asset name for “before” photo
    let afterImageName: String    // asset name for “after” photo
    let caption: String           // TikTok-style text under the image
}

/// Three sample transformations – swap the asset names for your own
let onboardingTransformations: [Transformation] = [
    Transformation(
        beforeImageName: "before_curl",
        afterImageName:  "after_curl",
        caption: "Bouncy curls in seconds ✨"
    ),
    Transformation(
        beforeImageName: "before_volume",
        afterImageName:  "after_volume",
        caption: "Instant volume, zero effort 🔥"
    ),
    Transformation(
        beforeImageName: "before_color",
        afterImageName:  "after_color",
        caption: "Switch shades like magic 🎨"
    )
]
