//
//  CellDelegate.swift
//  DrugChart
//
//  Created by Noureen on 22/12/2015.
//
//

import Foundation
protocol CellDelegate
{
    func moveNext(rowNumber:Int)
    func movePrevious(rowNumber:Int)
    func selectedCell(cell:UICollectionViewCell)
    func cellValueChanged(rowNumber:Int , object:AnyObject)
}
protocol ButtonAction
{
    func nextButtonAction()
    func previousButtonAction()
}


extension CellDelegate
{
    func moveNext(rowNumber:Int){}
    func movePrevious(rowNumber:Int){}
    func selectedCell(cell:UICollectionViewCell){}
    func cellValueChanged(rowNumber:Int, object:AnyObject){}
}
