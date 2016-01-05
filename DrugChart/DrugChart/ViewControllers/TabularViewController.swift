//
//  TabularViewController.swift
//  DrugChart
//
//  Created by Noureen on 10/12/2015.
//
//

import UIKit

class TabularViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate , ObservationDelegate ,UIPopoverPresentationControllerDelegate{

    @IBOutlet weak var sortMenuItem: UIBarButtonItem!
    
    let headerCellIdentifier = "headerCellIdentifier"
    let contentCellIdentifier = "contentCellIdentifier"
    let rowHeaderCellIdentifier = "rowHeaderCellIdentifier"
    
    @IBOutlet weak var collectionView: UICollectionView!
    var observationList:[VitalSignObservation]!
    var filteredObservations:[VitalSignObservation]!
    private var viewByDate:NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.title = "Vital Signs"
        self.collectionView .registerNib(UINib(nibName: "HeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: headerCellIdentifier)
        self.collectionView .registerNib(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
        self.collectionView .registerNib(UINib(nibName: "RowHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: rowHeaderCellIdentifier)
   
        setDateDisplay()
        reloadView(observationList)
    }
    
    private func setDateDisplay()
    {
        let calendar = NSCalendar.currentCalendar()
        let chosenDateComponents = calendar.components([.Month , .Year], fromDate: viewByDate)
        let displayText = String(format: "%d / %d",chosenDateComponents.month , chosenDateComponents.year)
        sortMenuItem.title = displayText
    }
    
    private func reloadView(observationList:[VitalSignObservation])
    {
        self.observationList = observationList // order matters here
        filterList()
        let collectionViewLayOut = self.collectionView.collectionViewLayout as! CustomCollectionViewLayout
        collectionViewLayOut.setNoOfColumns(filteredObservations.count + 1)
        self.collectionView.reloadData()
    }
    
    // MARK - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return ObservationTabularViewRow.count
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ( filteredObservations.count + 1 )
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let headerCell : HeaderCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(headerCellIdentifier, forIndexPath: indexPath) as! HeaderCollectionViewCell
            headerCell.configureCell()
            
            if indexPath.row == 0 {
                headerCell.dateLabel.text = "Date"
                headerCell.timeLabel.text = "Time"
                headerCell.backgroundColor = UIColor(red: 31/255, green: 146/255, blue: 190/255, alpha: 1.0)
                return headerCell
            } else {
                let observation = filteredObservations[indexPath.row - 1]
                headerCell.dateLabel.text = observation.getFormattedDate()
                headerCell.timeLabel.text = observation.getFormattedTime()
                headerCell.backgroundColor = UIColor(red: 31/255, green: 146/255, blue: 190/255, alpha: 1.0)
                return headerCell
            }
        } else {
            if indexPath.row == 0 {
                let headerCell : RowHeaderCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(rowHeaderCellIdentifier, forIndexPath: indexPath) as! RowHeaderCollectionViewCell
                
                headerCell.configureCell()
                var headerText:String
                
                switch(indexPath.section)
                {
                case ObservationTabularViewRow.Respiratory.rawValue:
                    headerText = Constant.RESPIRATORY
                case ObservationTabularViewRow.SPO2.rawValue:
                    headerText = Constant.SPO2
                case ObservationTabularViewRow.Temperature.rawValue:
                    headerText = Constant.TEMPERATURE
                case ObservationTabularViewRow.BloodPressure.rawValue:
                    headerText = Constant.BLOOD_PRESSURE
                case ObservationTabularViewRow.Pulse.rawValue:
                    headerText = Constant.PULSE
                case ObservationTabularViewRow.BM.rawValue:
                    headerText = Constant.BM
                case ObservationTabularViewRow.News.rawValue:
                    headerText = Constant.NEWS
                case ObservationTabularViewRow.CommaScore.rawValue:
                    headerText = Constant.COMMA_SCORE
                default:
                    headerText = ""
                }
                headerCell.backgroundColor = UIColor.whiteColor()
                
                headerCell.label.text = headerText
                return headerCell
            } else {
                let contentCell : ContentCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                let observation = filteredObservations[indexPath.row - 1]
               // contentCell.configureCell(observation)
                contentCell.delegate = self
                switch(indexPath.section)
                {
                case ObservationTabularViewRow.Respiratory.rawValue:
                    contentCell.configureCell(observation,showobservationType: .Respiratory)
                    contentCell.contentLabel.text = observation.getRespiratoryReading()
                case ObservationTabularViewRow.SPO2.rawValue:
                    contentCell.configureCell(observation,showobservationType: ShowObservationType.SpO2)
                    contentCell.contentLabel.text = observation.getSpo2Reading()
                case ObservationTabularViewRow.Temperature.rawValue:
                    contentCell.configureCell(observation,showobservationType: .Temperature)
                    contentCell.contentLabel.text = observation.getTemperatureReading()
                case ObservationTabularViewRow.BloodPressure.rawValue:
                    contentCell.configureCell(observation,showobservationType: .BloodPressure)
                    contentCell.contentLabel.text = observation.getBloodPressureReading()
                case ObservationTabularViewRow.Pulse.rawValue:
                    contentCell.configureCell(observation,showobservationType: .Pulse)
                    contentCell.contentLabel.text = observation.getPulseReading()
                case ObservationTabularViewRow.BM.rawValue:
                    contentCell.configureCell(observation,showobservationType: .BM)
                    contentCell.contentLabel.text = observation.getBMReading()
                case ObservationTabularViewRow.News.rawValue:
                    contentCell.configureCell(observation,showobservationType: .None)
                    contentCell.contentLabel.text = observation.getNews()
                case ObservationTabularViewRow.CommaScore.rawValue:
                    contentCell.configureCell(observation,showobservationType: .None)
                    contentCell.contentLabel.text = observation.getComaScore()
                default:
                    print("come in default section")
                }
                contentCell.backgroundColor = UIColor.whiteColor()
                return contentCell
            }
        }
    }
    // Mark: Sorting option implementation
    @IBAction func showCalendar()
    {
        let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
        let calendarViewController : CalendarViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CalendarViewController") as! CalendarViewController
        calendarViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        calendarViewController.preferredContentSize = CGSizeMake(320,250)
        calendarViewController.popoverPresentationController?.barButtonItem = sortMenuItem
        calendarViewController.delegate = self
        
        let popOverController:UIPopoverPresentationController = calendarViewController.popoverPresentationController!
        popOverController.delegate = self
        
        self.presentViewController(calendarViewController, animated: false, completion: nil)
    }
    // Mark: Delegate implementation
    func DateSelected(value:NSDate)
    {
        viewByDate = value
        setDateDisplay()
        reloadView(observationList)
    }
    
    func EditObservation(navigationController:UINavigationController)
    {
        self.presentViewController(navigationController, animated: false, completion: nil)
    }
    
    func filterList()
    {
        let calendar = NSCalendar.currentCalendar()
        let chosenDateComponents = calendar.components([.Month , .Year], fromDate: viewByDate)
        
        filteredObservations = observationList.filter { (observationList) -> Bool in
            let components = calendar.components([.Month, .Year], fromDate:observationList.date)
            return components.month == chosenDateComponents.month && components.year == chosenDateComponents.year
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    
    
    

//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//    
//    //Mark: Delegate Implementation
//    func EditObservation(navigationController:UINavigationController)
//    {
//        self.presentViewController(navigationController, animated: false, completion: nil)
//    }
//    
//    func EditObservationViewController(viewController:UIViewController)
//    {
//        self.presentViewController(viewController, animated: false, completion: nil)
//    }
    

}
