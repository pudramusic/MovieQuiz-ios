//
//  Movie.swift
//  MovieQuiz
//
//  Created by Yo on 28/1/24.
//

// 📕 если какая-то часть свойств JSON не нужна, то ее можно не вписывать в структуру или закомментировать уже имеющиеся

import Foundation

struct Actor: Codable {
    
    // добавляем (перечисляем) ключи к структуре и подписываем на протокол CodingKey
    enum CodingKeys: CodingKey {
        case id, image, name, asCharacter
    }
    
    let id: String
    let image: String
    let name: String
    let asCharacter: String
/*
    init(from decoder: Decoder) throws {
        // создаём контейнер, в котором будут содержаться все поля будущей структуры; оттуда мы и достанем значения по ключам
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.image = try container.decode(String.self, forKey: .image)
        self.name = try container.decode(String.self, forKey: .name)
        self.asCharacter = try container.decode(String.self, forKey: .asCharacter)
    }
*/
}

struct Movie: Codable {
    
    // добавляем (перечисляем) ключи к структуре и подписываем на протокол CodingKey
    enum CodingKeys: CodingKey {
        case id, title, year, image, releaseDate, runtimeMins, director, actorList
    }
    
    // создаём кастомный enum для обработки ошибок
    enum ParseError: Error {
        case yearFailure
        case runtimeMinsFailure
    }
    
    let id: String
    let title: String
    let year: Int
    let image: String
    let releaseDate: String
    let runtimeMins: Int
    let director: String
    let actorList: [Actor]
    
        // если тип данных свойства не String, то добавляем инициализатор в структуру
    init(from decoder: Decoder) throws {
    
        // создаём контейнер, в котором будут содержаться все поля будущей структуры; оттуда мы и достанем значения по ключам
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // созданный контейнер инициализирует все свойства структуры
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        
        // преобразовываем из String в Int
        let year = try container.decode(String.self, forKey: .year)
        guard let yearValue = Int(year) else {
            throw ParseError.yearFailure
        }
        self.year = yearValue
        
        self.image = try container.decode(String.self, forKey: .image)
        self.releaseDate = try container.decode(String.self, forKey: .releaseDate)
        
        // преобразовываем из String в Int
        let runtimeMins = try container.decode(String.self, forKey: .runtimeMins)
        guard let runtimeMinsValue = Int(runtimeMins) else {
            throw ParseError.runtimeMinsFailure
        }
        self.runtimeMins = runtimeMinsValue
        
        self.director = try container.decode(String.self, forKey: .director)
        self.actorList = try container.decode([Actor].self, forKey: .actorList)
    }
}

