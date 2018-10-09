//
//  DetailViewController.swift
//  LiveDaybreak
//
//  Created by Austin Van Alfen on 9/25/18.
//  Copyright © 2018 Austin Van Alfen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var detailURL: String? {
        didSet {
            // Update the view.
            configureData()
        }
    }

    func configureData() {
        // Update the user interface for the detail item.
        if let detail = detailURL {
            guard let detailURL = URL(string: detail), let data = try? Data(contentsOf: detailURL), let doc = TFHpple(htmlData: data) else {
                print("Error getting data for url")
                return
            }
            let eventElements = doc.search(withXPathQuery: "/html/body/div[1]/div/div[2]/div") as! [TFHppleElement]
            let events: [EventDetail] = {
                var array = [EventDetail]()
                for element in eventElements {
                    guard let head = (element.children(withTagName: "h2") as! [TFHppleElement])[0].content else { print("Error 0"); return [] }
                    guard let details = (element.children(withTagName: "p") as! [TFHppleElement])[0].content else { print("error 1"); return [] }
                    let imageURL = ((element.children(withTagName: "a") as! [TFHppleElement])[0].children as! [TFHppleElement])[0].attributes["src"] as! String
                    let moreInfoURL = (element.children as! [TFHppleElement])[3].attributes["href"] as! String
                    let event = EventDetail(title: head, timeLocation: details, moreInfoURL: URLStash.URLs.baseURL.rawValue + moreInfoURL, detailImageURL: URLStash.URLs.baseURL.rawValue + imageURL)
                    array.append(event)
                }
                return array
            }()
            
            self.events = events
        }
    }
    
    var events = [EventDetail]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetails" {
            if let selectedIndex = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! DetailsViewController
                let detailURL = self.events[selectedIndex.row].moreInfoURL
                destination.detailURL = detailURL
                destination.event = self.events[selectedIndex.row]
            }
        }
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as? EventTableViewCell else {
            print("Error getting event cell")
            return EventTableViewCell()
        }
        
        let event = self.events[indexPath.row]
        
        cell.configure(with: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

