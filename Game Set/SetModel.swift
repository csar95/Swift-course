//
//  SetModel.swift
//  Game Set
//
//  Created by Cesar Gutierrez Carrero on 26/1/18.
//  Copyright © 2018 Cesar Gutierrez Carrero. All rights reserved.
//

import Foundation
import UIKit
import GameplayKit.GKRandomSource

protocol CheckFeaturesProtocol {
    func checkForColor(in selectedCards: [Card]) -> Bool
    func checkForShape(in selectedCards: [Card]) -> Bool
    func checkForShade(in selectedCards: [Card]) -> Bool
    func checkForTime(in selectedCards: [Card]) -> Bool
}

class SetModel {
    
    var points = 0
    //private(set) var cardsBeingPlayed = [Card]()
    private(set) var selectedCards = [Card]()
    var deck = [Card]()
    
    private(set) var board = [Card?]()
    
    init() {
        generateDeck()
        
        // Shuffle cards
        deck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: deck) as! [Card]
        
        // Initialize board with 12 cards
        for i in 0..<24 {
            i < 12 ? addCardToBoard(at: nil) : board.append(nil)
        }
    }
    
    func chooseCard(at index: Int) {
        
        if let chosenCard = board[index] {
            // If chosen card is not currently selected
            if (!selectedCards.contains(chosenCard)) {
                selectedCards.append(chosenCard)
                
                if (selectedCards.count == 3) {
                    // Check if selected cards form a set
                    let isSet = checkForColor(in: selectedCards) && checkForShape(in: selectedCards) && checkForShade(in: selectedCards) && checkForTime(in: selectedCards)
                    
                    if isSet {
                        if !deck.isEmpty {
                            if (countOfNotNil(in: board) > 12) {
                                // Remove cards that form set
                                for card in selectedCards {
                                    if let index = getIndex(of: card) {
                                        board[index] = nil
                                    }
                                    else {
                                        print("ERROR: Selected card not found in board")
                                    }
                                }
                            }
                            else {
                                // Subtitute cards in set for new ones from the deck
                                for card in selectedCards {
                                    if let index = getIndex(of: card) {
                                        addCardToBoard(at: index)
                                    }
                                    else {
                                        print("ERROR: Selected card not found in board")
                                    }
                                }
                            }
                        }
                        points += 3
                    }
                    else {
                        points -= 5
                    }
                    // Clear list of selected cards
                    selectedCards.removeAll()
                }
            }
                // If chosen card is already selected, deselect it
            else {
                selectedCards.remove(at: selectedCards.index(of: chosenCard)! )
                points -= 1
            }
        }
    }
    
    func add3MoreCards () {
        if (countOfNotNil(in: board) < 24 && !deck.isEmpty) {
            var numberOfCardsToAdd = 3
            for index in 0..<board.count {
                if (board[index] == nil && numberOfCardsToAdd > 0) {
                    addCardToBoard(at: index)
                    numberOfCardsToAdd -= 1
                }
            }
        }
    }
    
    func reset () {
        board = [Card?]()
        selectedCards = [Card]()
        deck = [Card]()
        points = 0
        
        generateDeck()
        
        // Shuffle cards
        deck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: deck) as! [Card]
        
        // Initialize board with 12 cards
        for i in 0..<24 {
            i < 12 ? addCardToBoard(at: nil) : board.append(nil)
        }
    }
    
    func countOfNotNil (in array: [Card?]) -> Int {
        var count = 0
        for i in 0..<array.count {
            if let _ = array[i] { count += 1 }
        }
        return count
    }
    
    private func getIndex(of card: Card) -> Int? {
        for index in 0..<board.count {
            if (board[index] != nil && board[index] == card) {
                return index
            }
        }
        return nil
    }
    
    private func addCardToBoard (at index: Int?) {
        // Take random card from deck and put it on the board
        let randomIndex = deck.count.arc4random
        let randomCard = deck.remove(at: randomIndex)
        
        if let i = index {
            board[i] = randomCard
        }
        else {
            board.append(randomCard)
        }
    }
    
    // This function generates all possible combinations
    private func generateDeck() {
        let shapes = ["●", "■", "▲"] // circle, square, triangle
        let colors = [UIColor.green, UIColor.red, UIColor.blue] // green, red, blue
        let shading = [[-5.0, 1.0], [-5.0, 0.15], [5.0, 1.0]] // solid, striped, open
        
        for shape in shapes {
            for color in colors {
                for times in 1...3 {
                    for shade in shading {
                        
                        let attributes: [NSAttributedStringKey : Any] = [
                            .strokeWidth : shade[0],
                            .foregroundColor : color.withAlphaComponent(CGFloat(shade[1]))
                        ]
                        let attributedString = NSMutableAttributedString(string: shape, attributes: attributes)
                        
                        for _ in 1..<times {
                            attributedString.append( NSAttributedString(string: shape, attributes: attributes) )
                        }
                        addCardToDeck(color: color, shape: shape, shade0: shade[0], shade1: shade[1], times: times, attrString: attributedString)
                    }
                }
            }
        }
    }
    
    private func addCardToDeck(color: UIColor, shape: String, shade0: Double, shade1: Double, times: Int, attrString: NSAttributedString) {
        
        var c = Colors.green, sp = Shapes.circle, t = Numbers.one, sd = Shading.open
        
        switch color{
            case UIColor.green: c = Colors.green
            case UIColor.red: c = Colors.red
            case UIColor.blue: c = Colors.blue
            default: break
        }
        switch shape{
            case "●": sp = Shapes.circle
            case "■": sp = Shapes.square
            case "▲": sp = Shapes.triangle
            default: break
        }
        switch shade0{
            case -5.0:
                if (shade1 == 1.0) {
                    sd = Shading.solid
                }
                else {
                    sd = Shading.striped
                }
            case 5.0: sd = Shading.open
            default: break
        }
        switch times{
            case 1: t = Numbers.one
            case 2: t = Numbers.two
            case 3: t = Numbers.three
            default: break
        }
        
        // Create card with certain features and add it to the deck
        let card = Card(content: attrString, color: c, shape: sp, times: t, shade: sd)
        deck.append(card)
    }
    
    // It probably wants to keep track of which cards have already been matched.
}



