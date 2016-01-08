import Foundation
import Glibc
import JSON

protocol Serializable {
  func serialize() -> String
}

class ChatterMessage {

  var messageName:String = ""
  
  init() {
  }
  
}

class NickMessage : ChatterMessage, Serializable, CustomStringConvertible {

  var nickname:String

  init(nickname:String) {
    self.nickname = nickname
    super.init()
    super.messageName = "nick"
  }

  func serialize() -> String {
    let json:JSON = [
      "name":JSON.from(self.messageName),
      "nickname":JSON.from(self.nickname)
    ]
    return json.serialize(DefaultJSONSerializer())
  }

  var description:String {
    return self.serialize()
  }

}

class ChannelMessage : ChatterMessage, Serializable, CustomStringConvertible {

  var channel:String

  init(channel:String) {
    self.channel = channel
    super.init()
    super.messageName = "channel"

  }

  func serialize() -> String {
    let json:JSON = [
      "name":JSON.from(self.messageName),
      "channel":JSON.from(self.channel)
    ]
    return json.serialize(DefaultJSONSerializer())
  }

  var description:String {
    return self.serialize()
  }
  
}

class SendMessage : ChatterMessage, Serializable, CustomStringConvertible {

  var message:String

  init(message:String) {
    self.message = message
    super.init()
    super.messageName = "send"
  }

  func serialize() -> String {
    let json:JSON = [
      "name":JSON.from(self.messageName),
      "message":JSON.from(self.message)
    ]
    return json.serialize(DefaultJSONSerializer())
  }

  var description:String {
    return self.serialize()
  }
  
}
