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
    var correctAnswers = 0 // счетчик правильных ответов
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol? // ссылка на делегат фабрики вопросов
    var statisticService: StatisticService = StaticticServiceImplementation() // создаем сервис (свойство) по статистике класса StatisticServiceImplementation
    
    
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
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        viewController?.showLoadingIndicator()
        viewController?.noButton.isEnabled = false  // отключение кнопки для избежания случайногонажатия кнопки до того как появится вопрос
        viewController?.yesButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    
    
    func didReceiveNextQuestion(question: QuizQuestion?) {  // метод получения нового вопроса и отображения его на экране. Вопроса может не быть и тогда метод ничего не делает
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        viewController?.noButton.isEnabled = true  // включение кнопки сразу после появления вопроса
        viewController?.yesButton.isEnabled = true
    }
    
    
    
    func showNextQuestionOrResult() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)" + "\n" +
                       "Количество сыгранных квизов: \(statisticService.gameCount)" + "\n" +
                       "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))" + "\n" +
                       "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            
            let viewModel = QuizResultViewModel(title: "Этот раунд окончен!",
                                                text: text,
                                                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
           
        } else {
            self.switchToNextQuestion()

            questionFactory?.requestNextQuestion()
        }
    }
    
    
}
