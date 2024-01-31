//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Yo on 24/1/24.
//

import UIKit

final class AlertPresenter {
   // сообщаем алерт презентору что у него теперь есть делегат
    weak var delegate: AlertPresenterDelegate?
    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }
    
    // эта функция должна заставить вьюконтроллер показзать алерту, для этого создаем протокол делегата Алерт презентора
    func showAlert(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.text,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default) { _ in
            alertModel.buttonAction()
        }
        alert.addAction(action)
        delegate?.showAlert(alert: alert)
    }
}
