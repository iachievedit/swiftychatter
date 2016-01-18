import Glibc

enum Signal:Int32 {
case INT = 2
case WINCH = 28
}

typealias SigactionHandler = @convention(c)(Int32) -> Void

func trap(signum:Signal, action:SigactionHandler) {
  var sigAction = sigaction()
  sigAction.__sigaction_handler = unsafeBitCast(action,
                                                sigaction.__Unnamed_union___sigaction_handler.self)
  
  sigaction(signum.rawValue, &sigAction, nil)
                                                
}
