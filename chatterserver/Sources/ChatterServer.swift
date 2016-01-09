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
import Foundation
import JSON

class ChatterServer {

  private let ip:IP?
  private let server:TCPServerSocket?

  init?() {
    do {
      self.ip     = try IP(port:5555)
      self.server = try TCPServerSocket(ip:self.ip!)
    } catch let error {
      print(error)
      return nil
    }
  }

  func start() {
    while true {
      do {
        let client = try server!.accept()
        self.addClient(client)
      } catch let error {
        print(error)
      }
    }
  }

  private var connectedClients:[TCPClientSocket] = []
  private var connectionCount = 0
  private func addClient(client:TCPClientSocket) {
    self.connectionCount += 1
    let handlerThread = NSThread(){
      let clientId = self.connectionCount
      
      print("Client \(clientId) connected")
      
      while true {
        do {
          if let s = try client.receiveString(untilDelimiter: "\n") {
            print("Received from client \(clientId):  \(s)", terminator:"")
            let payload = self.handleMessage(s)
            self.broadcastMessage(payload)
          }
        } catch let error {
          print ("Client \(clientId) disconnected:  \(error)")
          self.removeClient(client)
          return
        }
      }
    }
    handlerThread.start()
    connectedClients.append(client)
  }

  private func removeClient(client:TCPClientSocket) {
    connectedClients = connectedClients.filter(){$0 !== client}
  }

  private func handleMessage(message:String) -> String {
    let json        = try! JSONParser.parse(message)
    let messageType = json["name"]
    let msgPay      = json["message"]!.stringValue!
    return msgPay
  }

  private func broadcastMessage(message:String) {
    for client in connectedClients {
      do {
        print("Broadcast to client")
        try client.sendString("\(message)\n")
        try client.flush()
      } catch {
        // 
      }
    }
  }


}
