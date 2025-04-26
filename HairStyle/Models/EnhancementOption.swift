//
//  EnhancementOption.swift
//  HairStyle
//
//  Created by adam on 25/04/2025.
//


//
//  BodyEnhancementPrompts.swift
//  HairStyle
//
//  Created by assistant on 25/04/2025.
//

import Foundation

/// A single enhancement option for a given body area.
struct EnhancementOption: Identifiable, Equatable {
    let id: String             // unique key
    let title: String          // display name
    let subtitle: String?      // optional secondary label (e.g., "Limited-time free")
    let prompt: String         // AI prompt to send
    let isFree: Bool           // whether this option is free
}

enum BodyEnhancementPrompts {
    static let breast: [EnhancementOption] = [
        EnhancementOption(
            id: "round",
            title: "Round",
            subtitle: nil,
            prompt: "Respectfully enhance chest curvature",
            isFree: true
        ),
        EnhancementOption(
            id: "heart_shaped",
            title: "Heart-shaped",
            subtitle: "Limited-time free",
            prompt: "Enhance chest into a heart-shaped bust",
            isFree: true
        ),
        EnhancementOption(
            id: "superlift",
            title: "Superlift",
            subtitle: nil,
            prompt: "Apply superlift enhancement to chest",
            isFree: false
        ),
        EnhancementOption(
            id: "pointy",
            title: "Pointy Nipple",
            subtitle: nil,
            prompt: "Respectfully feature pointy nipple visibly forming under a realistic fabric ",
            isFree: false
        )
    ]

    static let belly: [EnhancementOption] = [
        EnhancementOption(
            id: "flat_abs",
            title: "Flat Abs",
            subtitle: nil,
            prompt: "Respectfully slim and flatten the belly and waist",
            isFree: true
        ),
        EnhancementOption(
            id: "hourglass",
            title: "Hourglass",
            subtitle: nil,
            prompt: "Respectfully enhance the waist-to-hip curve",
            isFree: false
        ),
        EnhancementOption(
            id: "defined_abs",
            title: "Defined Abs",
            subtitle: nil,
            prompt: "Respectfully Enhance the abdominal abs",
            isFree: false
        ),
        EnhancementOption(
            id: "sculpted_core",
            title: "Sculpted Core",
            subtitle: nil,
            prompt: "Respectfully Sculpt and refine the core muscles for a balanced",
            isFree: true
        ),
        EnhancementOption(
            id: "chiseled_midsection",
            title: "Chiseled Midsection",
            subtitle: nil,
            prompt: "Respectfully enhance the lines of the midsection abs",
            isFree: false
        )
    ]

    static let buttock: [EnhancementOption] = [
        EnhancementOption(
            id: "lift",
            title: "Lift",
            subtitle: nil,
            prompt: "Lift and sculpt the buttocks for a firmer look",
            isFree: true
        ),
        EnhancementOption(
            id: "round",
            title: "Round",
            subtitle: nil,
            prompt: "Enhance roundness for a curvier silhouette",
            isFree: false
        ),
        EnhancementOption(
            id: "heart_shaped",
            title: "Heart-shaped",
            subtitle: "Limited-time free",
            prompt: "Respectfully reshape glutes into a heart-shaped form",
            isFree: true
        ),
        EnhancementOption(
            id: "superlift",
            title: "Superlift",
            subtitle: nil,
            prompt: "Apply superlift enhancement to buttocks for maximum elevation",
            isFree: false
        ),
        EnhancementOption(
            id: "sculpted_glutes",
            title: "Sculpted Glutes",
            subtitle: nil,
            prompt: "Respectfully define and sculpt the glute muscles for a toned look",
            isFree: false
        ),
        EnhancementOption(
            id: "perky",
            title: "Perky",
            subtitle: nil,
            prompt: "Respectfully perk up the buttocks for a youthful, lifted appearance",
            isFree: true
        ),
        EnhancementOption(
            id: "voluminous",
            title: "Voluminous",
            subtitle: nil,
            prompt: "Enhance volume and roundness for fuller, more pronounced glutes",
            isFree: false
        )
    ]
    static let muscle: [EnhancementOption] = [
        EnhancementOption(
            id: "tone",
            title: "Upper Body",
            subtitle: nil,
            prompt: "Respectfully increase the muscle shape on neck and upper body",
            isFree: true
        ),
        EnhancementOption(
            id: "sculpt",
            title: "Arms & Forearms",
            subtitle: nil,
            prompt: "Respectfully enhance the muscle shape on the arms and forearms",
            isFree: false
        ),
        EnhancementOption(
            id: "bicep_peak",
            title: "Bicep Peak",
            subtitle: nil,
            prompt: "Respectfully accentuate the bicep peak for a more pronounced flex",
            isFree: false
        ),
        EnhancementOption(
            id: "tricep_tone",
            title: "Tricep Tone",
            subtitle: nil,
            prompt: "Respectfully slim and tone the triceps for sleek definition",
            isFree: true
        ),
        EnhancementOption(
            id: "vascular_forearms",
            title: "Vascular Forearms",
            subtitle: "Limited-time free",
            prompt: "Respectfully highlight forearm veins and muscle separation",
            isFree: true
        ),
        EnhancementOption(
            id: "forearm_definition",
            title: "Forearm Definition",
            subtitle: nil,
            prompt: "Respectfully define the forearm muscles for enhanced detail",
            isFree: false
        ),
        EnhancementOption(
            id: "arm_strength",
            title: "Strength Boost",
            subtitle: nil,
            prompt: "Respectfully add subtle bulk to arms",
            isFree: false
        )
    ]


