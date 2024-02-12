//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Yo on 9/2/24.
//

import UIKit

struct MostPopularMovies: Codable {
    let errorMessage: String
    let item: [MostPopularMovies]
}

struct MostPopularMovies: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    // если имена в JSON не совпадают с именами полей в структуре, то надо указать соответствие между полями в структуре и JSON
    private enum CodingKeys: String, CodingKeys {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
