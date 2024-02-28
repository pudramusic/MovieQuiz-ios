//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Yo on 28/2/24.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    
    // MARK: - Properties
    
    
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers = 0 // счетчик правильных ответов
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol? // ссылка на делегат фабрики вопросов
    var statisticService: StatisticService = StaticticServiceImplementation() // создаем сервис (свойство) по статистике класса StatisticServiceImplementation
    
    private weak var viewController: MovieQuizViewController?
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
   
    // MARK: - QuestionFactoryDelegate
    
    
    func didLoadDataFromServer() { // метод успешной загрузки данных
        viewController?.hideLoadingIndicator() // вызываем функцию скрытия индикатор загрузки
        questionFactory?.requestNextQuestion() // делаем запрос к фабрике вопросов для загрузки следующего вопроса с сервера.
        }
    
    func didFailToLoadData(with error: Error) {  // метод загрузки ошибки и показ ошибки на экране
        viewController?.hideLoadingIndicator() // вызываем функцию скрытия индикатор загрузки
        viewController?.showNetworkError(message: error.localizedDescription) // берем в качестве сообщения описание ошибки
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
    
    
    // MARK: - Function (currentQuestionIndex)
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() { // метод обнуления ответов
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    
    // MARK: - Function
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel { // принимаем и преобразует «модельные данные» в данные для представления
        return QuizStepViewModel( // создаем функцию с тремя параметрами
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func makeResultsMessage() -> String { // выносим логику преобразования статистики в отдельный метод
        statisticService.store(correct: correctAnswers, total: self.questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let currentGameResultsLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let totalPlaysCounLine = "Количество сыгранных квизов: \(statisticService.gameCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [currentGameResultsLine,
                             totalPlaysCounLine,
                             bestGameInfoLine,
                             averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
    
    
    // MARK: - Private
    
    
   private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)

        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.proceedToNextQuestionOrResult()
        }
    }

   private func proceedToNextQuestionOrResult() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let text = makeResultsMessage()
            
            
            let viewModel = QuizResultViewModel(title: "Этот раунд окончен!",
                                                text: text,
                                                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
           
        } else {
            self.switchToNextQuestion()

            questionFactory?.requestNextQuestion()
        }
    }
    
   private func didAnswer(isCorrectAnswer: Bool) { // метод подсчета правильных ответов
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    
    private func didAnswer(isYes: Bool) { // функция проверки ответа на вопрос (вынесли за пределы yesButton и noButton, чтобы не повторять код)
        
        viewController?.showLoadingIndicator()
        viewController?.noButton.isEnabled = false  // отключение кнопки для избежания случайногонажатия кнопки до того как появится вопрос
        viewController?.yesButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    // MARK: - Function (Action)
    
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }

}
