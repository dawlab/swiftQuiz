//
//  ViewController.swift
//  AnimalsGallery
//
//  Created by Dawid Łabno on 15/01/2023.
//

import UIKit

class ViewController: UIViewController {
    
    var allQuestions: [String: String] = [
        "How is a dictionary different from an array?": " It’s all down to how you access data: arrays must be accessed using the index of each element, whereas dictionaries can be accessed using something you define – strings are very common. Make sure and give practical examples of where each would be used.",
        "What are the main differences between classes and structs in Swift?": "Your answer ought to include a discussion of value types (like structs) and reference types (like classes), but also the fact that classes allow inheritance. Classes have also deinit method.",
        "What does the Codable protocol do?": "This protocol was introduced in Swift 4 to let us quickly and safely convert custom Swift types to and from JSON, XML, and similar.",
        "What is the difference between an array and a set?": "sets can be thousands of times faster than arrays depending on how many elements they contain. If you can, go on to give specific examples of where a set would be a better idea than an array.",
        "Why is immutability important?": "Immutability is baked deep into Swift, and Xcode even warns if var was used when let was possible. It’s important because it’s like a programming contract: we’re saying This Thing Should Not Change, so if we try to change it the compiler will refuse.",
        "How would you explain delegates to a new Swift developer?": "Delegation allows you to have one object act in place of another, for example your view controller might act as the data source for a table. The delegate pattern is huge in iOS, so try to pick a small, specific example such as UITableViewDelegate from UIKit – something you can dissect from memory.",
        "What is the difference between the Float, Double, and CGFloat data types?": "It’s a question of how many bits are used to store data: Float is always 32-bit, Double is always 64-bit, and CGFloat is either 32-bit or 64-bit depending on the device it runs on, but realistically it’s just 64-bit all the time.",
        "What are tuples and why are they useful?": "Tuples are a bit like anonymous structs, and are helpful for returning multiple values from a method in a type-safe way, among other things.",
        "What’s the importance of key decoding strategies when using Codable?": "Give a specific answer first – “key decoding strategies let us handle difference between JSON keys and property names in our Decodable struct” – then provide some kind of practical sample. For example, you might say that it’s common for JSON keys to use snake_case for key names, whereas in Swift we prefer camelCase, so we need to use a key decoding strategy to convert between the two.",
        "What is type erasure and when would you use it?": "Type erasure allows us to throw away some type information, for example to say that an array of strings is actually just AnySequence – it’s a sequence containing strings, but we don’t know exactly what kind of sequence."
    ]
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
    var isActive = false
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
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
            newCard.addGestureRecognizer(tap)
        } else {
            currentReload = reloadQuiz()
            showReloadView(currentReload!)
        }
    }
    
    @objc func handleTap() {
        isActive = !isActive

        if isActive {
            activateCurrentPicture()
        } else {
            deactivateCurrentPicture()
        }
    }
    
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
        let cardView = CustomView()
        cardView.frame = CGRect(x: self.view.frame.width, y: self.view.center.y - (originalSize / 2), width: originalSize, height: originalSize)
        cardView.isUserInteractionEnabled = true
        cardView.backgroundColor = .white
        cardView.mainLabel.text = Array(allQuestions.keys)[nextIndex]
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
    
    func activateCurrentPicture() {
        UIView.animate(withDuration: 0.3) {
            self.currentCard?.layer.shadowOpacity = 0.5
            self.currentCard?.layer.borderColor = UIColor.darkGray.cgColor
        }
        currentCard?.answerLabel.text = allQuestions[(currentCard?.mainLabel.text!)!]
    }

    func deactivateCurrentPicture() {
        UIView.animate(withDuration: 0.3) {
            self.currentCard?.layer.shadowOpacity = 0
        }
        currentCard?.answerLabel.text = "Tap on a card to see the answer"
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
