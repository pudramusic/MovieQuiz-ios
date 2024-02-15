//
//  NetworkErrorModel.swift
//  MovieQuiz
//
//  Created by Yo on 7/2/24.
//

import Foundation

struct NetworkError {
    let title: String
    let text: String
    let buttonText: String
    let buttonAction: () -> Void
}
