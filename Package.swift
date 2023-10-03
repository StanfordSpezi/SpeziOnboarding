// swift-tools-version:5.7

//
// This source file is part of the Stanford Spezi open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "SpeziOnboarding",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "SpeziOnboarding", targets: ["SpeziOnboarding"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi", .upToNextMinor(from: "0.7.0")),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", .upToNextMinor(from: "0.5.0"))
    ],
    targets: [
        .target(
            name: "SpeziOnboarding",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziViews", package: "SpeziViews")
            ]
        ),
        .testTarget(
            name: "SpeziOnboardingTests",
            dependencies: [
                .target(name: "SpeziOnboarding")
            ]
        )
    ]
)
