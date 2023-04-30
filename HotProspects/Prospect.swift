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
