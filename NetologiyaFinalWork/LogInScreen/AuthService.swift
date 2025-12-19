//
//  AuthService.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 16.12.2025.
//

import Foundation



class AuthService {
   
    static let shared = AuthService()

    func register(username: String, password: String) {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        UserDefaults.standard.set(trimmed, forKey: "registeredUsername")
        UserDefaults.standard.set(true, forKey: "isRegistered")
        UserDefaults.standard.synchronize()
        KeychainHelper.savePassword(password, for: trimmed)
    }

    
    func login(username: String, password: String) -> Bool {
        guard let registered = UserDefaults.standard.string(forKey: "registeredUsername"),
              registered == username else { return false }
        if let saved = KeychainHelper.readPassword(for: username) {
            return saved == password
        }
        return false
    }
}

