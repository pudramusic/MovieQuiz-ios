//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Yo on 7/2/24.
//

import Foundation

struct NetworkClient {
    // создаем перечисление возможных ошибок
    private enum NetworkError: Error {
        case codeError
    }
    
    // фунция загрузки урл и обработки ошибок
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        // создаем запрос
        let request = URLRequest(url: url)
        // проверяем на ошибки и обрабатываем их
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // делаем проверку пришла ли ошибка
            if let error = error {
                // обрабатываем и возвращаем результат
                handler(.failure(error))
                return
            }
            // проверяем пришел ли успешный код ответа
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                // обрабатываем и возвращаем результат
                handler(.failure(NetworkError.codeError))
                return
            }
            // если ошибок нет, то обрабатываем ответ
            guard let data = data else { return }
            // обрабатываем и возвращаем результат
            handler(.success(data))
        }
        // все ошибки обработаны, получен ответ, теперь возобновляем работу приложения
        task.resume()
    }
}
