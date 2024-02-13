//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Yo on 29/1/24.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int // количество  правильных ответов
    let total: Int   // количество вопросов квиза
    let date: Date   // дата завершения раунда
    
    init(correct: Int, total: Int, date: Date) {
        self.correct = correct
        self.total = total
        self.date = date
    }
    
    func  isBetterThan(_ another: GameRecord) -> Bool { // метод сравнения рекордов  исходя из количества правильных ответов
        correct > another.correct
    }
}
