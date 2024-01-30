//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Yo on 29/1/24.
//

import Foundation

struct GameRecord: Codable {
    // количество  правильных ответов
    let correct: Int
    // количество вопросов квиза
    let total: Int
    // дата завершения раунда
    let date: Date
    
    init(correct: Int, total: Int, date: Date) {
        self.correct = correct
        self.total = total
        self.date = date
    }
    
    // метод сравнения рекордов  исходя из количества правильных ответов
    func  isBetterThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}
