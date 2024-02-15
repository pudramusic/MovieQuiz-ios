//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Yo on 22/1/24.
//

import Foundation

protocol QuestionFactoryProtocol: AnyObject {
    var delegate: QuestionFactoryDelegate? { get set }
    
    func requestNextQuestion()
    func loadData() // метод инициализации загрузки данных (его же добавляем в QuestionFactory)
}


    

