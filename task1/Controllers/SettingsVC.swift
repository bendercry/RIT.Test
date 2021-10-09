//
//  SettingsVC.swift
//  task1
//
//  Created by Kirill Benderskii on 02.10.2021.
//

import UIKit
//MARK: Delegate mph
protocol IsMPHDelegate: AnyObject{
    func returnedIsMPH(isMPH: Bool)
}

class SettingsVC: UIViewController {
    //MARK: Variables
    var isMPH: Bool = false
    weak var delegate: IsMPHDelegate? = nil
    
    //MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        isMPHSwitch.isOn = isMPH
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    //MARK: @IB
    @IBOutlet weak var isMPHSwitch: UISwitch!
    @IBAction func changedIsMPHSwitch(_ sender: UISwitch) {
        isMPH = !isMPH
        delegate?.returnedIsMPH(isMPH: isMPH)
    }
    
}
