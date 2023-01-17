//
//  PlayAgainView.swift
//  AnimalsGallery
//
//  Created by Dawid Łabno on 17/01/2023.
//

import UIKit

class PlayAgainView: UIView {

    @IBOutlet var playAgainView: UIView!
    @IBOutlet weak var reloadImageView: UIImageView!
    @IBOutlet weak var knownSummary: UILabel!
    @IBOutlet weak var unknownSummary: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PlayAgainView", owner: self)
        addSubview(playAgainView)
        playAgainView.frame = self.bounds
        playAgainView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
