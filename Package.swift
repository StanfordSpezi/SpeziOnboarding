// swift-tools-version:5.8

//
// This source file is part of the CardinalKit open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "CardinalKitOnboarding",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "CardinalKitOnboarding", targets: ["CardinalKitOnboarding"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordBDHG/CardinalKitViews", .upToNextMinor(from: "0.2.0"))
    ],
    targets: [
        .target(
            name: "CardinalKitOnboarding",
            dependencies: [
                .product(name: "CardinalKitViews", package: "CardinalKitViews")
            ]
        ),
        .testTarget(
            name: "CardinalKitOnboardingTests",
            dependencies: [
                .target(name: "CardinalKitOnboarding")
            ]
        )
    ]
)
