//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Yo on 24/1/24.
//

import UIKit
   
protocol AlertPresenterDelegate: AnyObject {  // создаем протокол делегата для Алерт презентора и подписывваем его на вьюконтроллер
    // 1. тот кто подписан на этот протокол (в данном случае это вью контроллер) должен показать этот метод
    // 2. передаем в этот метод структуру алерт модели
    func showAlert(alert: UIAlertController)
}
