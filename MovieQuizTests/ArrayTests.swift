//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Yo on 24/2/24.
//

import Foundation
import XCTest
@testable import MovieQuiz // Импортируем наше приложение для тестирования

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        //Дано — массив (например, массив чисел) из 5 элементов,
        let array = [1,1,2,3,5]
        
        //Когда — мы берём элемент по индексу 2, используя наш сабскрипт
        let value = array[safe: 2]
        
        //Тогда — этот элемент существует и равен третьему элементу из массива (потому что отсчёт индексов в массиве начинается с 0)
        XCTAssertNotNil(value) // Элемент по индексу существует
        XCTAssertEqual(value, 2) // Элемент равен 2
    }
    
    func testGetValueOutOfRange() throws {
        //Дано
        let array = [1,1,2,3,5]
        
        //Когда
        let value = array[safe: 20]
        
        //Тогда
        XCTAssertNil(value)
    }
}
