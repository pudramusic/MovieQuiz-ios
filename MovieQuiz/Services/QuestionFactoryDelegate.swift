//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Yo on 23/1/24.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об удачной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}


