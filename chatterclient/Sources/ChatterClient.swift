// ChatterClient.swift
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

import chattercommon
import Foundation
import Glibc
import JSON

enum CommandType:String {
case Invalid
case None
case Send
case Room    = "/room"
case Nick    = "/nick"
case Quit    = "/quit"
case Connect = "/connect"
}

// Structs
struct Command {
  var type:CommandType
  var data:String
}

class ChatterClient {

  var nick = DEFAULT_NICK
  var room = DEFAULT_ROOM
  // Read-only computed property
  var prompt:String {
    return "\(nick)@\(room) >"
  }
  
  private var serverIf:ServerInterface
  private var userIf:CursesInterface = CursesInterface()
  init() {
    self.serverIf = ServerInterface()
  }

  func start() {
    let receiveThread = NSThread(){
      while true {
        let received = self.serverIf.receive()
        self.handleReceivedMessage(received)

      }
    }
    receiveThread.start()
    
    let readThread = NSThread(){

      self.displayPrompt()

      while true {
        let input   = self.userIf.getInput()
        let command = self.parseInput(input)
        self.doCommand(command)
        self.displayPrompt()
      }
    }

    readThread.start()
  }

  func displayPrompt() {
    self.userIf.displayPrompt(self.prompt)
  }

   func parseInput(input:String) -> Command {
    var commandType:CommandType
    var commandData:String = ""

    // Splitting a string
    let tokens = input.characters.split{$0 == " "}.map(String.init)

    // guard statement to validate that there are tokens
    guard tokens.count > 0 else {
      return Command(type:CommandType.None, data:"")
    }

    switch tokens[0] {
      
    case CommandType.Quit.rawValue:
      commandType = .Quit
      
    case CommandType.Room.rawValue:
      guard tokens.count == 2 else {
        return Command(type:CommandType.Invalid,
                       data:"Too few arguments for \(tokens[0])")
      }
      commandType = .Room
      commandData = tokens[1]
      
    case CommandType.Nick.rawValue:
      guard tokens.count == 2 else {
        return Command(type:CommandType.Invalid,
                       data:"Too few arguments for \(tokens[0])")
      }
      commandType = .Nick
      commandData = tokens[1]
      
    case CommandType.Connect.rawValue:
      guard tokens.count == 2 else {
        return Command(type:CommandType.Invalid,
                       data:"Too few arguments for \(tokens[0])")
      }
      commandType = .Connect
      commandData = tokens[1]

    default:
      guard tokens[0].characters.first != "/" else {
        return Command(type:CommandType.Invalid,
                       data:"No such command \(tokens[0])")
      }
      commandType = .Send
      commandData = input
    }
    return Command(type:commandType, data:commandData)
  }

  func doCommand(command:Command) {
    switch command.type {
    case .Quit:
      self.userIf.end()
      exit(0)
    case .Nick:
      doNick(command)
    case .Room:
      doRoom(command)
    case .Send:
      doSend(command)
    case .Connect:
      doConnect(command)
    case .Invalid:
      self.userIf.displayErrorMessage("Error:  \(command.data)")
    case .None:
      break
    }
  }

  func doNick(command:Command) {
    self.nick   = command.data
    let message = NickMessage(nick:command.data)
    self.serverIf.send(message.serialize())

    // Update our prompt
    self.displayPrompt()
  }

  func doRoom(command:Command) {
    let message = RoomMessage(room:command.data)
    self.serverIf.send(message.serialize())
  }

  func doSend(command:Command) {
    let message = SayMessage(message:command.data)
    self.serverIf.send(message.serialize())
  }

  func doConnect(command:Command) {
    if self.serverIf.connect(command.data) {
    } else {
      self.userIf.displayErrorMessage("Error:  Could not connect to \(command.data)")
    }
  }

  func handleReceivedMessage(message:String) {
    do {
      let json = try JSONParser.parse(message)
      guard json != nil else {
        return
      }

      if let messageType = json["msgtype"]?.stringValue {
        if let msgtype = ChatterMessageType(rawValue:messageType) {
        switch msgtype {
        case .Say:
          self.handleSayMessage(json)
        case .Nick:
          break
        case .Enter:
          break
        case .Room:
          break
        }
        }
      }
    } catch {
      // don't care
    }
  }

  func handleSayMessage(json:JSON) {
    if let data = json["data"],
       let nick = data["nick"]?.stringValue!,
       let message = data["message"]?.stringValue! {
      self.userIf.displayChatMessage(nick, message:message)
    }
  }
}
