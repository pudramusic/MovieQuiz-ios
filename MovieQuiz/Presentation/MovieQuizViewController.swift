import UIKit

//подписываем класс виью контроллера под протокол делегата Алерт преззентера, тем самым показываем что вьконтроллер может являться делегатом Алерт презентора
final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    
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
    
    
    private var alertPresenter: AlertPresenter? // создаем свойство класса который реализует делегат
    private var presenter: MovieQuizPresenter! // создаем свойство класса
    
    
    // MARK: - Override
    
    
    override func viewDidLoad() {
        
        alertPresenter = AlertPresenter(delegate: self)  // создаем Алерт презентер
        alertPresenter?.delegate = self  // устанавливаем связь презентора с делегатом
        
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
    }
    
    
    // MARK: - AlertPresenterDelegate
    
    
    func showAlert(alert: UIAlertController) {
        hideLoadingIndicator() // скрываем индикатор перед показом алерты
        self.present(alert, animated: true)
    }
    
    
    //  MARK: - Private
    
    func changeStateButtons(isEnable: Bool) { // временное включение и отключение кнопок
        yesButton.isEnabled = isEnable
        noButton.isEnabled = isEnable
    }
    
    func showLoadingIndicator() { // добавили функцию, которая будет показывать индикатор загрузки
        activityIndicator.isHidden = false // указываем что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() { // добавляем функцию которая будет скрывать индикатор
        activityIndicator.isHidden = true // указываем что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    func show(quiz step: QuizStepViewModel) { // функция предоставления данных из QuizStepViewModel
        hideLoadingIndicator()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
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
            
        })
        alertPresenter?.showAlert(alertModel: alertModel)
        self.presenter.restartGame()
    }
    
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    func showNetworkError(message: String) {  // добавляем алерту которая покажет ошибки
        hideLoadingIndicator() // скрываем индикатор перед показом алерты с ошибкой
        let model = AlertModel(title: "Что-то пошло не так(",
                               text: message,
                               buttonText: "Попробовать ещё раз") { [ weak self ] in
            guard let self = self else { return }
        }
        alertPresenter?.showAlert(alertModel: model)
        self.presenter.restartGame()
    }
    
    
    // MARK: - Action
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}

