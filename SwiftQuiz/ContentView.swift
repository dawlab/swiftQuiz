//
//  CustomView.swift
//  AnimalsGallery
//
//  Created by Dawid Łabno on 17/01/2023.
//

import UIKit

class CustomView: UIView {
    
    
    @IBOutlet var ContentView: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CustomView", owner: self)
        addSubview(ContentView)
        ContentView.frame = self.bounds
        ContentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
