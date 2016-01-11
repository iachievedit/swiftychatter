import Foundation
import Glibc
import Rainbow
import CNCURSES

protocol UserInterface {

  func displayPrompt(prompt:String)

  func displayChatMessage(nick:String, message:String)

  func displayErrorMessage(message:String)

  func getInput() -> String

  func end()
  
}

class CursesInterface : UserInterface {

  // Class constant
  let delim:Character     = "\n"
  let backspace:Character = Character(UnicodeScalar(127))

  // Ncurses screen positions
  var cury:Int32 = 0
  var curx:Int32 = 0

  let errorLine:Int32  = 20
  let statusLine:Int32 = 21
  let promptLine:Int32 = 22

  private var liny:Int32 = 0
  init() {
    initscr()
    noecho()
    curs_set(1)
  }

  func displayPrompt(prompt:String) {
    move(promptLine,0)
    addstr(prompt)
    refresh()
  }

  func displayStatusBar() {
  }

  func displayChatMessage(nick:String, message:String) {
    let displayString = "\(nick):  \(message)"
    let lock = NSLock()
    lock.lock()
    move(liny, 0); liny += 1
    addstr(displayString)
    move(promptLine,curx)
    refresh()
    lock.unlock()
  }

  func displayErrorMessage(message:String) {
    move(errorLine, 0)
    addstr(message)
    refresh()
  }

  func end() {
    endwin()
  }

  func getInput() -> String {
    var input:String = ""

    curx = 10
    move(promptLine, curx)
    refresh()
    while true {
      let ic = UInt32(getch())
      let c  = Character(UnicodeScalar(ic))
      switch c {
      case self.backspace:
        guard curx != 10 else { break }
        curx -= 1; move(21, curx)
        delch()
        refresh()
        input = String(input.characters.dropLast())
      case self.delim:
        self.clearline(promptLine)
        return input
      default:
        addch(UInt(ic)); curx += 1
        input.append(c)
      }
    }
  }

  private func clearline(lineno:Int32) {
    move(lineno, 0)
    clrtoeol()
    refresh()
  }


}
