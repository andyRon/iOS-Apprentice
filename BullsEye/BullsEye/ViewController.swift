//
//  ViewController.swift
//  BullsEye
//
//  Created by Andy Ron on 2019/7/21.
//  Copyright © 2019 Andy Ron. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
  var currentValue: Int = 50
  var targetValue = 0
  var score = 0
  var round = 0
  
  @IBOutlet weak var slider: UISlider!
  @IBOutlet weak var targetLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var roundLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  // Do any additional setup after loading the view.
    startNewGame()
    
    let thumbImageNormal = UIImage(named: "SliderThumb-Normal")!
    slider.setThumbImage(thumbImageNormal, for: .normal)
    
    let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")!
    slider.setThumbImage(thumbImageHighlighted, for: .highlighted)
    
    let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    
    let trackLeftImage = UIImage(named: "SliderTrackLeft")!
    let trackLeftResizeable = trackLeftImage.resizableImage(withCapInsets: insets)
    slider.setMinimumTrackImage(trackLeftResizeable, for: .normal)
    
    let trackRightImage = UIImage(named: "SliderTrackRight")!
    let trackRightResizeable = trackRightImage.resizableImage(withCapInsets: insets)
    slider.setMaximumTrackImage(trackRightResizeable, for: .normal)
  }


  @IBAction func showAlert() {
    let difference = abs(currentValue - targetValue)
    var points = 100 - difference
    
    let title: String
    if difference == 0 {
      title = "Perfect!"
      points += 100
    } else if difference < 5 {
      title = "You almost had it!"
      if difference == 1 {
        points += 50
      }
    } else if difference < 10 {
      title = "Pretty good!"
    } else {
      title = "Not even close..."
    }
    score += points
    
    let message = "You scored \(points) points"
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: {
      _ in
      self.startNewRound()
    })
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
    
  }
  
  @IBAction func sliderMoved(_ slider: UISlider) {
    currentValue = lroundf(slider.value)
    
  }
  
  @IBAction func startOver() {
    startNewGame()
  }
  
  func startNewRound() {
    round += 1
    
    currentValue = 50
    targetValue = Int.random(in: 1...100)
    slider.value = Float(currentValue)
    updateLables()
  }
  
  func updateLables() {
    targetLabel.text = String(targetValue)
    scoreLabel.text = String(score)
    roundLabel.text = String(round)
  }
  
  func startNewGame() {
    score = 0
    round = 0
    startNewRound()
  }
}

