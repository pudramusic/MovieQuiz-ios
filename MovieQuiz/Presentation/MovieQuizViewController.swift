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
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    // создаем свойство класса который реализует делегат
    private var alertPresenter: AlertPresenter?
    
    // MARK - Override
    
    override func viewDidLoad() {
        
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.cornerRadius = 20

        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
        
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
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
    
    // MARK - Action
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let giveAnswer = true
        
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let giveAnswer = false
        
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
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

    func showAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    private func show(quiz result: QuizResultViewModel) {
        let alertModel  = AlertModel(title: result.title,
                                     text: result.text,
                                     buttonText: result.buttonText, buttonAction: {[ weak self ] in
            guard let self = self else {
                return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
                })
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            let text = correctAnswers == questionsAmount ? "Поздравляем, вы ответили на 10 ил 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultViewModel(title: "Раунд окончен!",
                                                text: text,
                                                buttonText: "Сыграть ещё раз")
           show(quiz: viewModel)
           
        } else {
            currentQuestionIndex += 1

            self.questionFactory.requestNextQuestion()
        }
    }
}

