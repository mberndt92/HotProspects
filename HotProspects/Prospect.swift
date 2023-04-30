//
//  Prospect.swift
//  HotProspects
//
//  Created by Maximilian Berndt on 2023/04/30.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var email = ""
    fileprivate (set) var isContacted = false
}

@MainActor class Prospects: ObservableObject {
    @Published private (set) var people: [Prospect]
    let savedKey = "SavedData"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: savedKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        }
        
        people = []
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    private func save() {
        if let encodedData = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encodedData, forKey: savedKey)
        }
    }
}
