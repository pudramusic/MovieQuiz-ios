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
}


