import Foundation

enum RepositoryError: Error {
    case filePathUnavailable
    case remoteDoesNotExist
    case unexpectedError
}
