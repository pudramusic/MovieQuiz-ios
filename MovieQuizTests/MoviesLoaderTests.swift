//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Yo on 24/2/24.
//

import Foundation
import XCTest
@testable import MovieQuiz // импортируем наше приложение для тестирования

struct StubNetworkClient: NetworkRouting {
    
    enum TestError: Error { // тестовая ошибка
    case test
    }
    
    let emulateError: Bool // ошибка или успешная загрузка
    
    private var expectedResponse: Data { // заранее созданный тестовый ответ с сервера в формате Data
            """
                        {
                           "errorMessage" : "",
                           "items" : [
                              {
                                 "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                                 "fullTitle" : "Prey (2022)",
                                 "id" : "tt11866324",
                                 "imDbRating" : "7.2",
                                 "imDbRatingCount" : "93332",
                                 "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                                 "rank" : "1",
                                 "rankUpDown" : "+23",
                                 "title" : "Prey",
                                 "year" : "2022"
                              },
                              {
                                 "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                                 "fullTitle" : "The Gray Man (2022)",
                                 "id" : "tt1649418",
                                 "imDbRating" : "6.5",
                                 "imDbRatingCount" : "132890",
                                 "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                                 "rank" : "2",
                                 "rankUpDown" : "-1",
                                 "title" : "The Gray Man",
                                 "year" : "2022"
                              }
                            ]
                          }
                        """.data(using: .utf8) ?? Data()
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
           if emulateError {
               handler(.failure(TestError.test))
           } else {
               handler(.success(expectedResponse))
           }
       }
   }

   class MoviesLoaderTests: XCTestCase {
       func testSuccessLoading() throws {
           // Given
           let stubNetworkClient = StubNetworkClient(emulateError: false) // Говорим, что не хотим эмулировать ошибку
           let loader = MoviesLoader(networkClient: stubNetworkClient)
           
           // When
           let expectation = expectation(description: "Loading expectation") // Так как функция загрузки фильмов — асинхронная, нужно ожидание
           
           loader.loadMovies { result in
               // Then
               switch result {
               case .success(let movies):
                   XCTAssertEqual(movies.items.count, 2) // Проверка загрузки двух элементов как в тестовых данных

                   expectation.fulfill()
               case .failure(_): // Мы не ожидаем, что пришла ошибка; если она появится, надо будет провалить тест
                   XCTFail("Unexpected failure") // Эта функция проваливает тест
               }
           }
           
           waitForExpectations(timeout: 1)
       }
       
       func testFailureLoading() throws {
           // Given
           let stubNetworkClient = StubNetworkClient(emulateError: true) // Говорим, что не хотим эмулировать ошибку
           let loader = MoviesLoader(networkClient: stubNetworkClient)
           
           // When
           let expectation = expectation(description: "Loading expectation") // Так как функция загрузки фильмов — асинхронная, нужно ожидание
           
           loader.loadMovies { result in
               // Then
               switch result {
               case .failure(let error):
                   XCTAssertNotNil(error)
                   expectation.fulfill()
               case .success(_):
                   XCTFail("Unexpected failure")
               }
           }
           
           waitForExpectations(timeout: 1)
       }
}
