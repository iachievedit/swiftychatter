// ServerInterface.swift
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
import swiftysockets

// Talk to the server
class ServerInterface {

  private(set) var connected:Bool
  private var clientSocket:TCPClientSocket?

  init() {
    self.connected = false
  }

  func connect(server:String) -> Bool {
    let tokens = server.characters.split{c in c == ":"}.map(String.init)

    guard tokens.count == 2 else {
      return false
    }

    let host = tokens[0]
    if let port = Int(tokens[1]) {
      do {
        let ip            = try IP(address:host, port:port)
        self.clientSocket = try TCPClientSocket(ip:ip)
        self.connected    = true
        return true
      } catch {
        return false
      }
    } else {
      return false
    }
  }

  func send(message:String) {
    try! self.clientSocket?.sendString("\(message)\n")
    try! self.clientSocket?.flush()
  }

  func receive(inout message:String) -> Bool {
    do {
      if let s = try self.clientSocket?.receiveString(untilDelimiter:"\n") {
        message = s
      } else {
        message = ""
      }
      return true
    } catch {
      // This usually means a server disconnect
      self.connected = false
      return false
    }
  }

}
