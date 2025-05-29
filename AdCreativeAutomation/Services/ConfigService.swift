import Foundation

enum APIKeyType: String {
    case openAI = "OpenAI"
    case facebook = "Facebook"
    case tiktok = "TikTok"
}

protocol ConfigServiceProtocol {
    func getAPIKey(for service: APIKeyType) throws -> String
    func setAPIKey(_ key: String, for service: APIKeyType) throws
    func getBaseURL(for service: APIKeyType) -> URL?
    func getValue(for key: String) -> String?
}

class ConfigService: ConfigServiceProtocol {
    private let keychainService: KeychainServiceProtocol
    private let userDefaults: UserDefaults
    private var configDictionary: [String: Any]?
    
    init(
        keychainService: KeychainServiceProtocol = KeychainService(),
        userDefaults: UserDefaults = .standard
    ) {
        self.keychainService = keychainService
        self.userDefaults = userDefaults
        loadConfig()
    }
    
    func getAPIKey(for service: APIKeyType) throws -> String {
        try keychainService.retrieveFromKeychain(key: service.rawValue)
    }
    
    func setAPIKey(_ key: String, for service: APIKeyType) throws {
        try keychainService.saveToKeychain(key: service.rawValue, value: key)
    }
    
    func getBaseURL(for service: APIKeyType) -> URL? {
        switch service {
        case .openAI:
            return URL(string: "https://api.openai.com")
        case .facebook:
            return URL(string: "https://graph.facebook.com")
        case .tiktok:
            return URL(string: "https://business-api.tiktok.com")
        }
    }
    
    func getValue(for key: String) -> String? {
        configDictionary?[key] as? String
    }
    
    private func loadConfig() {
        guard let configURL = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: configURL),
              let config = try? PropertyListSerialization.propertyList(
                from: data,
                format: nil
              ) as? [String: Any] else {
            return
        }
        
        self.configDictionary = config
    }
} 