//
//  ViewController.swift
//  AnimalsGallery
//
//  Created by Dawid Łabno on 15/01/2023.
//

import UIKit

class ViewController: UIViewController {
    
    var allQuestions = [
        "What is a protocol?",
        "What is an IBOutlet?",
        "What is the difference between class and struct?"]
    var knownQuestions = [String]()
    var unknownQuestions = [String]()
    
    @IBOutlet weak var knowLabel: UILabel!
    @IBOutlet weak var dontKnowLabel: UILabel!
    
    @IBOutlet weak var knownStats: UILabel!
    
    @IBOutlet weak var unknownStats: UILabel!
    
    
    @IBOutlet weak var CheckmarkImageView: UIImageView!
    @IBOutlet weak var CrossImageView: UIImageView!
    
    var nextIndex = 0
    var currentCard: CustomView?
    var currentReload: PlayAgainView?
    let originalSize: CGFloat = 300
//    var isActive = false
    var activeSize: CGFloat {
        return originalSize + 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNextCard()
        
    }
    
    func showNextCard() {
        if let newCard = createCard() {
            currentCard = newCard
            showCard(newCard)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
            pan.delegate = self
            newCard.addGestureRecognizer(pan)
        } else {
            currentReload = reloadQuiz()
            showReloadView(currentReload!)
        }
    }
    
//    @objc func handleTap() {
//        isActive = !isActive
//
//        if isActive {
//            activateCurrentPicture()
//        } else {
//            deactivateCurrentPicture()
//        }
//    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        hideCard(currentCard!)
        showNextCard()
    }
                                             
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let view = currentCard else { return }
        
        switch sender.state {
        case .began, .changed:
            processPictureMovement(sender: sender, view: view)
            knowLabel.text = "I know this"
            dontKnowLabel.text = "I don't know"
            
        case .ended:
            if view.frame.intersects(CrossImageView.frame) {
                unknownQuestions.append((currentCard?.mainLabel.text)!)
                unknownStats.text = "Unknown: \(unknownQuestions.count)"
                deletePicture(cardView: currentCard!)
            } else if view.frame.intersects(CheckmarkImageView.frame){
                knownQuestions.append((currentCard?.mainLabel.text)!)
                knownStats.text = "Known: \(knownQuestions.count)"
                deletePicture(cardView: currentCard!)
            } else {
                view.layer.borderColor = UIColor.darkGray.cgColor
                view.layer.borderWidth = 0
            }
        knowLabel.text = ""
        dontKnowLabel.text = ""
        default: break
        }
    }
    
    func processPictureMovement(sender: UIPanGestureRecognizer, view: CustomView) {
        let translation = sender.translation(in: view)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        sender.setTranslation(.zero, in: view)
        
        if view.frame.intersects(CrossImageView.frame) {
            view.layer.borderColor = UIColor.red.cgColor
            view.layer.borderWidth = 2
        } else if view.frame.intersects(CheckmarkImageView.frame){
            view.layer.borderColor = UIColor.green.cgColor
            view.layer.borderWidth = 2
        }
    }
    
    func deletePicture(cardView: CustomView) {
        UIView.animate(withDuration: 0.4, animations: {
            cardView.alpha = 0
        }) { (_) in
            cardView.removeFromSuperview()
        }
        showNextCard()
    }
    func createCard() -> CustomView? {
        guard nextIndex < allQuestions.count else { return nil }
        print(nextIndex)
        let cardView = CustomView()
        cardView.frame = CGRect(x: self.view.frame.width, y: self.view.center.y - (originalSize / 2), width: originalSize, height: originalSize)
        cardView.isUserInteractionEnabled = true
        cardView.backgroundColor = .white
        cardView.mainLabel.text = allQuestions[nextIndex]
        cardView.alpha = 0.9
        
        //Add a shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowRadius = 10
        
        nextIndex += 1
        return cardView
    }
    
    func showCard(_ cardiew: CustomView) {
        self.view.addSubview(cardiew)
        
        UIView.animate(withDuration: 0.4) {
            cardiew.center = self.view.center
        }
    }
    
    func hideCard(_ cardView: CustomView) {
        UIView.animate(withDuration: 0.4, animations: {
            self.currentCard?.frame.origin.y = -self.originalSize
        }, completion: { (_) in
            cardView.removeFromSuperview()
        })
    }
    
    func reloadQuiz() -> PlayAgainView? {
        let reloadView = PlayAgainView()
        reloadView.frame = CGRect(x: self.view.frame.width, y: self.view.center.y - (originalSize / 2), width: originalSize, height: originalSize)
        reloadView.isUserInteractionEnabled = true
        reloadView.knownSummary.text = "Known: \(knownQuestions.count)"
        reloadView.unknownSummary.text = "Unknown: \(unknownQuestions.count)"
        
        return reloadView
    }
    
    func showReloadView(_ reload: PlayAgainView) {
        self.view.addSubview(reload)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.refreshTap))
        reload.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.4) {
            reload.center = self.view.center
        }
    }
        
    @objc func refreshTap() {
        currentReload?.removeFromSuperview()
        knownQuestions.removeAll()
        unknownQuestions.removeAll()
        knownStats.text = "Known: 0"
        unknownStats.text = "Unknown: 0"
        nextIndex = 0
        showNextCard()
    }
    
//    func activateCurrentPicture() {
//        UIView.animate(withDuration: 0.3) {
//            self.currentPicture?.frame.size = CGSize(width: self.activeSize, height: self.activeSize)
//            self.currentPicture?.layer.shadowOpacity = 0.5
//            self.currentPicture?.layer.borderColor = UIColor.green.cgColor
//        }
//    }
//
//    func deactivateCurrentPicture() {
//        UIView.animate(withDuration: 0.3) {
//            self.currentPicture?.frame.size = CGSize(width: self.originalSize, height: self.originalSize)
//            self.currentPicture?.layer.shadowOpacity = 0
//            self.currentPicture?.layer.borderColor = UIColor.darkGray.cgColor
//        }
//    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
