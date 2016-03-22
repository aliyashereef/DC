//
//  HelpViewController.swift
//  drugchart
//
//  Created by Noureen on 23/02/2016.


import UIKit
import QuickLook
import CocoaLumberjack
class HelpViewController: UIViewController, QLPreviewControllerDataSource {
    
    // MARK: - Controller Properties
    
    let previewController = QLPreviewController()
    var docs = [NSURL]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        configureSubViews()
        
    }
    
     func configureSubViews() {
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneButtonPressed:")
        
        self.navigationItem.rightBarButtonItem = doneButton
        
        let path = NSBundle.mainBundle().pathForResource("NEWS", ofType: "pdf")!
        let fileURL = NSURL.fileURLWithPath(path)
        
        if QLPreviewController.canPreviewItem(fileURL) {
            self.docs.append(fileURL)
        } else {
            DDLogWarn("Help PDF Could Not Be Loaded")
        }
        
        previewController.dataSource = self
        previewController.currentPreviewItemIndex = 0
        
        self.view.addSubview(previewController.view)
        
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        
        return 1
        
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        
        return self.docs[index]
        
    }
    
    func doneButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
