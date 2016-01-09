import chattercommon
import Foundation
import Glibc
import Rainbow
import CNCURSES

enum CommandType:String {
case Invalid
case None
case Send
case Channel = "/channel"
case Help    = "/help" 
case Connect = "/connect"
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
        self.userIf.displayChatMessage(received)
      }
    }
    receiveThread.start()
    
    let readThread = NSThread(){

      //print("Type /help for help".green)
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
    case CommandType.Help.rawValue:
      commandType = .Help
    case CommandType.Connect.rawValue:
      commandType = .Connect
    case CommandType.Channel.rawValue:
      guard tokens.count == 2 else {
        return Command(type:CommandType.Invalid,
                       data:"Too few arguments for \(tokens[0])")
      }
      commandType = .Channel
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
    case .Help:
      print("Implement help")
    case .Nick:
      print("Implement nick")
    case .Channel:
      print("Implement channel")
    case .Connect:
      print("Implement connect")
    case .Send:
      doSend(command)
    case .Invalid:
      self.userIf.displayErrorMessage("Error:  \(command.data)")
    case .None:
      break
    }
  }

  func doSend(command:Command) {
    let message = SendMessage(message:command.data)
    self.serverIf!.send(message.serialize())
  }
}
