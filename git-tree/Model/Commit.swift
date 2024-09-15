import AppIntents

struct Commit: TransientAppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("Commit"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) commits")
        )
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(message ?? sha)",
            subtitle: "\(sha)")
    }

    var sha: String = ""
    var message: String? = nil
    var date: Date = Date()

    var id: String { sha }
}
