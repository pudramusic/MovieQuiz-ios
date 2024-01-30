import UIKit

//подписываем класс виью контроллера под протокол делегата Алерт преззентера, тем самым показываем что вьконтроллер может являться делегатом Алерт презентора
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
 
    // MARK - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var questionTitleLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var questionLabel: UILabel!
    
    // MARK - Properties
    
    // счетчик вопросов
    private var currentQuestionIndex = 0
    // счетчик правильных ответов
    private var correctAnswers = 0
    // всего вопросов
    private let questionsAmount: Int = 10
    // ссылка на делегат фабрики вопросов
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    
    private var currentQuestion: QuizQuestion?
    // создаем свойство класса который реализует делегат
    private var alertPresenter: AlertPresenter?
    
    // создаем сервис (свойство) по статистике класса StatisticServiceImplementation
    private var statisticService: StatisticService = StaticticServiceImplementation()
    
    // MARK - Override
    
    override func viewDidLoad() {
        
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.cornerRadius = 20

        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
        
        super.viewDidLoad()
        
        // создаем Алерт презентер
        alertPresenter = AlertPresenter(delegate: self)
        // устанавливаем связь презентора с делегатом
        alertPresenter?.delegate = self

    }
    
    // MARK - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
 
    // MARK - AlertPresenterDelegate
    
    func showAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    
    // MARK - Action
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        // отключение кнопки для избежания случайногонажатия кнопки до того как появится вопрос
        yesButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        // включение кнопки после появления вопроса
        yesButton.isEnabled = true
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        // отключение кнопки для избежания случайногонажатия кнопки до того как появится вопрос
        noButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        // включение кнопки после появления вопроса
        noButton.isEnabled = true
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    // MARK - Private
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResult()
        }
    }


    private func show(quiz result: QuizResultViewModel) {
        let alertModel  = AlertModel(
            title: result.title,
            text: result.text,
            buttonText: result.buttonText,
            buttonAction: {[ weak self ] in
                guard let self = self else {
                    return
                }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
                })
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            //
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            // предыдущий код
            //let text = correctAnswers == questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)" + "\n" +
                       "Количество сыгранных квизов: \(statisticService.gameCount)" + "\n" +
                       "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))" + "\n" +
                       "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            
            let viewModel = QuizResultViewModel(title: "Этот раунд окончен!",
                                                text: text,
                                                buttonText: "Сыграть ещё раз")
           show(quiz: viewModel)
           
        } else {
            currentQuestionIndex += 1

            self.questionFactory.requestNextQuestion()
        }
    }
}

