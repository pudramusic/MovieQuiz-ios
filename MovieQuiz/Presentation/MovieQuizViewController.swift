import UIKit

//подписываем класс виью контроллера под протокол делегата Алерт преззентера, тем самым показываем что вьконтроллер может являться делегатом Алерт презентора
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
 
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var questionTitleLabel: UILabel!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
//    private var correctAnswers = 0 // счетчик правильных ответов
//    private var questionFactory: QuestionFactoryProtocol? // ссылка на делегат фабрики вопросов
    private var alertPresenter: AlertPresenter? // создаем свойство класса который реализует делегат
    private var presenter = MovieQuizPresenter() // создаем свойство класса
//    private var statisticService: StatisticService = StaticticServiceImplementation() // создаем сервис (свойство) по статистике класса StatisticServiceImplementation
 
    // MARK: - Override
    
    override func viewDidLoad() {
        
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.cornerRadius = 20

        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        presenter.questionFactory?.delegate = self
        presenter.questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenter(delegate: self)  // создаем Алерт презентер
        alertPresenter?.delegate = self  // устанавливаем связь презентора с делегатом
        
        presenter.statisticService = StaticticServiceImplementation()
        
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
        
        presenter.viewController = self
        
        super.viewDidLoad()

    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() { // метод успешной загрузки данных
        hideLoadingIndicator() // вызываем функцию скрытия индикатор загрузки
        presenter.questionFactory?.requestNextQuestion() // делаем запрос к фабрике вопросов для загрузки следующего вопроса с сервера.
    }

    func didFailToLoadData(with error: Error) {  // метод загрузки ошибки и показ ошибки на экране
        hideLoadingIndicator() // вызываем функцию скрытия индикатор загрузки
        showNetworkError(message: error.localizedDescription) // берем в качестве сообщения описание ошибки
    }
   
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
 
    // MARK: - public
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presenter.showNextQuestionOrResult()
        }
    }
    
    func showLoadingIndicator() { // добавили функцию, которая будет показывать индикатор загрузки
        activityIndicator.isHidden = false // указываем что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() { // добавляем функцию которая будет скрывать индикатор
        activityIndicator.isHidden = true // указываем что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию
    }

    // MARK: - AlertPresenterDelegate
    
    func showAlert(alert: UIAlertController) {
        hideLoadingIndicator() // скрываем индикатор перед показом алерты
        self.present(alert, animated: true)
    }
    
    // MARK: - Private
    
    func show(quiz step: QuizStepViewModel) { // функция предоставления данных из QuizStepViewModel
        hideLoadingIndicator()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }
    
    private func showNetworkError(message: String) {  // добавляем алерту которая покажет ошибки
        hideLoadingIndicator() // скрываем индикатор перед показом алерты с ошибкой
        let model = AlertModel(title: "Что-то пошло не так(",
                               text: message,
                               buttonText: "Попробовать ещё раз") { [ weak self ] in
                                  guard let self = self else { return }
                                  presenter.resetQuestionIndex()
                                  presenter.correctAnswers = 0
                                  presenter.questionFactory?.loadData()
        }
        alertPresenter?.showAlert(alertModel: model)
    }

    func show(quiz result: QuizResultViewModel) {
        hideLoadingIndicator() // скрываем индикатор
        let alertModel  = AlertModel(title: result.title,
                                     text: result.text,
                                     buttonText: result.buttonText,
                                     buttonAction: {[ weak self ] in
                                     guard let self = self else {
                                     return
                                     }
                                     presenter.resetQuestionIndex()
                                     presenter.correctAnswers = 0
                                     presenter.questionFactory?.requestNextQuestion()
        })

        alertPresenter?.showAlert(alertModel: alertModel)
    }
 
//    func showNextQuestionOrResult() {
//    }
    
    
    // MARK: - Action
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) { 
        presenter.yesButtonClicked()

    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}

