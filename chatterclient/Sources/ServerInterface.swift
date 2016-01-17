import Foundation
import swiftysockets

// Talk to the server
class ServerInterface {

  private var clientSocket:TCPClientSocket

  init?() {
    do {
      let ip            = try IP(port:5555)
      self.clientSocket = try TCPClientSocket(ip:ip)
    } catch {
      return nil
    }
  }

  func connect(server:String) {
  }

  func send(message:String) {
    try! self.clientSocket.sendString("\(message)\n")
    try! self.clientSocket.flush()
  }

  func receive() -> String {
    return try! self.clientSocket.receiveString(untilDelimiter:"\n")!
  }

}
