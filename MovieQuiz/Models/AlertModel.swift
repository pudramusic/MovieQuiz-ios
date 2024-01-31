//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Yo on 24/1/24.
//

import Foundation

struct AlertModel {
    let title: String
    let text: String
    let buttonText: String
    let buttonAction: () -> Void
}
