//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Yo on 7/2/24.
//

import Foundation

struct NetworkClient {
    private enum NetworkError: Error {   // создаем перечисление возможных ошибок
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) { // фунция загрузки URL и обработки ошибок
        let request = URLRequest(url: url)  // создаем запрос
        let task = URLSession.shared.dataTask(with: request) { data, response, error in  // проверяем на ошибки и обрабатываем их
            if let error = error {  // делаем проверку пришла ли ошибка
                handler(.failure(error)) // обрабатываем и возвращаем результат
                return
            }
            
            if let response = response as? HTTPURLResponse, // проверяем пришел ли код ответа
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError)) // обрабатываем и возвращаем результат
                return
            }

            guard let data = data else { return } // если ошибок нет, то обрабатываем ответ
            handler(.success(data)) // обрабатываем и возвращаем результат
        }

        task.resume()  // все ошибки обработаны, получен ответ, теперь возобновляем работу приложения
    }
}
