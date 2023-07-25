import SwiftUI

struct DoingList: View {
    @State private var alertPresented = false
    @State private var newDoingTitle = ""
    @AppStorage("userDefaultDoings") var userDefaultDoings: Data = Data()

    var body: some View {
        NavigationView {
            ZStack {
                let decodedUserDefaultDoings = try? JSONDecoder().decode([String: [Doing]].self, from: userDefaultDoings)
                List {
                    ForEach(decodedUserDefaultDoings?["doings"] ?? [], id: \.id) { doing in
                        NavigationLink {
                            DoingDetail(doing: doing)
                        } label: {
                            DoingRow(doing: doing)
                        }
                    }
                    .navigationTitle("All Doings")
                }

                Button {
                    alertPresented = true
                } label: {
                    ZStack {
                        Image(systemName: "circle")
                        Image(systemName: "plus")
                    }
                }
                .alert("What are you doing?", isPresented: $alertPresented) {
                    TextField("", text: $newDoingTitle)
                    Button("Cancel", role: .cancel) {}
                    Button("Save", role: .none) {
                        if var val = decodedUserDefaultDoings?["doings"] {
                            val.append(Doing(id: UUID(), title: newDoingTitle, subDoings: []))
                            let data = ["doings": val]
                            guard let userDefaultDoings = try? JSONEncoder().encode(data) else { return }
                            self.userDefaultDoings = userDefaultDoings
                        } else {
                            let data = ["doings": [Doing(id: UUID(), title: newDoingTitle, subDoings: [])]]
                            guard let userDefaultDoings = try? JSONEncoder().encode(data) else { return }
                            self.userDefaultDoings = userDefaultDoings
                        }
                    }
                }
            }
        }
    }
}

struct DoingList_Previews: PreviewProvider {
    static var previews: some View {
        DoingList()
            .environmentObject(ModelData())
    }
}

