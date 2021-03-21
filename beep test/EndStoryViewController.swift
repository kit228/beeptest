//
//  EndStoryViewController.swift
//  beep test
//
//  Created by Вениамин Китченко on 25/07/2018.
//  Copyright © 2018 Вениамин Китченко. All rights reserved.
//

import UIKit

class EndStoryViewController: UIViewController {

    @IBOutlet weak var timeEndLabel: UILabel?
    
    var timeEndText: String = "00 : 00"
    
    override func viewWillAppear(_ animated: Bool) {
        timeEndLabel?.text = timeEndText
        print("Хранимое время на EndStory:",timeEndText)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
