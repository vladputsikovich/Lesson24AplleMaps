//
//  ViewController.swift
//  Lesson24
//
//  Created by Владислав Пуцыкович on 23.01.22.

import UIKit
import MapKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
struct AnnotationStudent {
    var nameFemale: String
    var year: String
    var coordinate: (Double, Double)
}

fileprivate struct Constants {
    static let minskLatitude: Double = 53.3359
    static let minskLongitude: Double = 27.34
    static let countOfStudent = 20
    static let imageSize: CGSize = CGSize(width: 50, height: 50)
    static let manImageName = "man"
    static let womanImageName = "woman"
    static let mapAnotationIdentificator = "Annotation"
    static let meetPlaceText = "Место встречи"
    static let smallRadius: Double = 25000
    static let middleRadius: Double  = 50000
    static let largeRadius: Double  = 75000
    static let statsViewWidth: CGFloat = 100
    static let statsViewWHeigth: CGFloat = 100
    static let alphaForStatsView: Double = 0.5
    static let alphaForCircle: Double = 0.5
}

class ViewController: UIViewController {

    var students = [Student]()
    var mapStudents = MKMapView()
    
    var locationManager = CLLocationManager()
    
    var statsView = UIView()
    var label1 = UILabel()
    var label2 = UILabel()
    var label3 = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        students = StudentCreator.createStudents(countOfStudent: Constants.countOfStudent)
        createMap()
        createStatsView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationEnabled()
        addStudentsOnMap()
        addMeetPlace()
        addPath()
        
    }
    //MARK: Create view elements
    func createMap() {
        mapStudents = MKMapView(frame: view.frame)
        mapStudents.centerCoordinate = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(Constants.minskLatitude),
            longitude: CLLocationDegrees(Constants.minskLongitude)
        )
        mapStudents.delegate = self
        view.addSubview(mapStudents)
    }
    
    func createStatsView() {
        statsView = UIView(
            frame: CGRect(
                x: .zero,
                y: .zero,
                width: Constants.statsViewWidth,
                height: Constants.statsViewWHeigth
            )
        )
        statsView.backgroundColor = .white.withAlphaComponent(Constants.alphaForStatsView)
        view.addSubview(statsView)
        label1 = UILabel(
            frame: CGRect(
                x: .zero,
                y: .zero,
                width: statsView.frame.width,
                height: statsView.frame.height / 3
            )
        )
        label2 = UILabel(
            frame: CGRect(
                x: .zero,
                y: label1.frame.maxY,
                width: statsView.frame.width,
                height: statsView.frame.height / 3
            )
        )
        label3 = UILabel(
            frame: CGRect(
                x: .zero,
                y: label2.frame.maxY,
                width: statsView.frame.width,
                height: statsView.frame.height - label2.frame.maxY
            )
        )
        statsView.addSubview(label1)
        statsView.addSubview(label2)
        statsView.addSubview(label3)
    }
    
    // MARK: Methods for check location enabled
    
    func checkLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            setupManger()
        } else {
            let alert = UIAlertController(
                title: "GPS disable",
                message: "GPS disable, are you need make enable?",
                preferredStyle: .alert
            )
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alert) in
                if let url = URL(string: "App-Prefs:root=LOCATION_SERVICES") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func setupManger() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: Methods for add cicle and path on map
    
    func addStudentsOnMap() {
        students.forEach { student in
            let studentPoint = MKPointAnnotation()
            studentPoint.title = "\(student.female) \(student.name)"
            studentPoint.subtitle = "\(student.year)"
            studentPoint.coordinate = CLLocationCoordinate2D(
                latitude: Constants.minskLatitude + student.coordinates.0,
                longitude: Constants.minskLongitude + student.coordinates.1
            )
            mapStudents.addAnnotation(studentPoint)
        }
    }
    
    func addMeetPlace() {
        let meetPoint = MKPointAnnotation()
        meetPoint.title = Constants.meetPlaceText
        meetPoint.coordinate = CLLocationCoordinate2D(
            latitude: Constants.minskLatitude,
            longitude: Constants.minskLongitude
        )
        addRadiusCircle(
            location: CLLocation(
                latitude: Constants.minskLatitude,
                longitude: Constants.minskLongitude
            )
        )
        mapStudents.addAnnotation(meetPoint)
    }
    
    func addRadiusCircle(location: CLLocation){
        let circle1 = MKCircle(
            center: location.coordinate,
            radius: Constants.smallRadius as CLLocationDistance
        )
        let circle2 = MKCircle(
            center: location.coordinate,
            radius: Constants.middleRadius as CLLocationDistance
        )
        let circle3 = MKCircle(
            center: location.coordinate,
            radius: Constants.largeRadius as CLLocationDistance
        )
        
        label1.text = "\(Constants.smallRadius): " + String(radiusSearchPoints(
            coordinate: CLLocationCoordinate2D(
                latitude: Constants.minskLatitude,
                longitude: Constants.minskLongitude
            ), radius: Constants.smallRadius))
        label2.text = "\(Constants.middleRadius): " + String(radiusSearchPoints(
            coordinate: CLLocationCoordinate2D(
                latitude: Constants.minskLatitude,
                longitude: Constants.minskLongitude
            ), radius: Constants.middleRadius))
        label3.text = "\(Constants.largeRadius): " + String(radiusSearchPoints(
            coordinate: CLLocationCoordinate2D(
                latitude: Constants.minskLatitude,
                longitude: Constants.minskLongitude
            ), radius: Constants.largeRadius))
        mapStudents.addOverlay(circle1)
        mapStudents.addOverlay(circle2)
        mapStudents.addOverlay(circle3)
    }
    
    func radiusSearchPoints(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) -> Int {
        var countStudentOnRadius = 0
        students.forEach { student in
            let distance: CLLocationDistance = CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude).distance(
                    from: CLLocation(
                        latitude: student.coordinates.0 + Constants.minskLatitude,
                        longitude: student.coordinates.1 + Constants.minskLongitude
                    )
                )
            if distance < radius {
                countStudentOnRadius += 1
            }
        }
        return countStudentOnRadius
    }
    
    func addPath() {
        guard let student = students.randomElement() else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(
            placemark: MKPlacemark(
                coordinate: CLLocationCoordinate2D(
                    latitude: student.coordinates.0 + Constants.minskLatitude,
                    longitude: student.coordinates.1 + Constants.minskLongitude),
                addressDictionary: nil
            )
        )
        request.destination = MKMapItem(
            placemark: MKPlacemark(
                coordinate: CLLocationCoordinate2D(
                    latitude: Constants.minskLatitude,
                    longitude: Constants.minskLongitude),
                addressDictionary: nil
            )
        )
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                mapStudents.addOverlay(route.polyline)
                mapStudents.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func showAnotationController(nameFemale: String, year: String, coord: (Double, Double)) {
        let controller = AnotationController()
        
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            controller.annotationValues.append(nameFemale)
            controller.annotationValues.append(year)
            controller.annotationValues.append("\(coord.0) - \(coord.1)")
        }
        present(controller, animated: true, completion: nil)
    }
}

// MARK: MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.mapAnotationIdentificator)
        
        var imageAnnotation = UIImage(named: Constants.manImageName)
        if annotation.title == Constants.meetPlaceText {
            imageAnnotation = UIImage(named: Constants.womanImageName)
            annotationView.isDraggable = true
            annotationView.setDragState(.dragging, animated: true)
        }
        annotationView.image = imageAnnotation?.resized(to: Constants.imageSize)
        let rightButton = UIButton(type: .contactAdd)
        guard let title = annotation.title as? String else { return MKAnnotationView()}
        guard let subtitle = annotation.subtitle as? String else { return MKAnnotationView()}
        rightButton.addAction(
            UIAction(
                handler: {_ in self.showAnotationController(
                    nameFemale: title,
                    year: subtitle,
                    coord: (annotation.coordinate.latitude, annotation.coordinate.longitude)
                )}),
            for: .touchUpInside)
        rightButton.tag = annotation.hash
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = rightButton
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = .red
            circle.fillColor = .red.withAlphaComponent(Constants.alphaForCircle)
            circle.lineWidth = 1
            return circle
        }
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.blue
            return renderer
        }
        return MKOverlayRenderer()
    }
    
}

// MARK: CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
}

