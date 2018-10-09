//
//  EventTableViewCell.swift
//  LiveDaybreak
//
//  Created by Austin Van Alfen on 9/25/18.
//  Copyright © 2018 Austin Van Alfen. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with event: EventDetail) {
        let url = URL(string: event.detailImageURL.replacingOccurrences(of: " ", with: "%20"))!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let data = data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.eventImageView.image = image
                }
            }
        }
        
        self.detailLabel.text = event.title + event.timeLocation
        
        task.resume()
    }

}
