//
//  ViewController.swift
//  Project18
//
//  Created by MacBook on 26/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        print("Some message", "yes", terminator: "")
//
//        assert(1 == 1, "Math failure") // if 1 is not 1, we will print "Math failure" (but of course it won't print it, as 1 is always 1!
//        assert(1 == 2, "Math failure") // this will crash the app
//
//        assert(myReallySlowMethod() == true, "The slow method returned false, which is a bad thing.")
//
        for i in 1...100 {
            print("Got number \(i).") // breakpoints let us stop executing the code at the chosen line and let us analyze the code done so far in the bottom left window. we can press fn+F6 to step over to the next line of the code and see it results.
        }
    }


}

