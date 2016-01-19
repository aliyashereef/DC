//
//  OneThirdScreenTabularView.swift
//  DrugChart
//
//  Created by Noureen on 13/01/2016.
//  This is similar to tabular view functionality wise but it will diplay a different view on iphone just because of the short space.
//

import UIKit

class OneThirdScreenTabularView: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,ObservationDelegate {
   
    @IBOutlet weak var stripView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var dateHeadingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var observationList:[VitalSignObservation]!
    let headerCellIdentifier = "headerCellIdentifier"
    let contentCellIdentifier = "contentCell"
    var selectedObservation:VitalSignObservation! = nil
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
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! OneThirdContentCell
        
        cell.clearCell()
        
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
        }
        if(selectedObservation  != nil)
        {
            cell.configureCell(observationType, observation: selectedObservation)
        }
        return cell
    }
    // MARK: CollectionView Items
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return observationList.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let observation = observationList[indexPath.row]
        selectedObservation = observation
        tableView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier(headerCellIdentifier, forIndexPath: indexPath) as! HeaderCollectionViewCell
        cell.changeBackgroundColor() // explicitly set the background color for all cells
        let observation = observationList[indexPath.row]
        cell.configureCell(observation.date)
        cell.layer.borderWidth = Constant.BORDER_WIDTH
        cell.layer.borderColor = Constant.CELL_BORDER_COLOR
        cell.layer.cornerRadius = Constant.CORNER_RADIUS
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
