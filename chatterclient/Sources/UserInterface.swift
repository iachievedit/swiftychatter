// UserInterface.swift
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
  var cury:Int32     = 0
  var curx:Int32     = 0
  var inputCol:Int32 = 0

  let errorLine:Int32    = 21
  let promptLine:Int32   = 22

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
    inputCol = Int32(prompt.characters.count)
  }

  func displayChatMessage(nick:String, message:String) {
    if liny == errorLine {
      for i in 0...errorLine {
        self.clearline(i)
      }
      liny = 0
    }
    
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

    curx = inputCol
    move(promptLine, curx)
    refresh()
    while true {
      let ic = UInt32(getch())
      let c  = Character(UnicodeScalar(ic))
      switch c {
      case self.backspace:
        guard curx != inputCol else { break }
        curx -= 1; move(promptLine, curx)
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
