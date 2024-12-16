//
//  HistoryManager.swift
//  NetCheckr
//
//  Created by padrewin on 15.12.2024.
//


import Foundation

class HistoryManager {
    private var history: [String] = []
    var onHistoryUpdated: (() -> Void)? // Callback pentru notificare
    
    func addEntry(_ entry: String) {
        history.append(entry)
        onHistoryUpdated?() // Notificăm că istoricul a fost actualizat
    }
    
    func getHistory() -> [String] {
        return history
    }
}
