// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarkdownEditor",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .executable(
            name: "MarkdownEditor",
            targets: ["MarkdownEditor"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "MarkdownEditor",
            path: ".",
            sources: ["main.swift"]
        ),
    ]
)