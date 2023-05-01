//
//  Prospect.swift
//  HotProspects
//
//  Created by Maximilian Berndt on 2023/04/30.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var dateAdded = Date.now
    var email = ""
    var name = "Anonymous"
    
    fileprivate (set) var isContacted = false
}

@MainActor class Prospects: ObservableObject {
    @Published private (set) var people: [Prospect] = []
    let savedKey = "SavedData"
    
    init() {
        load()
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
        FileManager()
            .saveInDocuments(to: savedKey, data: people)
    }
    
    private func load() {
        if FileManager().fileInDocumentsExists(savedKey) {
            let loadedContacts: [Prospect] = FileManager()
                .loadFromDocuments(savedKey)
            people = loadedContacts
        }
    }
}

extension Prospect {
    private static var exampleProspects = [
        "Paul Hudson": "paul@hackingwithswift.com",
        "Harry Potter": "harry@hogwarts.com",
        "Hermione Granger": "hermione@icloud.com",
        "Ron Weasley": "ron@weasley.com"
    ]
    
    
    static var example: Prospect {
        let prospect = Prospect()
        
        let example = exampleProspects.randomElement()!
        prospect.name = example.key
        prospect.email = example.value
        
        return prospect
    }
    
    func asSimulatedData() -> String {
        return "\(name)\n\(email)"
    }
}
