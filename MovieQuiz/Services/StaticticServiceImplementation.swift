//
//  StaticticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Yo on 29/1/24.
//

import Foundation
import UIKit

// реализуем протокол StatisticService для хранения данных и статистики
final class StaticticServiceImplementation: StatisticService {
    
    
    // создаем перечисление всех ключей и сущностей котрые придется хранить
    private enum Keys: String {
        case correct, total,  bestGame, gameCount, totalCorrectAnswer, totalAmount
    }
    // чтобы каждый раз при работе с UserDefaults не обрашаться к standart создадим константу
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let total = try? JSONDecoder().decode(Double.self, from: data) else {
            return 0.0
            }
            return total
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue)  else {
                print("Невозможно сохранить результат")
            return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    var gameCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gameCount.rawValue),
                  let count = try? JSONDecoder().decode(Int.self, from: data) else {
            return 0
            }
            return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
            return
            }
            userDefaults.set(data, forKey: Keys.gameCount.rawValue)
        }
    }
    
    var bestGame: GameRecord  {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
            return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
            return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalCorrectAnswer: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalCorrectAnswer.rawValue),
                  let count = try? JSONDecoder().decode(Int.self, from: data) else {
            return 0
            }
            return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
            return
            }
            userDefaults.set(data, forKey: Keys.totalCorrectAnswer.rawValue)
        }
    }
    
    var totalAmount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalAmount.rawValue),
                  let count = try? JSONDecoder().decode(Int.self, from: data) else {
            return 0
            }
            return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.totalAmount.rawValue)
        }
    }
    
    
    //  метод для сохранения текущего результата игры с проверкой на то что новый результат лучше
    func store(correct count: Int, total amount: Int) {
        let currentRecord = GameRecord(correct: count, total: amount, date: Date())
        if currentRecord.isBetterThan(bestGame) {
            bestGame = currentRecord
        }
        // изменяем счетчики статистики
        gameCount += 1
        totalCorrectAnswer = bestGame.correct + count
        totalAmount = bestGame.total + amount
        totalAccuracy = (Double(totalCorrectAnswer) / Double(totalAmount)) * 100
        
        // для округления точности используем конструкцию. Перенести в алерту
        //let formattedAccuracy = String(format: "%.2f", totalAccuracy)
        //let totalAccuracyString = "\(formattedAccuracy)%"
    }
}
