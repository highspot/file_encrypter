// swift-tools-version: 5.9

// Copyright 2025 Acme Software LLC. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "file_encrypter",
  platforms: [
    .iOS("12.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "file-encrypter", targets: ["file_encrypter"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "file_encrypter",
      dependencies: [],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
