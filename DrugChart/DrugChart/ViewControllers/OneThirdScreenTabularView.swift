//
//  OneThirdScreenTabularView.swift
//  DrugChart
//
//  Created by Noureen on 13/01/2016.
//  This is similar to tabular view functionality wise but it will diplay a different view on iphone just because of the short space.
//

import UIKit

class OneThirdScreenTabularView: PatientViewController ,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,ObservationDelegate,UIPopoverPresentationControllerDelegate  {
   
    @IBOutlet weak var stripView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var sortMenuItem: UIBarButtonItem!
    @IBOutlet weak var dateHeadingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    let headerCellIdentifier = "headerCellIdentifier"
    let contentCellIdentifier = "contentCell"
    var selectedObservation:VitalSignObservation! = nil
    var activityIndicator:UIActivityIndicatorView!
  
    var filteredObservations:[VitalSignObservation]!
    private var viewByDate:NSDate = NSDate()
    var selectedRow:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView.registerNib(UINib(nibName: "HeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:headerCellIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(UINib(nibName: "OneThirdContentCell", bundle: nil), forCellReuseIdentifier:contentCellIdentifier)
        stripView.layer.borderWidth = Constant.BORDER_WIDTH
        stripView.layer.cornerRadius = Constant.CORNER_RADIUS
        stripView.layer.backgroundColor = Constant.CELL_BORDER_COLOR
        stripView.backgroundColor = Constant.SELECTION_CELL_BACKGROUND_COLOR
        tableView.allowsMultipleSelectionDuringEditing = false
        setDateDisplay()
        reloadView()
    }
    
    func selectSpecificStripItem()
    {
        
    let indexPath = NSIndexPath(forItem: selectedRow, inSection: 0)
        self.collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.Right)
    
    collectionView(self.collectionView, didSelectItemAtIndexPath: indexPath)

    }
    override func viewDidAppear(animated: Bool) {
    }
    
    private func setDateDisplay()
    {
        sortMenuItem.title = viewByDate.getFormattedMonthandYear()
        headingLabel.text = viewByDate.getFormattedMonthName() + " " + viewByDate.getFormattedYear()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: tableview methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count  = ObservationTabularViewRow.count - 1
        return count
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? OneThirdContentCell
        if(cell == nil)
        {
            return false
        }
        if(cell!.isDeletable)
        {
            return true
        }
        else
        {
            return false
        }
        
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete)
        {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? OneThirdContentCell
            cell?.deleteObservation()
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! OneThirdContentCell
        
        let index = indexPath.row + 1
        let obsType = ObservationTabularViewRow(rawValue: index)
        var observationType:ShowObservationType!
        cell.delegate = self
        
        switch(obsType!)
        {
        case ObservationTabularViewRow.Respiratory:
            cell.title.text = Constant.RESPIRATORY
            observationType = ShowObservationType.Respiratory
            if(selectedObservation != nil)
            {
                cell.content.text = selectedObservation.getRespiratoryReading()
            }
        case ObservationTabularViewRow.SPO2:
            cell.title.text = Constant.SPO2
            observationType = ShowObservationType.SpO2
            if(selectedObservation != nil)
            {
                cell.content.text = selectedObservation.getSpo2Reading()
            }
        case ObservationTabularViewRow.Temperature:
            cell.title.text = Constant.TEMPERATURE
            observationType = ShowObservationType.Temperature
            if(selectedObservation != nil)
            {
                cell.content.text = selectedObservation.getTemperatureReading()
            }
        case ObservationTabularViewRow.BloodPressure:
            cell.title.text = Constant.BLOOD_PRESSURE
            observationType = ShowObservationType.BloodPressure
            if(selectedObservation != nil)
            {
                cell.content.text = selectedObservation.getBloodPressureReading()
            }
        case ObservationTabularViewRow.Pulse:
            cell.title.text = Constant.PULSE
            observationType = ShowObservationType.Pulse
            
            if(selectedObservation != nil)
            {
                cell.content.text = selectedObservation.getPulseReading()
            }
        case ObservationTabularViewRow.News:
            cell.title.text = Constant.NEWS
            observationType = ShowObservationType.None
            if(selectedObservation != nil)
            {
                cell.content.text = selectedObservation.getNews()
            }
        case ObservationTabularViewRow.CommaScore:
            cell.title.text = Constant.COMMA_SCORE
            observationType = ShowObservationType.None
            if(selectedObservation != nil)
            {
                cell.content.text = selectedObservation.getComaScore()
            }
        case ObservationTabularViewRow.AdditionalOxygen:
            cell.title.text = Constant.ADDITIONAL_OXYGEN
            observationType = ShowObservationType.None
            if(selectedObservation != nil)
            {
                cell.content.text = ""
            }
        case ObservationTabularViewRow.AVPU:
            cell.title.text = Constant.AVPU
            observationType = ShowObservationType.None
            if(selectedObservation != nil)
            {
                cell.content.text = ""
            }
        }
        if(selectedObservation  != nil)
        {
            cell.configureCell(observationType, observation: selectedObservation )
        }
        return cell
    }
    // MARK: CollectionView Items
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredObservations == nil ?0:  filteredObservations.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let observation = filteredObservations[indexPath.row]
        let cell =   self.collectionView.cellForItemAtIndexPath(indexPath) as? HeaderCollectionViewCell
        if(cell != nil)
        {
            cell?.setSelectionIndicators(observation.date)
        }
        selectedRow = indexPath.row
        selectedObservation = observation
        tableView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? HeaderCollectionViewCell
        let observation = filteredObservations[indexPath.row]
        if(cell != nil)
        {
            cell!.removeIndicator(observation.date)
        }
    }
      func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier(headerCellIdentifier, forIndexPath: indexPath) as! HeaderCollectionViewCell
        let observation = filteredObservations[indexPath.row]
        cell.configureOneThirdTabularCell(observation.date)
        cell.layer.borderWidth = Constant.BORDER_WIDTH
        cell.layer.borderColor = Constant.CELL_BORDER_COLOR
        cell.layer.cornerRadius = Constant.CORNER_RADIUS
        if(selectedRow == indexPath.row  )
        {
            cell.setSelectionIndicators(observation.date)
            selectedObservation = observation
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(165,60)
        
    }
    // MARK: ObservatioDelegate implementation
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
    
    // Mark: Segue methods
    @IBAction func unwindToOneThirdTabularView(sender:UIStoryboardSegue)
    {
        tableView.reloadData()
    }
    //MARK : popup presentation style implementation
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    // Mark: Delegate implementation
    func DateSelected(value:NSDate)
    {
        viewByDate = value
        setDateDisplay()
        reloadView()
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
        if(filteredObservations.count == 0)
        {
            dateHeadingLabel.text = "No Data"
            self.collectionView.hidden = true
            self.tableView.hidden = true
            stripView.hidden = true
        }
        else
        {
            selectedRow = 0
            self.collectionView.hidden = false
            self.tableView.hidden = false
            stripView.hidden = false
            self.collectionView.reloadData()
            self.tableView.reloadData()
            selectSpecificStripItem()
        }
        stopActivityIndicator(activityIndicator)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
