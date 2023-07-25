//
//  Doing.swift
//  Doings
//
//  Created by Mahima Chawla on 6/12/23.
// Creates an object Doing with all its properties.

import Foundation


struct Doing: Identifiable, Codable {
    var id = UUID()
    var title: String
    var subDoings: [Doing] = []
}

