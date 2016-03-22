//
//  TabularViewController.swift
//  DrugChart
//
//  Created by Noureen on 10/12/2015.
//
//

import UIKit

class TabularViewController: PatientViewController , UICollectionViewDataSource, UICollectionViewDelegate , ObservationDelegate ,UIPopoverPresentationControllerDelegate,CellDelegate{

    @IBOutlet weak var sortMenuItem: UIBarButtonItem!
    
    let headerCellIdentifier = "headerCellIdentifier"
    let contentCellIdentifier = "contentCellIdentifier"
    let rowHeaderCellIdentifier = "rowHeaderCellIdentifier"
    
    @IBOutlet weak var collectionView: UICollectionView!
    var filteredObservations:[VitalSignObservation] = [VitalSignObservation]()
    private var viewByDate:NSDate = NSDate()
    var activityIndicator:UIActivityIndicatorView!
    
    private var selectedContentCell:ContentCollectionViewCell!
    private var contentCellTag:Int = 1
    private var showColors = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.title = "Vital Signs"
        self.collectionView .registerNib(UINib(nibName: "HeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: headerCellIdentifier)
        self.collectionView .registerNib(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
        self.collectionView .registerNib(UINib(nibName: "RowHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: rowHeaderCellIdentifier)
        collectionView.layer.borderWidth = 0.5
        collectionView.layer.borderColor = UIColor.lightGrayColor().CGColor
        setDateDisplay()
        reloadView()
    }
    
    private func setDateDisplay()
    {
        sortMenuItem.title = viewByDate.getFormattedMonthandYear()
    }
    
    private func reloadView()
    {
        let startDate = viewByDate.minDayofMonth()
        let endDate = viewByDate.maxDayofMonth()
        activityIndicator = startActivityIndicator(self.view) // show the activity indicator
        let parser = VitalSignParser()
        parser.getVitalSignsObservations(patient.patientId,commaSeparatedCodes:  Helper.getCareRecordCodes(),startDate:  startDate , endDate:  endDate,includeMostRecent:  false , onSuccess: showData)
    
    }
    
    
    func showData(fetchedObservations:[VitalSignObservation] )
    {
        filteredObservations = fetchedObservations
        let collectionViewLayOut = self.collectionView.collectionViewLayout as! CustomCollectionViewLayout
        collectionViewLayOut.setNoOfColumns(filteredObservations.count + 1)
        self.collectionView.reloadData()
        stopActivityIndicator(activityIndicator)
    }
    
    // MARK - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        contentCellTag = 1
        return ObservationTabularViewRow.count
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return ( filteredObservations.count + 1 )
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let headerCell : HeaderCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(headerCellIdentifier, forIndexPath: indexPath) as! HeaderCollectionViewCell
            
            if indexPath.row == 0 {
                headerCell.dayLabel.text = viewByDate.getFormattedMonthName()
                headerCell.dateLabel.text = "  " + viewByDate.getFormattedYear()
                headerCell.dayLabel.font = UIFont.boldSystemFontOfSize(17)
                headerCell.removeTimeLabel()
                headerCell.layoutMargins = UIEdgeInsetsZero
                headerCell.layer.borderWidth = Constant.BORDER_WIDTH
                headerCell.layer.borderColor = Constant.CELL_BORDER_COLOR
                headerCell.layer.cornerRadius = Constant.CORNER_RADIUS
                headerCell.changeBackgroundColor(UIColor.whiteColor())
                headerCell.dateLabel.textColor = UIColor.blackColor()
                return headerCell
            } else {
                let observation = filteredObservations[indexPath.row - 1]
                headerCell.configureFullTabularCell(observation.date)
                headerCell.layer.borderWidth = Constant.BORDER_WIDTH
                headerCell.layer.borderColor = Constant.CELL_BORDER_COLOR
                headerCell.layer.cornerRadius = Constant.CORNER_RADIUS
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
                case ObservationTabularViewRow.News.rawValue:
                    headerText = Constant.NEWS
                case ObservationTabularViewRow.CommaScore.rawValue:
                    headerText = Constant.COMMA_SCORE
                default:
                    headerText = ""
                }
                headerCell.backgroundColor = UIColor.whiteColor()
                
                headerCell.label.text = headerText
                headerCell.layer.borderWidth = Constant.BORDER_WIDTH
                headerCell.layer.borderColor = Constant.CELL_BORDER_COLOR
                headerCell.layer.cornerRadius = Constant.CORNER_RADIUS
                return headerCell
            } else {
                let contentCell : ContentCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.resetCellScroll()
                contentCell.tag = contentCellTag
                contentCellTag++
                let observation = filteredObservations[indexPath.row - 1]
                contentCell.delegate = self
                contentCell.selectedCellDelegate = self
                if observation.date.isToday()
                {
                    contentCell.backgroundColor = Constant.SELECTION_CELL_BACKGROUND_COLOR
                }
                else
                {
                    contentCell.backgroundColor = UIColor.whiteColor()
                }
                contentCell.layer.borderWidth = Constant.BORDER_WIDTH
                contentCell.layer.borderColor = Constant.CELL_BORDER_COLOR
                contentCell.layer.cornerRadius = Constant.CORNER_RADIUS
                
                
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
                case ObservationTabularViewRow.News.rawValue:
                    contentCell.configureCell(observation,showobservationType: .None)
                    let newsScore = observation.newsScore
                    contentCell.contentLabel.text = newsScore
                    contentCell.backgroundColor = getNewsRowColor(newsScore)
                case ObservationTabularViewRow.CommaScore.rawValue:
                    contentCell.configureCell(observation,showobservationType: .None)
                    contentCell.contentLabel.text = observation.getComaScore()
                default:
                    print("come in default section")
                }
                return contentCell
            }
        }
    }
    
