//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Yo on 29/1/24.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get set }   // содержится результат игры
    var gameCount: Int  { get set }         // количество завершенных игр
    var bestGame: GameRecord { get set }    // информация о лучшей попытке
    // для вычисления средней точности правильных ответов за все игры в процентах создаем две переменных с общим количеством правильных ответов и количеством вопросов
    var totalCorrectAnswer: Int { get set }
    var totalAmount: Int { get set }
    
    
    func store(correct count: Int, total amount: Int)  //  метод для сохранения текущего результата игры
}
