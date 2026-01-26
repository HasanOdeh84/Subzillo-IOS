import Foundation

/// Enum representing all types of API errors returned from requests supported by the application.
public enum APIError: Error {
    case unknown
    case noInternetConnection
    case tooManyRequests
    case badRequest
    case unauthorized
    case notFound
    case requestTimeout
    case internalServerError
    case accountBlocked
    case someOneLoggedInElsewhere
    case badGateway
    case refreshTokenFailed
    case urlError(URLError)
    case responseError
    case decodingError(DecodingError)
    case anyError
    case apiError(String)
    case insufficientQuota
    
    var localizedDescription: String {
        switch self {
        case .urlError(let error):
            return "\(error)"
        case .decodingError(let error):
            return "\(error)"
        case .responseError:
            return "Bad response"
        case .anyError:
            return "Unknown error has ocurred"
        case .unknown:
            return "Unknown error has ocurred"
        case .noInternetConnection:
            return "noInternetConnection"
        case .tooManyRequests:
            return "tooManyRequests"
        case .badRequest:
            return "badRequest"
        case .unauthorized:
            return "unauthorized 401"
        case .notFound:
            return "notFound"
        case .requestTimeout:
            return "requestTimeout"
        case .internalServerError:
            return "internalServerError"
        case .accountBlocked:
            return "accountBlocked"
        case .badGateway:
            return "badGateway"
        case .refreshTokenFailed:
            return "refreshTokenFailed"
        case .apiError(let message):
            return message
        case .someOneLoggedInElsewhere:
            return "someone logged in else where"
        case .insufficientQuota:
            return "insufficient quota or quota exceeded"
        }
    }
}
