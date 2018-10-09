//
//  DetailsViewController.swift
//  LiveDaybreak
//
//  Created by Austin Van Alfen on 9/25/18.
//  Copyright © 2018 Austin Van Alfen. All rights reserved.
//

import UIKit
import WebKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    public var detailURL: String = ""
    public var event: EventDetail?

    override func viewDidLoad() {
        super.viewDidLoad()

        updateView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save to Calendar", style: .plain, target: self, action: #selector(saveToCalendar))
    }
    
    private func updateView() {
        guard let url = URL(string: detailURL) else { print("Error with detail url"); return }
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    
    @objc func saveToCalendar() {
        // Update the user interface for the detail item.
        guard let urlDetail = URL(string: detailURL), let data = try? Data(contentsOf: urlDetail), let doc = TFHpple(htmlData: data) else {
            print("Error getting data for url")
            return
        }
        let eventDetailElement = (doc.search(withXPathQuery: "/html/body/div[1]/div/div/div[2]/table") as! [TFHppleElement]).first!
        
        var date = eventDetailElement.content.components(separatedBy: "\n")[3]
        var time = eventDetailElement.content.components(separatedBy: "\n")[7]
        var locationOne = eventDetailElement.content.components(separatedBy: "\n")[11]
        var locationTwo = eventDetailElement.content.components(separatedBy: "\n")[12]
        var locationThree = eventDetailElement.content.components(separatedBy: "\n")[13]
        
        while locationOne.first! == " " {
            locationOne.removeFirst()
        }
        
        while locationTwo.first! == " " {
            locationTwo.removeFirst()
        }
        
        while locationThree.first! == " " {
            locationThree.removeFirst()
        }
        
        while date.first! == " " {
            date.removeFirst()
        }
        
        while time.first! == " " {
            time.removeFirst()
        }
        
        time = time.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "pm", with: "").replacingOccurrences(of: "am", with: "")
        
        let timeComponents = time.components(separatedBy: "-")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy hh:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let startTime = dateFormatter.date(from: date + " " + timeComponents[0])
        let endTime = dateFormatter.date(from: date + " " + timeComponents[1])
        
        print(startTime)
        print(endTime)
        
        let eventInformation = EventInformation(title: self.event!.title, startDate: startTime!, endDate: endTime!, location: locationOne + " " + locationTwo + " " + locationThree, info: "")
        eventInformation.delegate = self
        eventInformation.saveToCalendar()
        
        print("Done")
    }

}

extension DetailsViewController: EventSavedDelegate {
    
    func eventFinished(with status: EventSavedStatus, details: String) {
        if status == .failed {
            let alert = UIAlertController(title: "Something Went Wrong", message: "Couldn't save the event to your calendar.\n\(details)", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Success", message: "Event successfully saved to calendar", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
