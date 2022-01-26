//
//  AnotationController.swift
//  Lesson24
//
//  Created by Владислав Пуцыкович on 24.01.22.
//

import UIKit

class AnotationController: UIViewController {

    var annotation: AnnotationStudent!
    
    var tableView = UITableView()
    
    var annotationValues = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createTableView()
    }

    func createTableView() {
        tableView = UITableView(frame: view.frame)
        tableView.dataSource = self
        tableView.backgroundColor = .white
        view.addSubview(tableView)
    }
}
// MARK: UITableViewDataSource

extension AnotationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annotationValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = annotationValues[indexPath.item]
        return cell
    }
}
