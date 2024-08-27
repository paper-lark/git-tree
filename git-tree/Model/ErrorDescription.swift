import Foundation

struct ErrorDescription {
    var showError: Bool
    var header: String
    var description: String

    static func noError() -> ErrorDescription {
        return ErrorDescription(showError: false, header: "", description: "")
    }

    static func error(header: String, description: String) -> ErrorDescription {
        return ErrorDescription(showError: true, header: header, description: description)
    }

    mutating func showError(header: String, description: String) {
        self.header = header
        self.description = description
        showError = true
    }

    mutating func hideError() {
        showError = false
    }
}
