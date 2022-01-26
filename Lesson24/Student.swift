//
//  Student.swift
//  Lesson24
//
//  Created by Владислав Пуцыкович on 23.01.22.
//

import Foundation

fileprivate struct Constants {
    static let names = ["vlad", "sasah", "kirrila", "voca", "oleg"]
    static let females = ["puts", "ijke", "some", "dame", "cole"]
    static let countOfStudents = 20
    static let downRangeYear = 1970
    static let upRangeYear = 2000
    static let downRangeCoordinates: Double = -1
    static let upRangeCoordinates: Double = 1
}

class Student {
    var name: String
    var female: String
    var year: Int
    var coordinates: (Double, Double)
    
    init(name: String, female: String, year: Int, cooridinates: (Double, Double) ) {
        self.name = name
        self.female = female
        self.year = year
        self.coordinates = cooridinates
    }
}

struct StudentCreator {
    static func createStudents(countOfStudent: Int) -> [Student] {
        var students = [Student]()
        (.zero..<Constants.countOfStudents).forEach { number in
            let student = Student(
                name: Constants.names.randomElement() ?? String(),
                female: Constants.females.randomElement() ?? String(),
                year: Int.random(in: (Constants.downRangeYear...Constants.upRangeYear)),
                cooridinates: (
                    Double.random(in: Constants.downRangeCoordinates...Constants.upRangeCoordinates),
                    Double.random(in: Constants.downRangeCoordinates...Constants.upRangeCoordinates)
                )
            )
            students.append(student)
        }
        return students
    }
}
