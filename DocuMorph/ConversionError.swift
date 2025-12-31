// ConversionError.swift (Custom errors for better debugging)
enum ConversionError: Error {
    case invalidDocument
    case unsupportedFormat
    case jsonSerializationFailed
}
