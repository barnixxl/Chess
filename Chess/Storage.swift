
import Foundation

@propertyWrapper struct UserDefaultWrapper<Value> {
    let key: String
    let `default`: Value
    let storage: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            storage.value(forKey: key) as? Value ?? `default`
        }
        set {
            storage.setValue(newValue, forKey: key)
            storage.synchronize()
        }
    }
}

class Storage {
    static let shared = Storage()

    @UserDefaultWrapper(key: "boardTheme", default: nil)
    var boardTheme: String?

    @UserDefaultWrapper(key: "flipBlackWhenHuman", default: false)
    var flipBlackWhenHuman: Bool

    @UserDefaultWrapper(key: "backgroundMusicVolume", default: 0.5)
    var backgroundMusicVolume: Float

    @UserDefaultWrapper(key: "isMoveSoundEnabled", default: true)
    var isMoveSoundEnabled: Bool

    @UserDefaultWrapper(key: "isWinSoundEnabled", default: true)
    var isWinSoundEnabled: Bool

    @UserDefaultWrapper(key: "isLoseSoundEnabled", default: true)
    var isLoseSoundEnabled: Bool

    @UserDefaultWrapper(key: "isCaptureSoundEnabled", default: true)
    var isCaptureSoundEnabled: Bool

    @UserDefaultWrapper(key: "isKeySoundEnabled", default: true)
    var isKeySoundEnabled: Bool
}
