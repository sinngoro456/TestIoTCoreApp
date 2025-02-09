//
//  Package.swift
//  EventsApp
//
//  Created by 川渕悟郎 on 2025/02/08.
//  Copyright © 2025 Dubal, Rohan. All rights reserved.
//

// swift-tools-version:5.1
import PackageDescription

let package = Package(name: "Tools",
                      dependencies: [
                          .package(url: "https://github.com/apple/swift-format", .branch("master"))
                      ])
