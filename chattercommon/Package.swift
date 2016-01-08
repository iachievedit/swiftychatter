import PackageDescription

let package = Package(
  name:  "chattercommon",
  dependencies: [
    .Package(url:"https://github.com/Zewo/JSON.git", majorVersion:0, minor:1),
  ]
)
