import Foundation

enum RepositoryError: Error {
    case cloneError(String)
    case filePathUnavailable
}
