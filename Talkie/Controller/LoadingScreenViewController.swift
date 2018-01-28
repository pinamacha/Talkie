//
//  LoadingScreenViewController.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/22/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            // your code here For Pushing to Another Screen
            self.loadNewView()
        }
    }
    func loadNewView() {
        performSegue(withIdentifier: "LoadToLogin", sender: nil)
    }
    


}


