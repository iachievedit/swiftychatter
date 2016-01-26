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

import swiftysockets
import swiftlog
import chattercommon
import Foundation
import JSON

class ChatterServer {

  private let ip:IP?
  private let server:TCPServerSocket?

  init?(host:String, port:Int) {
    do {
      self.ip     = try IP(address:host, port:5555)
      self.server = try TCPServerSocket(ip:self.ip!)
    } catch let error {
      SLogError("\(error)")
      return nil
    }
  }

  func start() {
    while true {
      do {
        let clientSocket = try server!.accept()
        let client       = ChatterClient(socket:clientSocket)
        self.addClient(client)
      } catch let error {
        SLogError("\(error)")
      }
    }
  }

  private var connectedClients:[ChatterClient] = []
  private var connectionCount = 0
  private func addClient(client:ChatterClient) {
    self.connectionCount += 1
    let handlerThread = NSThread(){
      client.id = self.connectionCount
      
      SLogInfo("Client \(client.id) connected")
      
      while true {
        do {
          if let s = try client.socket.receiveString(untilDelimiter: "\n") {
            SLogVerbose("Received from client \(client.id):  \(s)")
            self.handleMessage(s, fromClient:client)

          }
        } catch let error {
          SLogInfo("Client \(client.id) disconnected:  \(error)")
          self.removeClient(client)
          return
        }
      }
    }
    handlerThread.start()
    connectedClients.append(client)
  }

  private func removeClient(client:ChatterClient) {
    connectedClients = connectedClients.filter(){$0 !== client}
  }

  private func handleMessage(message:String, fromClient:ChatterClient) {
    do {
      let json = try JSONParser.parse(message)
      guard json != nil else {
        return
      }
      
      let messageType = json["msgtype"]!.stringValue!
      switch messageType {
      case "say":
        self.handleSayMessage(json, from:fromClient)
      case "nick":
        self.handleNickMessage(json, fromClient:fromClient)
      case "room":
        self.handleRoomMessage(json, from:fromClient)
      default:
        break
      }
    } catch {
      return
    }
  }

  private func handleSayMessage(json:JSON, from client:ChatterClient) {
    if let data    = json["data"],
       let message = data["message"]?.stringValue {
      let say     = SayMessage(message:message, nick:client.nick)
      self.broadcastSayMessage(say, from:client)
    } else {
      SLogWarning("Unable to parse client say message".red)
    }
  }

  private func handleNickMessage(json:JSON, fromClient:ChatterClient) {
    if let data = json["data"],
       let nick = data["nick"]?.stringValue {
      fromClient.nick = nick
    } else {
      SLogWarning("Unable to parse client nick message".red)
    }
  }

  private func handleRoomMessage(json:JSON, from client:ChatterClient) {
    if let data = json["data"],
       let room = data["room"]?.stringValue {
      client.room = room
    } else {
      SLogWarning("Unable to parse client room message".red)
    }
  }

  private func broadcastSayMessage(say:SayMessage, from client:ChatterClient) {
    for c in connectedClients where c.room == client.room {
      SLogVerbose("Broadcast to client")
      c.sendMessage(say)
    }
  }


}
