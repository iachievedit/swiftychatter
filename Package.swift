import PackageDescription

let package = Package(
    targets:[
      Target(name:"chattercommon"),
      Target(name:"chatterserver",
             dependencies:[
               .Target(name:"chattercommon")
             ]
            ),
      Target(name:"chatterclient",
             dependencies:[
               .Target(name:"chattercommon")
             ]
            )
    ],
    dependencies:[
      .Package(url:"https://github.com/iachievedit/swiftysockets",
               majorVersion:0),
      .Package(url:"https://github.com/Zewo/JSON.git",
                 majorVersion:0, minor:1),
      .Package(url:"https://github.com/onevcat/Rainbow",
                           majorVersion:1),
      .Package(url:"https://github.com/iachievedit/CNCURSES",
               majorVersion:1),
      .Package(url:"https://github.com/kylef/Commander",
               majorVersion:0, minor:4),
      .Package(url:"https://github.com/iachievedit/swiftlog",
               majorVersion:1)
    ]
)
