//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Yo on 20/1/24.
//

import UIKit

class QuestionFactory: QuestionFactoryProtocol { //  определяем класс и подписываем на него протокол
    
    weak var delegate: QuestionFactoryDelegate? // свойство которое реализует протокол QuestionFactoryDelegate
    
    private let moviesLoader: MoviesLoader // свойство которое реализует протокол MoviesLoader
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoader, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() { // метод инициализации загрузки данных (его же добавляем в QuestionFactoryProtocol). Загружаем в него данные о фильмах)
        moviesLoader.loadMovies { [ weak self ] result in // здесь мы используем структуру movieLoader для вызова ее же метода loadMovies который загружает данные о фильмаз
            DispatchQueue.main.async { // переносим сетевой запрос в гравный поток
                guard let self = self else { return } // проверяем есть ли ссылка
                switch result { // обрабатываем результат загрузки данных
                case .success(let mostPopularMovies): // switch обрабатывавет удачное завершение загрузки
                    self.movies = mostPopularMovies.items // и если данные получены, то созраняем их свойство movie
                    self.delegate?.didLoadDataFromServer() // и одновременно сообщаем делегату что данные загрузились
                case .failure(let error): // switch обрабатывает неудачный случай загрузки
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему делегату MovieQuizViewController(а)
                }
            }
        }
    }
    func requestNextQuestion() { // превращаем MostPopularMovie в QuizQuestion
        DispatchQueue.global().async { [ weak self ] in // для начала запускаем код в другом потоке (с применением слабой ссылки для предотвращения утечки), так как работа с изображениями и сетью должны быть в отдельном потоке и не блокировали основной поток
            guard let self = self else { return } // в этих трех строчках мы выбираем произвольный элемент массива, чтобы показать его. Для этого проводим условную проверку что экземпляр класса существует
            let index = (0..<self.movies.count).randomElement() ?? 0 // создаем индекс случайного фильма из коллекции
            guard let movie = self.movies[safe: index] else { return } // проверка налиция фильма по указанному индексу
            
            var imageData = Data() // здесь мы будем создавать данные из URL, поэтому ниже обработаем ошибки
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL) // загружаем изображение по URL c исправленным размером изображения
            } catch {
                print("Failed to load image") // в случае ошибки выводим сообщение
            }
            
            let rating = Float(movie.rating) ?? 0 // Преобразование рейтинга фильма в тип Float
            let text = "Рейтинг этого фильма больше чем 7?" // формируем текст вопроса
            let correctAnswer = rating > 7 // проверяем, соответствует ли рейтинг фильма условию - больше 7
            let question = QuizQuestion(image: imageData, // теперь создаем объект, который содержит все полученные данные
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [ weak self ] in // теперь когда обработка данных завершена, необходимо вернуться в главный поток
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question) // вызываем делегат, сообщаем ему что следующий вопрос получен и передаем его
            }
        }
    }
}