    static let waist: [EnhancementOption] = [
        EnhancementOption(
            id: "slim",
            title: "Slim",
            subtitle: nil,
            prompt: "Slim and cinch the waist",
            isFree: true
        ),
        EnhancementOption(
            id: "curve",
            title: "Curve",
            subtitle: nil,
            prompt: "Enhance waist curves for definition",
            isFree: false
        )
    ]

    static let hair: [EnhancementOption] = [
        EnhancementOption(
            id: "volume",
            title: "Volume",
            subtitle: nil,
            prompt: "Add natural volume and body to hair",
            isFree: true
        ),
        EnhancementOption(
            id: "smooth",
            title: "Smooth",
            subtitle: nil,
            prompt: "Smooth hair and reduce frizz",
            isFree: false
        ),
        EnhancementOption(
            id: "silver_blonde",
            title: "Silver Blonde",
            subtitle: nil,
            prompt: "Transform hair to a chic silver blonde shade",
            isFree: true
        ),
        EnhancementOption(
            id: "bob_cut",
            title: "Bob Cut",
            subtitle: nil,
            prompt: "Give hair a modern bob cut",
            isFree: false
        ),
        EnhancementOption(
            id: "afro",
            title: "Afro",
            subtitle: "Limited-time free",
            prompt: "Define natural afro texture and volume",
            isFree: true
        ),
        EnhancementOption(
            id: "pixie_cut",
            title: "Pixie Cut",
            subtitle: nil,
            prompt: "Create a stylish pixie cut",
            isFree: false
        ),
        EnhancementOption(
            id: "ombre",
            title: "Ombre",
            subtitle: nil,
            prompt: "Add subtle ombre color blending",
            isFree: true
        ),
        EnhancementOption(
            id: "highlights",
            title: "Highlights",
            subtitle: nil,
            prompt: "Incorporate bright highlights throughout hair",
            isFree: false
        ),
        EnhancementOption(
            id: "balayage",
            title: "Balayage",
            subtitle: nil,
            prompt: "Apply a natural balayage painting technique",
            isFree: false
        ),
        EnhancementOption(
            id: "loose_curls",
            title: "Loose Curls",
            subtitle: nil,
            prompt: "Add loose, bouncy curls for movement",
            isFree: true
        ),
        EnhancementOption(
            id: "beach_waves",
            title: "Beach Waves",
            subtitle: "Limited-time free",
            prompt: "Create soft, effortless beach waves",
            isFree: true
        ),
        EnhancementOption(
            id: "sleek_straight",
            title: "Sleek Straight",
            subtitle: nil,
            prompt: "Smooth hair into a sleek, straight style",
            isFree: false
        )
    ]


    static let nose: [EnhancementOption] = [
        EnhancementOption(
            id: "refine",
            title: "Refine",
            subtitle: nil,
            prompt: "Refine the nose shape subtly",
            isFree: true
        ),
        EnhancementOption(
            id: "slim",
            title: "Slim",
            subtitle: nil,
            prompt: "Slim down the nose bridge",
            isFree: false
        )
    ]

