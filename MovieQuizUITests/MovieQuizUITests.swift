//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Yo on 24/2/24.
//

import XCTest

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // Это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
        
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3) // создаем такие задержки чтобы остановить действие текущего потока и дать время загрузиться данным
        
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation // так как это не картинка а UI элемент, необходимо сначала сделать скриншот этого элемента и передать как Data
        
        app.buttons["Yes"].tap() // находим кнопку ДА и нажимаем ее
        sleep(3)
        
        let secondPoster = app.images["Poster"] // еще раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation // так как это не картинка а UI элемент, необходимо сначала сделать скриншот этого элемента и передать как Data
        
        let indexLabel = app.staticTexts["Index"] // находим на экране индекс фопросов
        
        XCTAssertNotEqual(firstPosterData, secondPosterData) // проверяем что постеры разные
        XCTAssertEqual(indexLabel.label, "2/10")

    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation // так как это не картинка а UI элемент, необходимо сначала сделать скриншот этого элемента и передать как Data
        
        app.buttons["No"].tap() // находим кнопку НЕТ инажимаем ее
        sleep(3)
        
        let secondPoster = app.images["Poster"] // еще раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation // так как это не картинка а UI элемент, необходимо сначала сделать скриншот этого элемента и передать как Data
        
        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() { // тест окончания раунда и показа алерты  Можно делать по любой кнопке. Я делаю по кнопке НЕТ
        sleep(2)
        
        for _ in 1...10 { // используем цикл для повторяющихся действий, так как игра закончится через 10 нажатий кнопки
            app.buttons["No"].tap()
            sleep(3)
        }
        
        let resultAlert = app.alerts["Game results"] // находим на экране алерту
        let alertTitle = resultAlert.label
        let alertButton = resultAlert.buttons.firstMatch.label
        
        XCTAssertTrue(resultAlert.exists) // тестируем алерту
        XCTAssertEqual(alertTitle, "Этот раунд окончен!") // тестируем есть ли текст в шапке алерты
        XCTAssertEqual(alertButton, "Сыграть еще раз") // тестируем есть ли текст в кнопке алерты
    }
    
    // Тест скрытия алерта завершения игры
    func testAlertDismiss() {
        sleep(2)
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let resultAlert = app.alerts["Game results"]
        resultAlert.buttons.firstMatch.tap()
        
        sleep(5)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(resultAlert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
}


//func testExample() throws {
//    // UI tests must launch the application that they test.
//    let app = XCUIApplication()
//    app.launch()
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