/******************************************/
/*  IMPLEMENTING CHECK FEATURES PROTOCOL  */
/******************************************/

extension SetModel: CheckFeaturesProtocol {
    func checkForColor (in selectedCards: [Card]) -> Bool {
        if (selectedCards[0].color == selectedCards[1].color && selectedCards[0].color == selectedCards[2].color && selectedCards[1].color == selectedCards[2].color) {
            return true
        }
        else if (selectedCards[0].color != selectedCards[1].color && selectedCards[0].color != selectedCards[2].color && selectedCards[1].color != selectedCards[2].color){
            return true
        }
        else {
            return false
        }
    }
    
    func checkForShape (in selectedCards: [Card]) -> Bool {
        if (selectedCards[0].shape == selectedCards[1].shape && selectedCards[0].shape == selectedCards[2].shape && selectedCards[1].shape == selectedCards[2].shape) {
            return true
        }
        else if (selectedCards[0].shape != selectedCards[1].shape && selectedCards[0].shape != selectedCards[2].shape && selectedCards[1].shape != selectedCards[2].shape){
            return true
        }
        else {
            return false
        }
    }
    
    func checkForShade (in selectedCards: [Card]) -> Bool {
        if (selectedCards[0].shade == selectedCards[1].shade && selectedCards[0].shade == selectedCards[2].shade && selectedCards[1].shade == selectedCards[2].shade) {
            return true
        }
        else if (selectedCards[0].shade != selectedCards[1].shade && selectedCards[0].shade != selectedCards[2].shade && selectedCards[1].shade != selectedCards[2].shade){
            return true
        }
        else {
            return false
        }
    }
    
    func checkForTime (in selectedCards: [Card]) -> Bool {
        if (selectedCards[0].times == selectedCards[1].times && selectedCards[0].times == selectedCards[2].times && selectedCards[1].times == selectedCards[2].times) {
            return true
        }
        else if (selectedCards[0].times != selectedCards[1].times && selectedCards[0].times != selectedCards[2].times && selectedCards[1].times != selectedCards[2].times){
            return true
        }
        else {
            return false
        }
    }
}