    static let eyes: [EnhancementOption] = [
        EnhancementOption(
            id: "brighten",
            title: "Brighten",
            subtitle: nil,
            prompt: "Brighten eyes and reduce shadows",
            isFree: true
        ),
        EnhancementOption(
            id: "enlarge",
            title: "Enlarge",
            subtitle: nil,
            prompt: "Subtly enlarge the eyes",
            isFree: false
        )
    ]

    static let skin: [EnhancementOption] = [
        EnhancementOption(
            id: "smooth",
            title: "Smooth",
            subtitle: nil,
            prompt: "Smooth skin texture and even tone",
            isFree: true
        ),
        EnhancementOption(
            id: "glow",
            title: "Glow",
            subtitle: nil,
            prompt: "Add a healthy, radiant glow",
            isFree: false
        )
    ]

    static let face: [EnhancementOption] = [
        EnhancementOption(
            id: "contour",
            title: "Contour",
            subtitle: nil,
            prompt: "Add subtle contour to face",
            isFree: true
        ),
        EnhancementOption(
            id: "smooth",
            title: "Smooth",
            subtitle: nil,
            prompt: "Smooth overall facial features",
            isFree: false
        )
    ]

    static let lips: [EnhancementOption] = [
        EnhancementOption(
            id: "full",
            title: "Full",
            subtitle: nil,
            prompt: "Enhance lip fullness",
            isFree: true
        ),
        EnhancementOption(
            id: "color",
            title: "Color",
            subtitle: nil,
            prompt: "Add natural lip color",
            isFree: false
        )
    ]

    static let leg: [EnhancementOption] = [
        EnhancementOption(
            id: "slim",
            title: "Slim",
            subtitle: nil,
            prompt: "Slim and lengthen legs",
            isFree: true
        ),
        EnhancementOption(
            id: "tone",
            title: "Tone",
            subtitle: nil,
            prompt: "Tone leg muscles for definition",
            isFree: false
        )
    ]
    
