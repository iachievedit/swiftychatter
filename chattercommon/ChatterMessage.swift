// ChatterServer.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 iAchieved.it LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Glibc
import JSON

protocol Serializable {
  func serialize() -> String
}

public class ChatterMessage {

  var messageName:String = ""
  
  public init() {
  }
  
}

public class NickMessage : ChatterMessage, Serializable, CustomStringConvertible {

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

  public var description:String {
    return self.serialize()
  }

}

public class ChannelMessage : ChatterMessage, Serializable, CustomStringConvertible {

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

  public var description:String {
    return self.serialize()
  }
  
}

public class SendMessage : ChatterMessage, Serializable, CustomStringConvertible {

  var message:String

  public init(message:String) {
    self.message = message
    super.init()
    super.messageName = "send"
  }

  public func serialize() -> String {
    let json:JSON = [
      "name":JSON.from(self.messageName),
      "message":JSON.from(self.message)
    ]
    return json.serialize(DefaultJSONSerializer())
  }

  public var description:String {
    return self.serialize()
  }
  
}