    func getNewsRowColor(newsScore:String) -> UIColor
    {
        let value = Double(newsScore)
        if(value == nil)
        {
            return UIColor.whiteColor()
        }
        else if( value > 0 && value < 5)
        {
            return UIColor(forHexString: "#CEE5C8")
        }
        else if (value >= 5 && value <= 6)
        {
            return UIColor(forHexString: "#F5BB86")
        }
        else if(value >= 7)
        {
            return UIColor(forHexString: "#EE836D")
        }
        else
        {
            return UIColor.whiteColor()
        }
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        print("deselect")
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
       
        let calendar = NSCalendar.currentCalendar()
        let chosenDateComponents = calendar.components([.Month , .Year], fromDate: viewByDate)
        calendarViewController.setSelection(chosenDateComponents.month, year:chosenDateComponents.year)
        
        self.presentViewController(calendarViewController, animated: false, completion: nil)
    
        
    }
    // Mark: Delegate implementation
    func DateSelected(value:NSDate)
    {
        viewByDate = value
        setDateDisplay()
        reloadView()
    }
    
    func ShowModalNavigationController(navigationController:UINavigationController)
    {
        if(navigationController.viewControllers[0].isKindOfClass(PatientViewController))
        {
            let patientViewController = navigationController.viewControllers[0] as? PatientViewController
            patientViewController?.patient = self.patient
        }
        self.presentViewController(navigationController, animated: false, completion: nil)
    }
    
    func ShowAlertController(alertController: UIAlertController)
    {
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    

   override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    // Mark: Unwind element
    
    @IBAction func unwindToTabularView(sender:UIStoryboardSegue)
    {
      reloadView()
        
    }
    
    //Mark: store the previous selected cell
    func selectedCell(cell:UICollectionViewCell)
    {
        let contentCell = cell as? ContentCollectionViewCell
        if(selectedContentCell != nil && contentCell?.tag == selectedContentCell.tag)
        {
            return
        }
        if(selectedContentCell != nil)
        {
             selectedContentCell.resetCellScroll()
        }
        selectedContentCell = cell as? ContentCollectionViewCell
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
