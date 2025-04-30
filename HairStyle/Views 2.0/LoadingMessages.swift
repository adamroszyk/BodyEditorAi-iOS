//
//  LoadingMessages.swift
//  HairStyle
//
//  Created by adam on 30/04/2025.
//


//  LoadingMessages.swift
//  PicUp
//  Generated 30‑04‑2025 – A sprinkle of Gen‑Z flavoured loading banter ✨
//
//  Call `LoadingMessages.random()` whenever you need a fresh status line.
//  Example:
//      Text(LoadingMessages.random())
//
//  The list can be expanded or localized later.

import Foundation

enum LoadingMessages {
    static let all: [String] = [
        "Casting ✨ filters… hold my boba!",
        "Crunching pixels like kettle chips…",
        "Tweaking the vibe parameters (scientifically, of course)…",
        "GPU is doing burpees—almost done!",
        "Uploading imagination to the cloud ☁️…",
        "Painting happy little bytes…",
        "Assembling AI drip, please stand by…",
        "Turning coffee into gradients…",
        "Charging the creativity capacitor ⚡️…",
        "Optimizing the funniness algorithm…",
        "Feeding hamsters more voltage…",
        "Rendering in ✨ Ultra‑Mega‑1080p ✨…",
        "Spinning up rainbow shaders…",
        "Injecting extra serotonin into pixels…",
        "Reticulating splines 2.0…",
        "Aligning photonic chakras…",
        "Manifesting your best self…",
        "Negotiating with the color wheel…",
        "Loading swag assets (almost there)…",
        "Finalizing epicness—do not unplug!"
    ]

    /// Returns a random playful loading string.
    static func random() -> String {
        all.randomElement() ?? "Generating… hang tight!"
    }
}
