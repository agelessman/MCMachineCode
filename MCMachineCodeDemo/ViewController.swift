//
//  ViewController.swift
//  MCMachineCodeDemo
//
//  Created by 马超 on 16/5/25.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBOutlet weak var resultLabel: UILabel!
  
    @IBAction func scanAction(sender: UIButton) {
        
        let machineCodeVc = MCMachineCodeViewController(lineType: LineType.LineScan, moveType: MoveType.Default)
        self.navigationController?.pushViewController(machineCodeVc, animated: true)
        
        machineCodeVc.didGetMachineCode = { code in
            
            self.resultLabel.text = code
        }
        
    }
    
    @IBAction func scanNetAction(sender: UIButton) {
        
        let machineCodeVc = MCMachineCodeViewController(lineType: LineType.Grid, moveType: MoveType.Default)
        self.navigationController?.pushViewController(machineCodeVc, animated: true)
  
        machineCodeVc.didGetMachineCode = { code in
            
            self.resultLabel.text = code
        }
    }

    @IBAction func defaultAcction(sender: AnyObject) {
       
        let machineCodeVc = MCMachineCodeViewController(lineType: LineType.Default, moveType: MoveType.Default)
        self.navigationController?.pushViewController(machineCodeVc, animated: true)
        
        machineCodeVc.didGetMachineCode = { code in
            
            self.resultLabel.text = code
        }
    }
    
  
}

