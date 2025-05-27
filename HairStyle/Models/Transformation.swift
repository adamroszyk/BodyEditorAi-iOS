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
/// Nine sample transformations for onboarding
let onboardingTransformations: [Transformation] = [

    Transformation(
        beforeImageName: "remove_before",
        afterImageName:  "remove_after",
        caption: "Clutter? Poof—gone 🗑️✨"
    ),

    Transformation(
        beforeImageName: "pro_before",
        afterImageName:  "pro_after",
        caption: "Corporate glow-up in 1 tap 💼"
    ),

    Transformation(
        beforeImageName: "body_before",
        afterImageName:  "body_after",
        caption: "Beach-bod confidence 🏖️🔥"
    ),

    Transformation(
        beforeImageName: "hug_before",
        afterImageName:  "hug_after",
        caption: "Selfie + wild animal encounter = viral 🐻🤗"
    ),

    Transformation(
        beforeImageName: "classy_before",
        afterImageName:  "classy_after",
        caption: "Bond vibes on the Riviera 🤵🏖️"
    ),

   /* Transformation(
        beforeImageName: "fix_before",
        afterImageName:  "fix_after",
        caption: "Saved that blurry memory 🛠️📸"
    ),*/

    Transformation(
        beforeImageName: "hair_before",
        afterImageName:  "hair_after",
        caption: "Big-hair energy 💇‍♀️🚀"
    ),

    Transformation(
        beforeImageName: "smile_before",
        afterImageName:  "smile_after",
        caption: "Turn that grin on 😁"
    ),

    Transformation(
        beforeImageName: "phone_before",
        afterImageName:  "phone_after",
        caption: "Hands-free selfie magic 📱✂️"
    )
]

