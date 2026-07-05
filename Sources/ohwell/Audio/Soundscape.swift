enum Soundscape: String, CaseIterable, Sendable {
    case off
    case rain = "rain"
    case whiteNoise = "white-noise"
    case cafe = "cafe"
    case bird = "bird"
    case custom = "custom"

    var label: String {
        switch self {
        case .off:        return "Off"
        case .rain:       return "Rain"
        case .whiteNoise: return "White Noise"
        case .cafe:       return "Café"
        case .bird:       return "Bird"
        case .custom:     return "Custom"
        }
    }

    var icon: String {
        switch self {
        case .off:        return "speaker.slash"
        case .rain:       return "cloud.rain"
        case .whiteNoise: return "waveform"
        case .cafe:       return "cup.and.saucer"
        case .bird:       return "bird"
        case .custom:     return "music.note"
        }
    }
}
