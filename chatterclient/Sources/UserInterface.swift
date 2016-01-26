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

  func displayStatusBar()

  func displayChatMessage(nick:String, message:String)

  func displayErrorMessage(message:String)

  func getInput() -> String

  func end()
  
}

func getmaxyx(window window:UnsafeMutablePointer<WINDOW>, inout y:Int32, inout x:Int32) {
  x = getmaxx(window)
  y = getmaxy(window)
}

func getcuryx(window window:UnsafeMutablePointer<WINDOW>, inout y:Int32, inout x:Int32) {
  x = getcurx(window)
  y = getcury(window)
}

var userInterface:CursesInterface? = nil

let NotConnected = "Not Connected"

class CursesInterface : UserInterface {

  let delim:Character     = "\n"
  let backspace:Character = Character(UnicodeScalar(127))
  let A_REVERSE = Int32(1 << 18)
  
  // Ncurses screen positions
  var maxy:Int32 = 0 // Maximum number of lines
  var maxx:Int32 = 0 // Maximum number of columns
  var cury:Int32 = 0 // Current cursor line
  var curx:Int32 = 0 // Current cursor column
  
  var inputCol:Int32 = 0
  
  var prompt:String = ""
  var connection:String
  
  var statusLine:Int32 {
    get {
      return maxy - 2
    }
  }
  var inputLine:Int32 {
    get {
      return maxy - 1
    }
  }
  
  var liny:Int32 = 0

  var buffer:CircularBuffer<String>?

  init() {
    initscr()
    noecho()
    curs_set(1)
    
    self.connection = NotConnected
    buffer = CircularBuffer<String>(size:120)
    
    trap(.INT){ s in
      if let ui = userInterface {
        ui.end()
        exit(0)
      }
    }
    
    trap(.WINCH){ s in
      if let ui = userInterface {
        ui.resetUI()
      }
    }
    
    getmaxyx(window:stdscr, y:&maxy, x:&maxx)
    
  }

  func resetUI() {
     endwin()
     refresh()
     initscr()
     clear()
     curs_set(1)
     liny = 0
     self.getDisplaySize()
     self.displayStatusBar()
     self.displayInput()
     self.refreshChatMessages()
   }

  func getDisplaySize() {
    getmaxyx(window:stdscr, y:&maxy, x:&maxx)
  }
  
  func setPrompt(prompt:String) {
    self.prompt = prompt
    self.displayStatusBar()
  }
  
  func setConnection(connection:String = NotConnected) {
    self.connection = connection
    self.displayStatusBar()
  }
  
  func displayStatusBar() {
    
    let promptLen = prompt.characters.count
    let connLen   = connection.characters.count
    let padLen    = maxx - promptLen - connLen
    
    var statusBarString:String = prompt

    for _ in 1...padLen {
      statusBarString += " "
    }

    statusBarString += connection
    
    move(statusLine,0)
    attron(A_REVERSE)
    addstr(statusBarString)
    attroff(A_REVERSE)
    refresh()
  }

  func displayChatMessage(nick:String, message:String) {
    let displayString = "\(nick):  \(message)"
    displayMessage(displayString)
  }

  func displayMessage(message:String, addToBuffer:Bool = true) {
    // Clear the screen and
    if liny == statusLine {
      for i in 0...statusLine-1 {
        self.clearline(i)
      }
      liny = 0
    }
    
    let lock = NSLock()
    lock.lock()
    move(liny, 0); liny += 1
    addstr(message)
    if addToBuffer {
      buffer?.writeNext(message)
    }
    move(inputLine,curx)
    refresh()
    lock.unlock()
  }

  func refreshChatMessages() {
    if let buf = buffer {
      for message in buf {
        self.displayMessage(message, addToBuffer:false)
      }
    }
  }

   func displayErrorMessage(message:String) {
    displayChatMessage("system", message:message) 
  }

   func end() {
    endwin()
  }

   var input:String = ""
   func getInput() -> String {
     input = ""
     curx = inputCol
     move(inputLine, curx)
     refresh()
     while true {
       let ic = UInt32(getch())
       let c  = Character(UnicodeScalar(ic))
       switch c {
       case self.backspace:
         guard curx != inputCol else { break }
         curx -= 1; move(inputLine, curx)
         delch()
         refresh()
         input = String(input.characters.dropLast())
       case self.delim:
         clearline(inputLine)
         return input
       default:
         if isprint(Int32(ic)) != 0 {
           addch(UInt(ic)); curx += 1
           refresh()
           input.append(c)
         }
       }
     }
   }

   // Call after SIGWINCH
   func displayInput() {
     move(inputLine, 0)
     addstr(input)
     refresh()
   }
   
   func clearline(lineno:Int32) {
     move(lineno, 0)
     clrtoeol()
     refresh()
   }
   
   
}
