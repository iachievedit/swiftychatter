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
}

// Structs
struct Command {
  var type:CommandType
  var data:String
}

class ChatterClient {

  // Read-only computed property
  var prompt:String {
    return "<>"
  }
  
  private var serverIf:ServerInterface?
  private var userIf:CursesInterface = CursesInterface()
  init() {
    self.serverIf = ServerInterface()
    assert(self.serverIf != nil)
  }

  func start() {
    let receiveThread = NSThread(){
      while true {
        let received = self.serverIf!.receive()
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
    case .Invalid:
      self.userIf.displayErrorMessage("Error:  \(command.data)")
    case .None:
      break
    }
  }

  func doNick(command:Command) {
    let message = NickMessage(nick:command.data)
    self.serverIf!.send(message.serialize())
  }

  func doRoom(command:Command) {
    let message = RoomMessage(room:command.data)
    self.serverIf!.send(message.serialize())
  }

  func doSend(command:Command) {
    let message = SayMessage(message:command.data)
    self.serverIf!.send(message.serialize())
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
