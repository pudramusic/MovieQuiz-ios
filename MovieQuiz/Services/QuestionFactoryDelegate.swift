//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Yo on 23/1/24.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}


