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
    let savedKey = "Save"
    
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
            "Harry Potter": "harry@hogwarts.edu",
            "Hermione Granger": "hermione@hogwarts.edu",
            "Ron Weasley": "ron@weasley.com",
            "Ginny Weasley": "ginny@weasley.com",
            "Fred Weasley": "fred@weasley.com",
            "George Weasley": "george@weasley.com",
            "Molly Weasley": "molly@weasley.com",
            "Arthur Weasley": "arthur@weasley.com",
            "Albus Dumbledore": "albus@hogwarts.edu",
            "Severus Snape": "severus@hogwarts.edu",
            "Draco Malfoy": "draco@malfoy.com",
            "Bellatrix Lestrange": "bellatrix@death-eaters.com",
            "Lord Voldemort": "voldemort@death-eaters.com"
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
