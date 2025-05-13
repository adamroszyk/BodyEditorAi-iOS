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
           EnhancementOption(id: "round",               title: "Round",                subtitle: nil,                prompt: "Respectfully enhance chest curvature",                                             isFree: true),
           EnhancementOption(id: "heart_shaped",        title: "Heart‑shaped",        subtitle: "Limited‑time free", prompt: "Enhance chest into a heart‑shaped bust",                                         isFree: true),
           EnhancementOption(id: "superlift",           title: "Superlift",           subtitle: nil,                prompt: "Apply superlift enhancement to chest",                                           isFree: false),
           EnhancementOption(id: "natural_lift",        title: "Natural Lift",        subtitle: nil,                prompt: "Apply natural lift enhancement to chest",                             isFree: false),
           EnhancementOption(id: "subtle_volume",       title: "Subtle Volume",       subtitle: nil,                prompt: "Respectfully but minimally enhance chest curvature",                           isFree: true),
           EnhancementOption(id: "snatched_cleavage",   title: "Snatched Cleavage",   subtitle: "Limited‑time free", prompt: "Respectfully but subtly enhance chest curvature",                      isFree: true)
       ]

       // MARK: – Belly / Core
       static let belly: [EnhancementOption] = [
           EnhancementOption(id: "flat_abs",            title: "Flat Abs",            subtitle: nil,                prompt: "Respectfully slim and flatten the belly and waist",                               isFree: true),
           EnhancementOption(id: "hourglass",           title: "Hourglass",           subtitle: nil,                prompt: "Respectfully enhance the waist‑to‑hip curve",                                     isFree: false),
           EnhancementOption(id: "defined_abs",         title: "Defined Abs",         subtitle: nil,                prompt: "Respectfully enhance the abdominal abs",                                        isFree: false),
           EnhancementOption(id: "sculpted_core",       title: "Sculpted Core",       subtitle: nil,                prompt: "Respectfully sculpt and refine the core muscles for balance",                   isFree: true),
           EnhancementOption(id: "chiseled_midsection", title: "Chiseled Midsection", subtitle: nil,                prompt: "Respectfully enhance the lines of the midsection abs",                         isFree: false),
           EnhancementOption(id: "snatched_waist",      title: "Snatched Waist",      subtitle: "Limited‑time free", prompt: "Respectfully cinch the waist for a snatched silhouette",                         isFree: true),
           EnhancementOption(id: "vacuum_slim",         title: "Vacuum Slim",         subtitle: nil,                prompt: "Respectfully apply stomach‑vacuum slimming for a flat profile",                 isFree: false),
           EnhancementOption(id: "core_carve",          title: "Core Carve",          subtitle: nil,                prompt: "Respectfully carve deep core lines for athletic definition",                   isFree: false)
       ]

       // MARK: – Buttock / Glutes
       static let buttock: [EnhancementOption] = [
           EnhancementOption(id: "lift",                title: "Lift",                subtitle: nil,                prompt: "Lift and sculpt the buttocks for a firmer look",                              isFree: true),
           EnhancementOption(id: "round",               title: "Round",               subtitle: nil,                prompt: "Enhance roundness for a curvier silhouette",                                   isFree: false),
           EnhancementOption(id: "heart_shaped",        title: "Heart‑shaped",        subtitle: "Limited‑time free", prompt: "Respectfully reshape glutes into a heart‑shaped form",                          isFree: true),
           EnhancementOption(id: "superlift",           title: "Superlift",           subtitle: nil,                prompt: "Apply superlift enhancement to buttocks for maximum elevation",               isFree: false),
           EnhancementOption(id: "sculpted_glutes",     title: "Sculpted Glutes",     subtitle: nil,                prompt: "Respectfully define and sculpt the glute muscles for a toned look",           isFree: false),
           EnhancementOption(id: "perky",               title: "Perky",               subtitle: nil,                prompt: "Respectfully perk up the buttocks for a youthful, lifted appearance",        isFree: true),
           EnhancementOption(id: "voluminous",          title: "Voluminous",          subtitle: nil,                prompt: "Enhance volume and roundness for fuller, more pronounced glutes",            isFree: false),
           EnhancementOption(id: "peach_lift",          title: "Peach Lift",          subtitle: nil,                prompt: "Respectfully lift glutes for a peach‑emoji vibe 🍑",                          isFree: true),
           EnhancementOption(id: "bubble_booty",        title: "Bubble Booty",        subtitle: nil,                prompt: "Respectfully add bubble‑shaped roundness for a playful look",                isFree: false),
           EnhancementOption(id: "brazilian_curve",     title: "Brazilian Curve",     subtitle: "Limited‑time free", prompt: "Respectfully enhance lower‑upper glute transition for Brazilian shape",       isFree: true),
           EnhancementOption(id: "shape_360",           title: "360 Shape",           subtitle: nil,                prompt: "Respectfully smooth and contour hips & glutes for a 360° hourglass",         isFree: false)
       ]

       // MARK: – Muscle / Arms
       static let muscle: [EnhancementOption] = [
           EnhancementOption(id: "tone",                title: "Upper Body",          subtitle: nil,                prompt: "Respectfully increase the muscle shape on neck and upper body",               isFree: true),
           EnhancementOption(id: "sculpt",              title: "Arms & Forearms",     subtitle: nil,                prompt: "Respectfully enhance the muscle shape on the arms and forearms",            isFree: false),
           EnhancementOption(id: "bicep_peak",          title: "Bicep Peak",          subtitle: nil,                prompt: "Respectfully accentuate the bicep peak for a more pronounced flex",        isFree: false),
           EnhancementOption(id: "tricep_tone",         title: "Tricep Tone",         subtitle: nil,                prompt: "Respectfully slim and tone the triceps for sleek definition",              isFree: true),
           EnhancementOption(id: "vascular_forearms",   title: "Vascular Forearms",   subtitle: "Limited‑time free", prompt: "Respectfully highlight forearm veins and muscle separation",                  isFree: true),
           EnhancementOption(id: "forearm_definition",  title: "Forearm Definition",  subtitle: nil,                prompt: "Respectfully define the forearm muscles for enhanced detail",              isFree: false),
           EnhancementOption(id: "arm_strength",        title: "Strength Boost",       subtitle: nil,                prompt: "Respectfully add subtle bulk to arms",                                   isFree: false),
           EnhancementOption(id: "swimmer_build",       title: "Swimmer Build",       subtitle: nil,                prompt: "Respectfully broaden shoulders and taper waist for swimmer aesthetics",     isFree: false),
           EnhancementOption(id: "athlete_tone",        title: "Athlete Tone",        subtitle: nil,                prompt: "Respectfully tone arms for an athletic, sporty vibe",                      isFree: true),
           EnhancementOption(id: "power_flex",          title: "Power Flex",          subtitle: "Limited‑time free", prompt: "Respectfully sharpen muscle definition for a power pose",                     isFree: true)
       ]
    
    // MARK: – Waist
    static let waist: [EnhancementOption] = [
        // Existing
        EnhancementOption(id: "slim",             title: "Slim",             subtitle: nil,                prompt: "Slim and cinch the waist",                                                     isFree: true),
        EnhancementOption(id: "curve",            title: "Curve",            subtitle: nil,                prompt: "Enhance waist curves for definition",                                         isFree: false),
        EnhancementOption(id: "v_shape",          title: "V-Shape",          subtitle: nil,                prompt: "Respectfully sculpt a tapered V-shape waist",                                  isFree: false),
        EnhancementOption(id: "corset_cinch",     title: "Corset Cinch",     subtitle: "Limited-time free", prompt: "Respectfully simulate corset-style waist cinching for TikTok snatch",           isFree: true),

        // New additions
        EnhancementOption(id: "hourglass",        title: "Hourglass",        subtitle: nil,                prompt: "Respectfully sculpt an hourglass silhouette",                                  isFree: false),
        EnhancementOption(id: "micro_cinch",      title: "Micro Cinch",      subtitle: "Limited-time free", prompt: "Respectfully simulate an ultra-cinched micro waist",                           isFree: true),
        EnhancementOption(id: "athletic_tone",    title: "Athletic Tone",    subtitle: nil,                prompt: "Define a toned, athletic waistline",                                           isFree: false),
        EnhancementOption(id: "balanced_curve",   title: "Balanced Curve",   subtitle: nil,                prompt: "Add gentle definition for a balanced waist curve",                             isFree: true),
        EnhancementOption(id: "dream_sculpt",     title: "Dream Sculpt",     subtitle: nil,                prompt: "Sculpt a dreamy snatched waistline fit for viral looks",                       isFree: false),
        EnhancementOption(id: "vapor_snatch",     title: "Vapor Snatch",     subtitle: "Limited-time free", prompt: "Respectfully vapor-snatch the waist for an ethereal cinched look",             isFree: true),
        EnhancementOption(id: "soft_taper",       title: "Soft Taper",       subtitle: nil,                prompt: "Create a soft, natural waist taper",                                           isFree: true),
        EnhancementOption(id: "precision_trim",   title: "Precision Trim",   subtitle: nil,                prompt: "Apply precise trimming for a sleek waist contour",                             isFree: false)
    ]


       // MARK: – Hair
       static let hair: [EnhancementOption] = [
           EnhancementOption(id: "volume",              title: "Volume",              subtitle: nil,                prompt: "Add natural volume and body to hair",                                    isFree: true),
           EnhancementOption(id: "smooth",              title: "Smooth",              subtitle: nil,                prompt: "Smooth hair and reduce frizz",                                          isFree: false),
           EnhancementOption(id: "silver_blonde",       title: "Silver Blonde",       subtitle: nil,                prompt: "Transform hair to a chic silver blonde shade",                            isFree: true),
           EnhancementOption(id: "bob_cut",             title: "Bob Cut",             subtitle: nil,                prompt: "Give hair a modern bob cut",                                            isFree: false),
           EnhancementOption(id: "afro",                title: "Afro",                subtitle: "Limited‑time free", prompt: "Define natural afro texture and volume",                                    isFree: true),
           EnhancementOption(id: "pixie_cut",           title: "Pixie Cut",           subtitle: nil,                prompt: "Create a stylish pixie cut",                                           isFree: false),
           EnhancementOption(id: "ombre",               title: "Ombre",               subtitle: nil,                prompt: "Add subtle ombre color blending",                                       isFree: true),
           EnhancementOption(id: "highlights",          title: "Highlights",          subtitle: nil,                prompt: "Incorporate bright highlights throughout hair",                           isFree: false),
           EnhancementOption(id: "balayage",            title: "Balayage",            subtitle: nil,                prompt: "Apply a natural balayage painting technique",                             isFree: false),
           EnhancementOption(id: "loose_curls",         title: "Loose Curls",         subtitle: nil,                prompt: "Add loose, bouncy curls for movement",                                   isFree: true),
           EnhancementOption(id: "beach_waves",         title: "Beach Waves",         subtitle: "Limited‑time free", prompt: "Create soft, effortless beach waves",                                      isFree: true),
           EnhancementOption(id: "sleek_straight",      title: "Sleek Straight",      subtitle: nil,                prompt: "Smooth hair into a sleek, straight style",                                 isFree: false),
           EnhancementOption(id: "butterfly_layers",    title: "Butterfly Layers",    subtitle: nil,                prompt: "Add TikTok trending butterfly layers for airy movement",                   isFree: true),
           EnhancementOption(id: "curtain_bangs",       title: "Curtain Bangs",       subtitle: nil,                prompt: "Add soft curtain bangs framing the face",                                isFree: false),
           EnhancementOption(id: "mermaid_waves",       title: "Mermaid Waves",       subtitle: "Limited‑time free", prompt: "Create long, flowing mermaid waves with shine",                              isFree: true),
           EnhancementOption(id: "copper_glow",         title: "Copper Glow",         subtitle: nil,                prompt: "Transform hair to a warm LA‑sun copper glow",                              isFree: false),
           EnhancementOption(id: "pastel_pink",         title: "Pastel Pink",         subtitle: nil,                prompt: "Tint hair a playful pastel pink",                                       isFree: false)
       ]
    // MARK: – Nose
    static let nose: [EnhancementOption] = [
        // Existing
        EnhancementOption(id: "refine",           title: "Refine",            subtitle: nil,                 prompt: "Refine the nose shape subtly",                                                      isFree: true),
        EnhancementOption(id: "slim",             title: "Slim",              subtitle: nil,                 prompt: "Slim down the nose bridge",                                                        isFree: false),
        EnhancementOption(id: "button_tip",       title: "Button Tip",        subtitle: nil,                 prompt: "Respectfully soften and round the nose tip for a button effect",                  isFree: true),
        EnhancementOption(id: "soft_contour",     title: "Soft Contour",      subtitle: nil,                 prompt: "Respectfully add gentle shadow for a softly contoured nose",                      isFree: false),

        // New additions
        EnhancementOption(id: "pixie_lift",       title: "Pixie Lift",        subtitle: nil,                 prompt: "Respectfully lift and refine the nose tip for a pixie-esque profile",             isFree: false),
        EnhancementOption(id: "snatched_bridge",  title: "Snatched Bridge",   subtitle: "Limited-time free", prompt: "Respectfully slim and sharpen the nose bridge for a snatched look",               isFree: true),
        EnhancementOption(id: "doll_nose",        title: "Doll Nose",         subtitle: nil,                 prompt: "Respectfully sculpt a petite, doll-like nose shape",                               isFree: false),
        EnhancementOption(id: "airbrush_narrow",  title: "Airbrush Narrow",   subtitle: nil,                 prompt: "Airbrush-style narrowing for a photo-ready nose",                                  isFree: true),
        EnhancementOption(id: "slope_sculpt",     title: "Slope Sculpt",      subtitle: nil,                 prompt: "Respectfully sculpt a gentle ski-slope nose profile",                              isFree: false),
        EnhancementOption(id: "natural_polish",   title: "Natural Polish",    subtitle: "Limited-time free", prompt: "Add subtle refinement for a naturally polished nose",                               isFree: true),
        EnhancementOption(id: "cupids_dip",       title: "Cupid’s Dip",       subtitle: nil,                 prompt: "Create a delicate dip just beneath the tip for a Cupid-inspired contour",          isFree: false),
        EnhancementOption(id: "halo_highlight",   title: "Halo Highlight",    subtitle: nil,                 prompt: "Respectfully add soft highlight to accentuate the nose bridge",                   isFree: true)
    ]


    // MARK: – Eyes
    static let eyes: [EnhancementOption] = [
        // Existing
        EnhancementOption(id: "brighten",         title: "Brighten",          subtitle: nil,                 prompt: "Brighten eyes and reduce shadows",                                                  isFree: true),
        EnhancementOption(id: "enlarge",          title: "Enlarge",           subtitle: nil,                 prompt: "Subtly enlarge the eyes",                                                          isFree: false),
        EnhancementOption(id: "fox_lift",         title: "Fox Lift",          subtitle: nil,                 prompt: "Respectfully lift outer corners for a fox-eye trend",                               isFree: true),
        EnhancementOption(id: "doll_eyes",        title: "Doll Eyes",         subtitle: "Limited-time free", prompt: "Respectfully widen and round eyes for a doll-like effect",                           isFree: true),
        EnhancementOption(id: "winged_liner",     title: "Winged Liner",      subtitle: nil,                 prompt: "Apply a clean winged-liner illusion for sharp definition",                          isFree: false),

        // New additions
        EnhancementOption(id: "siren_lift",       title: "Siren Lift",        subtitle: nil,                 prompt: "Respectfully raise outer corners for a sultry siren-eye look",                     isFree: false),
        EnhancementOption(id: "soft_sparkle",     title: "Soft Sparkle",      subtitle: nil,                 prompt: "Gently add subtle shimmer for softly sparkling eyes",                               isFree: true),
        EnhancementOption(id: "mega_pop",         title: "Mega Pop",          subtitle: "Limited-time free", prompt: "Intensify iris clarity for ultra-pop TikTok eyes",                                   isFree: true),
        EnhancementOption(id: "pastel_twinkle",   title: "Pastel Twinkle",    subtitle: nil,                 prompt: "Tint eyes with a pastel twinkle for dreamy vibes",                                   isFree: false),
        EnhancementOption(id: "graphic_flick",    title: "Graphic Flick",     subtitle: nil,                 prompt: "Apply a bold graphic liner flick for statement eyes",                               isFree: false),
        EnhancementOption(id: "dreamy_haze",      title: "Dreamy Haze",       subtitle: nil,                 prompt: "Add a soft-focus haze for ethereal eyes",                                           isFree: true),
        EnhancementOption(id: "icicle_bright",    title: "Icicle Bright",     subtitle: "Limited-time free", prompt: "Cool-tone brighten for an icy, refreshed gaze",                                      isFree: true),
        EnhancementOption(id: "subtle_smoke",     title: "Subtle Smoke",      subtitle: nil,                 prompt: "Respectfully add a gentle smoky contour for depth",                                 isFree: false)
    ]

    // MARK: – Skin
    static let skin: [EnhancementOption] = [
        // Existing
        EnhancementOption(id: "smooth",        title: "Smooth",        subtitle: nil,                 prompt: "Smooth skin texture and even tone",                             isFree: true),
        EnhancementOption(id: "glow",          title: "Glow",          subtitle: nil,                 prompt: "Add a healthy, radiant glow",                                   isFree: false),

        // New additions
        EnhancementOption(id: "airbrush",      title: "Airbrush",      subtitle: nil,                 prompt: "Apply studio-grade airbrush smoothing and even tones",           isFree: false),
        EnhancementOption(id: "glass_skin",    title: "Glass Skin",    subtitle: "Limited-time free", prompt: "Respectfully create a dewy glass-skin finish",                    isFree: true),
        EnhancementOption(id: "peachy_blush",  title: "Peachy Blush",  subtitle: nil,                 prompt: "Add a soft peachy flush for a healthy TikTok blush look",        isFree: true),
        EnhancementOption(id: "bronze_tan",    title: "Bronze Tan",    subtitle: nil,                 prompt: "Apply a subtle sun-kissed bronze tan",                           isFree: false),
        EnhancementOption(id: "freckle_kiss",  title: "Freckle Kiss",  subtitle: "Limited-time free", prompt: "Sprinkle natural-looking sun freckles for playful vibes",        isFree: true),
        EnhancementOption(id: "clarity_boost", title: "Clarity Boost", subtitle: nil,                 prompt: "Reduce blemishes and enhance skin clarity",                      isFree: false),
        EnhancementOption(id: "matte_filter",  title: "Matte Filter",  subtitle: nil,                 prompt: "Respectfully mattify skin to reduce shine",                      isFree: true),
        EnhancementOption(id: "pearl_highlight",title: "Pearl Highlight",subtitle: nil,               prompt: "Apply soft pearl highlights for luminous skin accents",          isFree: false)
    ]

    // MARK: – Face
    static let face: [EnhancementOption] = [
        // Existing
        EnhancementOption(id: "contour",        title: "Contour",        subtitle: nil,                 prompt: "Add subtle contour to face",                                   isFree: true),
        EnhancementOption(id: "smooth",         title: "Smooth",         subtitle: nil,                 prompt: "Smooth overall facial features",                               isFree: false),

        // New additions
        EnhancementOption(id: "jawline_define", title: "Jawline Define", subtitle: nil,                 prompt: "Sharpen jawline for a defined look",                           isFree: false),
        EnhancementOption(id: "cheek_lift",     title: "Cheek Lift",     subtitle: nil,                 prompt: "Respectfully lift and sculpt cheekbones",                      isFree: true),
        EnhancementOption(id: "v_face",         title: "V-Face",         subtitle: "Limited-time free", prompt: "Respectfully sculpt a sleek V-shaped face",                    isFree: true),
        EnhancementOption(id: "baby_soft",      title: "Baby Soft",      subtitle: nil,                 prompt: "Subtly soften features for a baby-face effect",                isFree: true),
        EnhancementOption(id: "siren_sculpt",   title: "Siren Sculpt",   subtitle: nil,                 prompt: "Respectfully sculpt striking features for a siren look",       isFree: false),
        EnhancementOption(id: "golden_ratio",   title: "Golden Ratio",   subtitle: nil,                 prompt: "Refine facial proportions toward the golden ratio",            isFree: false),
        EnhancementOption(id: "soft_highlight", title: "Soft Highlight", subtitle: "Limited-time free", prompt: "Add gentle highlighted glow to lift features",                 isFree: true),
        EnhancementOption(id: "chin_tuck",      title: "Chin Tuck",      subtitle: nil,                 prompt: "Subtly tuck chin for a refined profile",                       isFree: false)
    ]

    // MARK: – Lips
    static let lips: [EnhancementOption] = [
        // Existing
        EnhancementOption(id: "full",           title: "Full",            subtitle: nil,                 prompt: "Enhance lip fullness",                                                         isFree: true),
        EnhancementOption(id: "color",          title: "Color",           subtitle: nil,                 prompt: "Add natural lip color",                                                        isFree: false),

        // New additions
        EnhancementOption(id: "gloss_sheen",    title: "Gloss Sheen",      subtitle: "Limited-time free", prompt: "Add a high-shine gloss sheen for viral glow",                                    isFree: true),
        EnhancementOption(id: "soft_ombre",     title: "Soft Ombré",       subtitle: nil,                 prompt: "Apply a subtle ombré gradient for fuller-looking lips",                          isFree: false),
        EnhancementOption(id: "cupid_bow",      title: "Cupid’s Bow",      subtitle: nil,                 prompt: "Enhance Cupid’s bow definition for a crisp lip shape",                           isFree: false),
        EnhancementOption(id: "velvet_matte",   title: "Velvet Matte",     subtitle: nil,                 prompt: "Give lips a plush velvet-matte finish",                                         isFree: false),
        EnhancementOption(id: "plump_pout",     title: "Plump Pout",       subtitle: "Limited-time free", prompt: "Respectfully plump lips for a TikTok-ready pout",                                isFree: true),
        EnhancementOption(id: "blushed_tint",   title: "Blushed Tint",     subtitle: nil,                 prompt: "Add a soft blushed tint for a natural flush",                                   isFree: true),
        EnhancementOption(id: "frosted_shine",  title: "Frosted Shine",    subtitle: nil,                 prompt: "Apply shimmering frosted shine for nostalgic Y2K vibes",                        isFree: false)
    ]
    // MARK: – Legs
    static let leg: [EnhancementOption] = [
        // Existing
        EnhancementOption(id: "slim",              title: "Slim",               subtitle: nil,                 prompt: "Slim and lengthen legs",                                                          isFree: true),
        EnhancementOption(id: "tone",              title: "Tone",               subtitle: nil,                 prompt: "Tone leg muscles for definition",                                                isFree: false),

        // New additions
        EnhancementOption(id: "barbie_length",     title: "Barbie Length",      subtitle: "Limited-time free", prompt: "Lengthen and refine legs for Barbiecore proportions",                              isFree: true),
        EnhancementOption(id: "model_stretch",     title: "Model Stretch",      subtitle: nil,                 prompt: "Respectfully elongate legs for a runway-model stretch",                          isFree: false),
        EnhancementOption(id: "athletic_sculpt",   title: "Athletic Sculpt",    subtitle: nil,                 prompt: "Enhance muscle definition for a sporty leg sculpt",                               isFree: false),
        EnhancementOption(id: "pilates_tone",      title: "Pilates Tone",       subtitle: nil,                 prompt: "Add gentle Pilates-inspired toning",                                             isFree: true),
        EnhancementOption(id: "sun_kissed_glow",   title: "Sun-Kissed Glow",    subtitle: nil,                 prompt: "Apply a subtle sun-bronzed glow to legs",                                        isFree: false),
        EnhancementOption(id: "glass_shine",       title: "Glass Shine",        subtitle: "Limited-time free", prompt: "Add glossy glass-skin shine for viral leg sheen",                                 isFree: true),
        EnhancementOption(id: "dreamy_slim",       title: "Dreamy Slim",        subtitle: nil,                 prompt: "Soft-focus slim effect for dreamy long legs",                                    isFree: false),
        EnhancementOption(id: "v_line_define",     title: "V-Line Define",      subtitle: nil,                 prompt: "Sculpt inner-thigh V-line for crisp definition",                                 isFree: false)
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