    static let jewellery: [EnhancementOption] = [
        EnhancementOption(
                id: "gold_hoop_minimal",
                title: "Minimal Gold Hoops",
                subtitle: nil,
                prompt: "Add sleek, minimalistic gold hoop earrings",
                isFree: true
            ),
            EnhancementOption(
                id: "delicate_gold_chain",
                title: "Delicate Gold Chain",
                subtitle: nil,
                prompt: "Add a thin, delicate gold chain necklace",
                isFree: true
            ),
            EnhancementOption(
                id: "stackable_bands",
                title: "Stackable Bands",
                subtitle: nil,
                prompt: "Add a set of minimal stackable gold rings",
                isFree: false
            ),
            EnhancementOption(
                id: "geometric_studs",
                title: "Geometric Studs",
                subtitle: nil,
                prompt: "Add small geometric stud earrings in gold",
                isFree: true
            ),
            EnhancementOption(
                id: "thin_gold_bangle",
                title: "Thin Gold Bangle",
                subtitle: nil,
                prompt: "Add a slender, minimalistic gold bangle bracelet",
                isFree: false
            ),
            EnhancementOption(
                id: "gold_bar_necklace",
                title: "Gold Bar Necklace",
                subtitle: "Limited-time free",
                prompt: "Add a minimalist gold bar pendant necklace",
                isFree: true
            ),
            EnhancementOption(
                id: "link_chain_bracelet",
                title: "Link Chain Bracelet",
                subtitle: nil,
                prompt: "Add a bold gold link chain bracelet",
                isFree: false
            ),
            EnhancementOption(
                id: "pearls_and_gold",
                title: "Pearls & Gold",
                subtitle: nil,
                prompt: "Add a blend of pearls with gold accents",
                isFree: true
            ),
            EnhancementOption(
                id: "gold_cuff_minimal",
                title: "Minimal Gold Cuff",
                subtitle: nil,
                prompt: "Add a clean, minimalistic gold cuff bracelet",
                isFree: false
            ),
            EnhancementOption(
                id: "layered_gold_chains",
                title: "Layered Gold Chains",
                subtitle: nil,
                prompt: "Add multiple thin gold chain necklaces for layering",
                isFree: false
            ),
        EnhancementOption(
            id: "earrings",
            title: "Earrings",
            subtitle: nil,
            prompt: "Add stylish earrings",
            isFree: true
        ),
        EnhancementOption(
            id: "necklace",
            title: "Necklace",
            subtitle: nil,
            prompt: "Add a beautiful necklace",
            isFree: false
        ),
        EnhancementOption(
            id: "bracelet",
            title: "Bracelet",
            subtitle: nil,
            prompt: "Add a delicate bracelet around the wrist",
            isFree: true
        ),
        EnhancementOption(
            id: "ring",
            title: "Ring",
            subtitle: nil,
            prompt: "Add a sparkling ring to the fingers",
            isFree: false
        ),
        EnhancementOption(
            id: "anklet",
            title: "Anklet",
            subtitle: "Limited-time free",
            prompt: "Add a subtle anklet for a refined touch",
            isFree: true
        ),
        EnhancementOption(
            id: "chandelier_earrings",
            title: "Chandelier Earrings",
            subtitle: nil,
            prompt: "Add elegant chandelier-style earrings",
            isFree: false
        ),
        EnhancementOption(
            id: "hoop_earrings",
            title: "Hoop Earrings",
            subtitle: nil,
            prompt: "Add classic hoop earrings",
            isFree: true
        ),
        EnhancementOption(
            id: "cuff_bracelet",
            title: "Cuff Bracelet",
            subtitle: nil,
            prompt: "Add a bold cuff bracelet to the wrist",
            isFree: false
        ),
        EnhancementOption(
            id: "choker",
            title: "Choker",
            subtitle: nil,
            prompt: "Add a sleek choker around the neck",
            isFree: true
        ),
        EnhancementOption(
            id: "pendant",
            title: "Pendant",
            subtitle: nil,
            prompt: "Add a charming pendant on a fine chain",
            isFree: false
        ),
        EnhancementOption(
            id: "brooch",
            title: "Brooch",
            subtitle: nil,
            prompt: "Add a decorative brooch for a vintage flair",
            isFree: true
        ),
        EnhancementOption(
            id: "watch",
            title: "Watch",
            subtitle: nil,
            prompt: "Add a stylish wristwatch",
            isFree: false
        )
    ]

    // New Eyewear options
    static let eyewear: [EnhancementOption] = [
        EnhancementOption(
            id: "eyewear",
            title: "Eyewear",
            subtitle: nil,
            prompt: "Add stylish eyewear frames",
            isFree: true
        ),
        EnhancementOption(
            id: "sunglasses",
            title: "Sunglasses",
            subtitle: nil,
            prompt: "Add trendy sunglasses with reflective lenses",
            isFree: false
        ),
        EnhancementOption(
            id: "reading_glasses",
            title: "Reading Glasses",
            subtitle: "Limited-time free",
            prompt: "Add elegant reading glasses with thin frames",
            isFree: true
        ),
        EnhancementOption(
            id: "aviators",
            title: "Aviator Frames",
            subtitle: nil,
            prompt: "Add classic aviator sunglasses with metal frames",
            isFree: false
        ),
        EnhancementOption(
            id: "wayfarer",
            title: "Wayfarer",
            subtitle: nil,
            prompt: "Add stylish wayfarer-style glasses",
            isFree: true
        ),
        EnhancementOption(
            id: "round_frames",
            title: "Round Frames",
            subtitle: nil,
            prompt: "Add vintage round frame glasses",
            isFree: false
        ),
        EnhancementOption(
            id: "cat_eye",
            title: "Cat-eye",
            subtitle: nil,
            prompt: "Add chic cat-eye glasses for a retro look",
            isFree: true
        ),
        EnhancementOption(
            id: "translucent_frames",
            title: "Translucent Frames",
            subtitle: nil,
            prompt: "Add translucent frame glasses with modern vibe",
            isFree: false
        ),
        EnhancementOption(
            id: "sports_goggles",
            title: "Sports Goggles",
            subtitle: nil,
            prompt: "Add sporty wrap-around goggles",
            isFree: false
        ),
        EnhancementOption(
            id: "steampunk_goggles",
            title: "Steampunk Goggles",
            subtitle: "Limited-time free",
            prompt: "Add decorative steampunk-style goggles",
            isFree: true
        )
    ]
}
