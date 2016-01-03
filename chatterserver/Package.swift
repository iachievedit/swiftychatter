import PackageDescription

let package = Package(
  name:  "chatterserver",
  dependencies: [
    .Package(url:  "https://github.com/iachievedit/swiftysockets", majorVersion: 0),
  ]
)
