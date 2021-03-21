//
//  PausePageViewController.swift
//  beep test
//
//  Created by Вениамин Китченко on 22/07/2018.
//  Copyright © 2018 Вениамин Китченко. All rights reserved.
//

import UIKit

class PausePageViewController: UIViewController {
    
    var storageTimeValue: String! // хранимая переменная времени (восклицательный знак для того? чтобы была обязательной)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EndSegue" {
            if let toEnd = segue.destination as? EndStoryViewController {
                toEnd.timeEndText = storageTimeValue
                //toEnd.timeEndLabel?.text = storageTimeValue
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("хранимое время в паузе:",storageTimeValue) // просто печает храниму переменную времени в консоле
    }
    
    
    @IBAction func PauseButtonResume(_ sender: Any) {
        dismiss(animated: true, completion: nil)  // при нажатии на кнопку Pause - возвращаемся на экран TalkPage
    }
    
    
    @IBAction func StartAgainButon(_ sender: Any) {
        //timerLabel.text = "makak"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
