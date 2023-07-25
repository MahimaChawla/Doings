import SwiftUI

struct DoingDetail: View {
    var doing: Doing
    @State private var alertPresented = false
    @State private var subDoingText = ""
    @AppStorage("userDefaultDoings") var userDefaultDoings: Data = Data()
    
    @State private var editedTitles: [UUID: String] = [:]
    @State private var editedDescriptions: [UUID: String] = [:]
    @State private var isEditingTitle = false
    @State private var editedTitle = ""
    @State private var isEditingDescription = false
    @State private var editedDescription = ""

    var body: some View {
        ZStack {
            List{
                ForEach(doing.subDoings) { subDoing in
                                    VStack(alignment: .leading) {
                                        if isEditingTitle(for: subDoing) {
                                            TextField("Title", text: bindingForTitle(subDoing), onCommit: {
                                                saveTitle(for: subDoing)
                                            })
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        } else {
                                            Text(subDoing.title)
                                                .onTapGesture {
                                                    startEditingTitle(for: subDoing)
                                                }
                                        }
                                        
                                        if isEditingDescription(for: subDoing) {
                                            TextField("Description", text: bindingForDescription(subDoing), onCommit: {
                                                saveDescription(for: subDoing)
                                            })
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        } else {
                                            Text(subDoing.description.isEmpty ? "Add Description" : subDoing.description)
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray) 
                                                .onTapGesture {
                                                    startEditingDescription(for: subDoing)
                                                }
                        }
                        
                    }
                }.onDelete(perform: deleteSubDoing)
            }
            .navigationTitle(doing.title)
            .navigationBarItems(trailing: Button("Save", action: saveAllData))
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        alertPresented = true
                    } label: {
                        ZStack {
                            Image(systemName: "circle").font(.system(size: 30))
                            Image(systemName: "plus").font(.system(size: 30))
                        }
                    }
                    .alert("Take a new step", isPresented: $alertPresented) {
                        TextField("", text: $subDoingText)
                        Button("Cancel", role: .cancel) {}
                        Button("Save", role: .none) {
                            var decodedUserDefaultDoings = try? JSONDecoder().decode([String: [Doing]].self, from: userDefaultDoings)
                            
                            if var currentTitle = decodedUserDefaultDoings?["doings"]?.first(where: { $0.id == doing.id })?.subDoings {
                                currentTitle.append(Doing(id: UUID(), title: subDoingText, subDoings: [], description: ""))
                                
                                if let index = decodedUserDefaultDoings?["doings"]?.firstIndex(where: { $0.id == doing.id }) {
                                    decodedUserDefaultDoings?["doings"]?[index].subDoings = currentTitle
                                }
                                if let data = try? JSONEncoder().encode(decodedUserDefaultDoings) {
                                    self.userDefaultDoings = data
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    // Function to delete a sub-doing
    private func deleteSubDoing(at offsets: IndexSet) {
        var decodedUserDefaultDoings = try? JSONDecoder().decode([String: [Doing]].self, from: userDefaultDoings)

        if var currentSubDoing = decodedUserDefaultDoings?["doings"]?.first(where: { $0.id == doing.id })?.subDoings {
            // Remove the sub-doings at the specified offsets
            currentSubDoing.remove(atOffsets: offsets)

            if let index = decodedUserDefaultDoings?["doings"]?.firstIndex(where: { $0.id == doing.id }) {
                decodedUserDefaultDoings?["doings"]?[index].subDoings = currentSubDoing
            }
            if let data = try? JSONEncoder().encode(decodedUserDefaultDoings) {
                self.userDefaultDoings = data
            }
        }
    }

    
    private func isEditingTitle(for subDoing: Doing) -> Bool {
        editedTitles[subDoing.id] != nil
    }
    
    private func startEditingTitle(for subDoing: Doing) {
        editedTitles[subDoing.id] = subDoing.title
    }
    
    private func bindingForTitle(_ subDoing: Doing) -> Binding<String> {
        .init(get: {
            editedTitles[subDoing.id] ?? subDoing.title
        }, set: { newValue in
            editedTitles[subDoing.id] = newValue
        })
    }
        
        private func isEditingDescription(for subDoing: Doing) -> Bool {
            editedDescriptions[subDoing.id] != nil
        }
        
        private func startEditingDescription(for subDoing: Doing) {
            editedDescriptions[subDoing.id] = subDoing.description
        }
        
        private func bindingForDescription(_ subDoing: Doing) -> Binding<String> {
            .init(get: {
                editedDescriptions[subDoing.id] ?? subDoing.description
            }, set: { newValue in
                editedDescriptions[subDoing.id] = newValue
            })
        }
    
    private func saveTitle(for subDoing: Doing) {
        // Check if the edited title is not empty
        guard let editedTitle = editedTitles[subDoing.id], !editedTitle.isEmpty else {
            // If it is empty, reset the editing state and return
            editedTitles[subDoing.id] = nil
            isEditingTitle = false
            return
        }

        // Update the title for the corresponding subDoing
        var decodedUserDefaultDoings = try? JSONDecoder().decode([String: [Doing]].self, from: userDefaultDoings)
        if let index = decodedUserDefaultDoings?["doings"]?.firstIndex(where: { $0.id == doing.id }) {
            if var currentSubDoings = decodedUserDefaultDoings?["doings"]?[index].subDoings {
                if let subDoingIndex = currentSubDoings.firstIndex(where: { $0.id == subDoing.id }) {
                    currentSubDoings[subDoingIndex].title = editedTitle
                    decodedUserDefaultDoings?["doings"]?[index].subDoings = currentSubDoings
                    editedTitles[subDoing.id] = nil // Reset the edited title once saved
                    isEditingTitle = false // Reset the editing state
                }
            }
        }
        // Update userDefaultDoings data
        if let data = try? JSONEncoder().encode(decodedUserDefaultDoings) {
            self.userDefaultDoings = data
        }
    }

    private func saveDescription(for subDoing: Doing) {
        // Check if the edited description is not empty
        guard let editedDescription = editedDescriptions[subDoing.id], !editedDescription.isEmpty else {
            // If it is empty, reset the editing state and return
            editedDescriptions[subDoing.id] = nil
            isEditingDescription = false
            return
        }

        // Update the description for the corresponding subDoing
        var decodedUserDefaultDoings = try? JSONDecoder().decode([String: [Doing]].self, from: userDefaultDoings)
        if let index = decodedUserDefaultDoings?["doings"]?.firstIndex(where: { $0.id == doing.id }) {
            if var currentSubDoings = decodedUserDefaultDoings?["doings"]?[index].subDoings {
                if let subDoingIndex = currentSubDoings.firstIndex(where: { $0.id == subDoing.id }) {
                    currentSubDoings[subDoingIndex].description = editedDescription
                    decodedUserDefaultDoings?["doings"]?[index].subDoings = currentSubDoings
                    editedDescriptions[subDoing.id] = nil // Reset the edited description once saved
                    isEditingDescription = false // Reset the editing state
                }
            }
        }
        // Update userDefaultDoings data
        if let data = try? JSONEncoder().encode(decodedUserDefaultDoings) {
            self.userDefaultDoings = data
        }
    }
    
    private func saveAllData() {
        // Save all edited titles and descriptions
        for subDoing in doing.subDoings {
            saveTitle(for: subDoing)
            saveDescription(for: subDoing)
        }
    }
    
}

struct DoingDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        DoingDetail(doing: modelData.doings[0])
            .environmentObject(modelData)
    }
}
