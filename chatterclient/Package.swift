import PackageDescription

let package = Package(
  name:  "chatterclient",
  dependencies: [
    .Package(url:  "https://github.com/iachievedit/swiftysockets", majorVersion: 0),
  ]
)
