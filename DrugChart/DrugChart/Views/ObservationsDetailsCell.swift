//
//  ObservationsDetailsCell.swift
//  vitalsigns
//
//  Created by Noureen on 03/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit

class ObservationsDetailsCell: UITableViewCell {

    private var observation:VitalSignObservation!
    
    @IBOutlet weak var respiratory: UILabel!
    @IBOutlet weak var commaScore: UILabel!
    @IBOutlet weak var newsScore: UILabel!
    @IBOutlet weak var pulse: UILabel!
    @IBOutlet weak var bm: UILabel!
    @IBOutlet weak var bp: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var spo2: UILabel!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getObservation()-> VitalSignObservation
    {
        return observation!
    }
    
    func configureCell(observation:VitalSignObservation)
    {
        self.observation = observation
        commaScore.text = observation.getComaScore()
        newsScore.text = observation.getNews()
        spo2.text = observation.getSpo2Reading()
        respiratory.text = observation.getRespiratoryReading()
        pulse.text = observation.getPulseReading()
        bp.text = observation.getBloodPressureReading()
        bm.text = observation.getBMReading()
        temperature.text = observation.getTemperatureReading()
        date.text = observation.getFormattedDate()
        
    }
    
}
