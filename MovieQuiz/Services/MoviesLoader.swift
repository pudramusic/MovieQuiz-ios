//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Yo on 9/2/24.
//


// у нас есть NetworkClient и модель данных MostPopularMovies. Теперь это объеденим тут чтобы по запросу получать нашу модель данных
// для этого создаем сервис для загрузки фильмов через NetwokClient и преобразовывать их в моделт данных MostPopularMovies
import UIKit

protocol MoviesLoading { // создаем протокол для загрузчика фильмов
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
        
}

struct MoviesLoader: MoviesLoading { // создаем загрузчик который будет реализовывать протокол
    
    // MARK: - NetworkClient
   
    private let networkClient = NetworkClient()  // чтобы создавать запросы к API нужен NetworkClient, создаем его как приватную переменную
    
    //MARK: - URL
  
    private var mostPopularMoviesURL: URL {   // так же нам понадобится URL в виде URL метода для получения фильмов
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else { // преобразовываем строку в URL
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
   
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {  // создаем загрузчик который будет реализовывать протокол
        networkClient.fetch(url: mostPopularMoviesURL) { result in // вызываем метод networkClient и передаем ему ссылку на список фильмов
            switch result { // перебираем полученную ссылку
            case .success(let data):
                do { // и в случае успеха декодируем данные из ссылки в объект MostPopularMovies
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies)) // полученые данные передаем в замыкание
                } catch { // в случае не успеха ловим ошибку и с помощью замыкания handler передаем ему ошибку
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
    
  

