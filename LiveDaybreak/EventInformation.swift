//
//  EventInformation.swift
//  LiveDaybreak
//
//  Created by Austin Van Alfen on 9/25/18.
//  Copyright © 2018 Austin Van Alfen. All rights reserved.
//

import Foundation
import EventKit

enum EventSavedStatus {
    case failed
    case success
}

protocol EventSavedDelegate: class {
    func eventFinished(with status: EventSavedStatus, details: String)
}

class EventInformation {
    
    weak var delegate: EventSavedDelegate?
    
    lazy private var eventStore: EKEventStore = EKEventStore()
    
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String
    let info: String
    
    init(title: String, startDate: Date, endDate: Date, location: String, info: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.info = info
        
    }
    
    func saveToCalendar() {
        eventStore.requestAccess(to: .event) { (value, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if value {
                if let calendar = self.eventStore.defaultCalendarForNewEvents{
                    self.save(to: calendar)
                    print("Calendar exists")
                } else {
                    self.delegate?.eventFinished(with: .failed, details: "No default calendar to save to.")
                }
            } else {
                print("failssss")
            }
        }
    }
    
    private func save(to calendar: EKCalendar) {
        
        let event = EKEvent(eventStore: self.eventStore)
        
        event.startDate = self.startDate
        event.endDate = self.endDate
        event.title = self.title
        event.timeZone = TimeZone(abbreviation: "MDT")
        event.notes = self.info
        event.calendar = calendar
        
        do {
            try self.eventStore.save(event, span: .thisEvent)
            self.delegate?.eventFinished(with: .success, details: "")
            print("Save Success")
        } catch {
            self.delegate?.eventFinished(with: .failed, details: error.localizedDescription)
            print("Save Fail\n\(error.localizedDescription)")
        }
        print("Success")
    }
}
