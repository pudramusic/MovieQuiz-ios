import UIKit

//подписываем класс виью контроллера под протокол делегата Алерт преззентера, тем самым показываем что вьконтроллер может являться делегатом Алерт презентора
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
 
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var questionTitleLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var currentQuestionIndex = 0 // счетчик вопросов
    private var correctAnswers = 0 // счетчик правильных ответов
    private let questionsAmount: Int = 10  // всего вопросов
    private var questionFactory: QuestionFactoryProtocol? // ссылка на делегат фабрики вопросов
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter? // создаем свойство класса который реализует делегат
    private var statisticService: StatisticService = StaticticServiceImplementation()   // создаем сервис (свойство) по статистике класса StatisticServiceImplementation
    
    // MARK: - Override
    
    override func viewDidLoad() {
        
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.cornerRadius = 20

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenter(delegate: self)  // создаем Алерт презентер
        alertPresenter?.delegate = self  // устанавливаем связь презентора с делегатом
        
        statisticService = StaticticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        super.viewDidLoad()
        

    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() { // метод успешной загрузки данных
        activityIndicator.isHidden = true // для начала скрываем индикатор загрузки
        questionFactory?.requestNextQuestion() // делаем запрос к фабрике вопросов для загрузки следующего вопроса с сервера.
    }

    func didFailToLoadData(with error: Error) {  // метод загрузки ошибки и показ ошибки на экране
        showNetworkError(message: error.localizedDescription) // берем в качестве сообщения описание ошибки
    }
   
    func didReceiveNextQuestion(question: QuizQuestion?) {  // метод получения нового вопроса и отображения его на экране. Вопроса может не быть и тогда метод ничего не делает
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
 
    // MARK: - AlertPresenterDelegate
    
    func showAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    // MARK: - Private
    
    private func showLoadingIndicator() { // добавили функцию, которая будет показывать индикатор загрузки
        activityIndicator.isHidden = false // указываем что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel { // принимаем и конвертируем вопрос квиза в квиз вью модель
        return QuizStepViewModel( // создаем функцию с тремя параметрами
            image: UIImage(data: model.image) ?? UIImage(), //
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
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

    private func showNetworkError(message: String) {  // добавляем алерту которая покажет ошибки
        activityIndicator.isHidden = true // скрываем индикатор
        let model = AlertModel(title: "Что-то пошло не так(",
                               text: message,
                               buttonText: "Попробовать ещё раз") { [ weak self ] in
                                  guard let self = self else { return }
                                  self.currentQuestionIndex = 0
                                  self.correctAnswers = 0
                                  self.questionFactory?.loadData()
        }
        alertPresenter?.showAlert(alertModel: model)
    }

    private func show(quiz result: QuizResultViewModel) {
        activityIndicator.isHidden = true // скрываем индикатор
        let alertModel  = AlertModel(title: result.title,
                                     text: result.text,
                                     buttonText: result.buttonText,
                                     buttonAction: {[ weak self ] in
                                     guard let self = self else {
                                     return
                                     }
                                     self.currentQuestionIndex = 0
                                     self.correctAnswers = 0
                                     self.questionFactory?.requestNextQuestion()
        })

        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
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

            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Action
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        yesButton.isEnabled = false // отключение кнопки для избежания случайногонажатия кнопки до того как появится вопрос
        
        guard let currentQuestion = currentQuestion else {
            return
        }

        yesButton.isEnabled = true  // включение кнопки после появления вопроса
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        noButton.isEnabled = false  // отключение кнопки для избежания случайногонажатия кнопки до того как появится вопрос
        
        guard let currentQuestion = currentQuestion else {
            return
        }
       
        noButton.isEnabled = true  // включение кнопки после появления вопроса
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
}

