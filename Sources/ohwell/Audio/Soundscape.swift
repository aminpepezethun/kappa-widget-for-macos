enum Soundscape: String, CaseIterable, Sendable {
    case off
    case rain
    case whiteNoise = "white-noise"
    case cafe

    var label: String {
        switch self {
        case .off:        return "Off"
        case .rain:       return "Rain"
        case .whiteNoise: return "White Noise"
        case .cafe:       return "Café"
        }
    }

    var icon: String {
        switch self {
        case .off:        return "speaker.slash"
        case .rain:       return "cloud.rain"
        case .whiteNoise: return "waveform"
        case .cafe:       return "cup.and.saucer"
        }
    }
}
