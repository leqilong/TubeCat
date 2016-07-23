//
//  BoxesPickerViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/16/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

protocol BoxesPickerViewControllerDelegate{
    func setupBox(index: Int?)
}

class BoxesPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var boxesData = [
        "Think Box",
        "Look Box",
        "Love Box"
    ]

    @IBOutlet weak var boxesPickerView: UIPickerView!
    
    var delegate: BoxesPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boxesPickerView.delegate = self
        boxesPickerView.dataSource = self
        
        boxesPickerView.selectRow(0, inComponent: 0, animated: false)
        //updateSelectedBox()

    }
    
    
    func updateSelectedBox(index: Int){
        delegate?.setupBox(index)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return boxesData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(boxesData[row])"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateSelectedBox(row)
    }
}
