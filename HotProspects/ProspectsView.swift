//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Maximilian Berndt on 2023/04/30.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    
    enum FilterType {
        case none
        case contacted
        case uncontacted
    }
    
    enum SortingType {
        case name
        case recent
    }
    
    @EnvironmentObject var prospects: Prospects
    
    @State private var isShowingQRCodeScanner = false
    @State private var isShowingFilterView = false
    
    @State private var sorting: SortingType = .recent
    private (set) var filter: FilterType = .none
    
    
    var title: String {
        switch filter {
        case .none: return "Everyone"
        case .contacted: return "Contacted people"
        case .uncontacted: return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { $0.isContacted == false }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedProspects(prospects: filteredProspects)) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.email)
                                .foregroundColor(.secondary)
                        }
                        if (filter == .none) {
                            Spacer()
                            Image(systemName: calculateSFSymbol(prospect: prospect))
                                .foregroundColor(prospect.isContacted ? .green : .yellow)
                        }
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark uncontacted", systemImage: "person .crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark contacted", systemImage: "person .crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            Button {
                                addNotification(for: prospect)
                            } label: {
                                Label("Remind me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingFilterView = true
                    } label: {
                        Label("Filter", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingQRCodeScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $isShowingQRCodeScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: Prospect.example.asSimulatedData(), completion: handleScan)
            }
            .confirmationDialog("Change sorting", isPresented: $isShowingFilterView) {
                Button("by name") { sorting = .name }
                Button("by recent") { sorting = .recent }
            } message: {
                Text("Select a sort order")
            }
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingQRCodeScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            let prospect = Prospect()
            prospect.name = details[0]
            prospect.email = details[1]
            prospects.add(prospect)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
            
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.email
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh!")
                    }
                }
            }
        }
    }
    
    private func sortedProspects(prospects: [Prospect]) -> [Prospect] {
        switch sorting {
        case .name: return prospects.sorted { a, b in
            return a.name < b.name
        }
        case .recent: return prospects.sorted { a, b in
            return a.dateAdded < b.dateAdded
        }
        }
    }
    
    private func calculateSFSymbol(prospect: Prospect) -> String {
        return prospect.isContacted ? "person.fill.checkmark" : "person.fill.questionmark"
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
