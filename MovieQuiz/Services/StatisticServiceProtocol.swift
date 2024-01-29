//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Yo on 29/1/24.
//

import Foundation

protocol StatisticService {
    // содержится результат игры
    var totalAccuracy: Double { get }
    // количество завершенных игр
    var gameCount: Int  { get }
    // информация о лучшей попытке
    var bestGame: GameRecord { get }
    // средняя точность правильных ответов за все ишры в процентах
    
    //  метод для сохранения текущего результата игры
    func store(correct count: Int, total amount: Int)
}
