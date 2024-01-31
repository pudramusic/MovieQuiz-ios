//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Yo on 29/1/24.
//

import Foundation

protocol StatisticService {
    // содержится результат игры
    var totalAccuracy: Double { get set }
    // количество завершенных игр
    var gameCount: Int  { get set }
    // информация о лучшей попытке
    var bestGame: GameRecord { get set }
    // для вычисления средней точности правильных ответов за все игры в процентах создаем две переменных с общим количеством правильных ответов и количеством вопросов
    var totalCorrectAnswer: Int { get set }
    var totalAmount: Int { get set }
    
    //  метод для сохранения текущего результата игры
    func store(correct count: Int, total amount: Int)
}
