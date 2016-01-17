import Foundation
import swiftysockets

// Talk to the server
class ServerInterface {

  private var clientSocket:TCPClientSocket?

  init() {
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

  func receive() -> String {
    if let s = try! self.clientSocket?.receiveString(untilDelimiter:"\n") {
      return s
    } else {
      return ""
    }
  }

}
