//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Yo on 28/2/24.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    
    weak var viewController: MovieQuizViewController?
    
    func convert(model: QuizQuestion) -> QuizStepViewModel { // принимаем и преобразует «модельные данные» в данные для представления
        return QuizStepViewModel( // создаем функцию с тремя параметрами
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    // методы для доступа и изменения к значению currentQuestionIndex
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        viewController?.showLoadingIndicator()
        viewController?.yesButton.isEnabled = false // отключение кнопки для избежания случайногонажатия кнопки до того как появится вопрос
        
        guard let currentQuestion = currentQuestion else {
            return
        }

        viewController?.yesButton.isEnabled = true  // включение кнопки после появления вопроса
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        viewController?.showLoadingIndicator()
        viewController?.noButton.isEnabled = false  // отключение кнопки для избежания случайногонажатия кнопки до того как появится вопрос
        
        guard let currentQuestion = currentQuestion else {
            return
        }
       
        viewController?.noButton.isEnabled = true  // включение кнопки после появления вопроса
        viewController?.showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }

}
