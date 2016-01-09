import PackageDescription

let package = Package(dependencies:[
                       .Package(url:  "https://github.com/iachievedit/swiftysockets", majorVersion:
 0),
                       .Package(url:"https://github.com/Zewo/JSON.git", majorVersion:0, minor:1),
                       .Package(url:"https://github.com/onevcat/Rainbow", majorVersion:1),
                       .Package(url:"/tank/users/josephbell/projects/CNCURSES", majorVersion:1),


                     ],
                      targets:[
                        Target(name:"chattercommon"),
                        Target(name:"chatterserver"),
                        Target(name:"chatterclient",
                               dependencies:[.Target(name:"chattercommon")])
                     ]
                )
