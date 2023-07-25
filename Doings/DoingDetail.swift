import SwiftUI

struct DoingDetail: View {
    var doing: Doing
    @State private var alertPresented = false
    @State private var subDoingText = ""
    @AppStorage("userDefaultDoings") var userDefaultDoings: Data = Data()

    var body: some View {
        ZStack {
            List(doing.subDoings) { subDoing in
                Text(subDoing.title)
            }
            .navigationTitle(doing.title)

            Button {
                alertPresented = true
            } label: {
                ZStack {
                    Image(systemName: "circle")
                    Image(systemName: "plus")
                }
            }
            .alert("Take a new step", isPresented: $alertPresented) {
                TextField("", text: $subDoingText)
                Button("Cancel", role: .cancel) {}
                Button("Save", role: .none) {
                    var decodedUserDefaultDoings = try? JSONDecoder().decode([String: [Doing]].self, from: userDefaultDoings)

                    if var currentDescription = decodedUserDefaultDoings?["doings"]?.first(where: { $0.id == doing.id })?.subDoings {
                        currentDescription.append(Doing(id: UUID(), title: subDoingText, subDoings: []))

                        if let index = decodedUserDefaultDoings?["doings"]?.firstIndex(where: { $0.id == doing.id }) {
                            decodedUserDefaultDoings?["doings"]?[index].subDoings = currentDescription
                        }
                        if let data = try? JSONEncoder().encode(decodedUserDefaultDoings) {
                            self.userDefaultDoings = data
                        }
                    }
                }
            }
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

