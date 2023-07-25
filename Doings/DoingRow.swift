//
//  DoingRow.swift
//  Doings
//
//  Created by Mahima Chawla on 6/12/23.
//

import SwiftUI

struct DoingRow: View {
    
    var doing: Doing
    var body: some View {
        HStack {
            Text(doing.title)
            Spacer()
        }
    }
}

struct DoingRow_Previews: PreviewProvider {
    static var doings = ModelData().doings
    static var previews: some View {
        Group {
            DoingRow(doing: doings[0])
            DoingRow(doing: doings[1])
            DoingRow(doing: doings[2])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
