import Foundation

public enum LogType: String {
  case networking = "🌐 [Networking]"
  case core = "📝 [Info]"
  case apiUrl = "📟 [API URL]"
  case inputParamenters = "📩 Input Parameters"
  case response = "💎 Response"
  case error = "❌ Error"
  case authToken = "🔑 [Auth Token]"
  case deviceToken = "🛡 [Device Token]"
}

public struct PrintLogger {
  private static let logQueue = DispatchQueue(label: "com.subzillo.logger", qos: .background)

  public static func log(type: LogType, message: String) {
    #if DEBUG
    logQueue.async {
        print("[Subzillo] \(type.rawValue) \(message)\n")
    }
    #endif
  }

  public static func modelLog<T: Encodable>(_ data: T, type: LogType, isInput: Bool = true) {
    #if DEBUG
    logQueue.async {
        let stringData = data.encodePrint().orEmpty
        print("[Subzillo] \(type.rawValue): \n\(stringData)\n")
        if !isInput {
          print("-------------------------------------------------------------------------------------------------------\n")
        }
    }
    #endif
  }
}
