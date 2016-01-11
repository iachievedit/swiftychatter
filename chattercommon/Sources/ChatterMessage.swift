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

public enum ChatterMessageType:String {
       case Say   = "say"
       case Nick  = "nick"
       case Enter = "enter"
       case Room  = "room"
       }

public protocol ChatterMessage : CustomStringConvertible {
  var msgtype:String { get }
  func serialize() -> String
}

// Client-originated messages
public class NickMessage : ChatterMessage {

  public let msgtype = "nick"
  
  var nick:String

  public init(nick:String) {
    self.nick = nick
  }

  public func serialize() -> String {
    let json:JSON = [
      "msgtype":JSON.from(self.msgtype),
      "data":[
        "nick":JSON.from(self.nick)
      ]
    ]
    return json.serialize(DefaultJSONSerializer())
  }

  public var description:String {
    return self.serialize()
  }

}

public class RoomMessage : ChatterMessage {

  public let msgtype = "room"

  var room:String

  public init(room:String) {
    self.room = room
  }

  public func serialize() -> String {
    let json:JSON = [
      "msgtype":JSON.from(self.msgtype),
      "data":[
        "room":JSON.from(self.room)
      ]
    ]
    return json.serialize(DefaultJSONSerializer())
  }

  public var description:String {
    return self.serialize()
  }
  
}

public class SayMessage : ChatterMessage {

  public let msgtype = "say"
  var message:String
  var nick:String      // Only used by the server

  public init(message:String, nick:String = "") {
    self.message = message
    self.nick    = nick
  }

  public func serialize() -> String {
    let json:JSON = [
      "msgtype":JSON.from(self.msgtype),
      "data":[
        "message":JSON.from(self.message),
        "nick":JSON.from(self.nick)
      ]
    ]
    return json.serialize(DefaultJSONSerializer())
  }

  public var description:String {
    return self.serialize()
  }
  
}

public class EnterMessage : ChatterMessage {

  public let msgtype = "enter"
  var nick:String
  var room:String

  public init(nick:String, room:String) {
    self.nick = nick
    self.room = room
  }

  public func serialize() -> String {
    let json:JSON = [
      "msgtype":JSON.from(self.msgtype),
      "data":[
        "nick":JSON.from(self.nick),
        "room":JSON.from(self.room),
      ]
    ]
    return json.serialize(DefaultJSONSerializer())
  }

  public var description:String {
    return self.serialize()
  }

}
