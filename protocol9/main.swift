//
//  main.swift
//  protocol9
//
//  Created by Myoung-Wan Koo on 2017. 4. 11..
//  Copyright © 2017년 Myoung-Wan Koo. All rights reserved.
//

import Foundation

// Definition of protocol
protocol FullyNamed {
    var fullName: String { get}
}

// Example of simple class
struct Person: FullyNamed {
    var fullName: String
}
let john = Person(fullName: "John Appleseed")
print(" Simple Example: \(john.fullName)")

// Example of more complex class
print("\n More complex Example")
class Starship:FullyNamed{
    var prefix:String?
    var name:String
    init(name:String, prefix:String? = nil) {
        self.name = name
        self.prefix = prefix
    }
    var fullName: String {
        return (prefix != nil ? prefix! + " ":"") + name
    }
}

var ncc1701 = Starship(name: "Enterprise", prefix: "USS")
print( ncc1701.fullName)


/*********************************************/

// Method Requirements
print("\n Method Requirement")
protocol RandomNumberGenerator{
    func random()->Double
}

class LinearCongruentialGenerator: RandomNumberGenerator {
    var lastRandom = 42.0
    let m = 139968.0
    let a = 3877.0
    let c = 29573.0
    func random() -> Double {
        lastRandom = (( lastRandom * a + c).truncatingRemainder(dividingBy: m))
        return lastRandom / m
    }
}

let generator = LinearCongruentialGenerator()
print(" Here's a random number: \(generator.random())")

print(" And another one: \(generator.random())" )


// Mutating Method Requirement
print("\n Mutation Method Requirement")
protocol Togglable {
    mutating func toggle()
}

enum OnOffSwitch: Togglable{
    case off, on
    mutating func toggle() {
        switch self {
        case .off:
            self = .on
        case .on:
            self = .off
        }
    }
}
var lightSwitch = OnOffSwitch.off
lightSwitch.toggle()

switch lightSwitch {
case .off:
    print(" lightSwitch = Off")
case .on:
    print(" lightSwithc = On ")
    
}



// Protocols as Types
class Dice {
    let sides:Int
    let generator: RandomNumberGenerator
    init(sides:Int, generator: RandomNumberGenerator) {
        self.sides = sides
        self.generator = generator
    }
    func roll()->Int {
        return Int( generator.random() * Double (sides)) + 1
    }
}

var d6 = Dice(sides: 6, generator: LinearCongruentialGenerator())

for _ in 1...5 {
    print("Random dice roll is \(d6.roll())")
}


// Delegation
protocol DiceGame{
    var dice: Dice {get}
    func play()
}

protocol DiceGameDelegate {
    func gameDidStart(_ game: DiceGame )
    func game(_ game: DiceGame, didStartNewTurnWithDiceRoll : Int)
    func gameDidEnd(_ game: DiceGame)
}

class SnakesAndLadders: DiceGame {
    let finalSquare = 25
    let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
    var square = 0
    var board:[Int]
    init() {
        board = [Int] (repeating: 0, count: finalSquare+1)
        board[03] =  +08; board[06] = +11; board[09] = +9;
        board[10] = +02 ; board[14] = -10; board[10] = -11;
        board[22] = -2 ;  board[24] = -08
    }
    var delegate: DiceGameDelegate?
    
    func play() {
        square = 0
        delegate?.gameDidStart(self)
        gameLoop: while square != finalSquare {
            let diceRoll = dice.roll()
            delegate?.game(self, didStartNewTurnWithDiceRoll: diceRoll)
            switch square + diceRoll {
            case finalSquare:
                print(" board number =\(square+diceRoll)")
                break gameLoop
            case let newSquare where newSquare > finalSquare:
                print(" more than final Square board number =\(square+diceRoll)")
                continue gameLoop
            default:
                print(" board number =\(square+diceRoll)")
                square += diceRoll
                square += board[square]
            }
        }
        delegate?.gameDidEnd(self)
    }
    
}

class DiceGameTracker: DiceGameDelegate {
    var numberOfTurns = 0
    func gameDidStart(_ game: DiceGame) {
        numberOfTurns = 0
        if game is SnakesAndLadders {
            print(" Started a new game of Snakes and Ladders")
        }
        print(" The game is using a \(game.dice.sides) - sided dice")
    }
    func game(_ game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int) {
        numberOfTurns += 1
        print("Rolled a \(diceRoll)")
    }
    func gameDidEnd(_ game: DiceGame) {
        print(" The game lasted for \(numberOfTurns) turns")
    }
    
}

let tracker = DiceGameTracker()
let game = SnakesAndLadders()
game.delegate = tracker
game.play()


// Adding Protocol Conformance with an Extension Protocol
print(" \nAdding Protocol Conformance with an Extension ")

protocol TextRepresentable {
    func asText() -> String
}

extension Dice: TextRepresentable {
    func asText() -> String {
        return "A \(sides)-sided dice"
    }
}

let d12 = Dice(sides: 12, generator: LinearCongruentialGenerator())
print(d12.asText())

extension SnakesAndLadders : TextRepresentable {
    func asText() -> String {
        return "A game of Snakes and Ladders with \(finalSquare) squares"
    }
}

print(game.asText())

// Declaring Protocal Adoption with an Extension
struct Hamster {
    var name: String
    func asText() ->String {
        return "A hamster named \(name)"
    }
    
}

extension Hamster: TextRepresentable {}

let simonTheHamster = Hamster(name: "Simon")
let somethingTextRepresentable: TextRepresentable = simonTheHamster

print(somethingTextRepresentable.asText())

// Collection of protocol Types
print("\n Collection of protocol Types")
let things: [TextRepresentable] = [game, d12, simonTheHamster]

for thing in things {
    print(thing.asText())
}

// protocol Inheritance
protocol PrettyTextRepresentable: TextRepresentable {
    func asPrettyText() -> String
    
}
extension SnakesAndLadders: PrettyTextRepresentable {
    func asPrettyText() -> String {
        var output = asText() + ":\n"
        for index in 1...finalSquare {
            switch board[index] {
            case let ladder where ladder > 0 :
                output += "▲"
            case let snake where snake < 0:
                output += "▼"
            default:
                output += "◦"
            }
        }
        return output
    }
}
print(" asPrettyText() ")
print(game.asPrettyText())

/*******************************************************/

/*  */
// Protocol Composition
print("\n Protocol Composition")
protocol Named {
    var name: String {get}
}
protocol Aged {
    var age: Int {get}
}

struct Person1: Named, Aged {
    var name: String
    var age: Int
}

func wishHappyBirthday(_ celebrator: Named & Aged ) {
    print(" Happy birthday \(celebrator.name) - you're \(celebrator.age) ! " )
}

let birthdayPerson = Person1(name: "Malcolm", age: 21)
wishHappyBirthday(birthdayPerson)

/* */

/*  */
//Checking for Protocol Conformance
print(" \n Checking for Protocol Conformance")
protocol HasArea {
    var area: Double {get}
}

class Circle: HasArea {
    let pi = 3.1415927
    var radius: Double
    var  area: Double {
        return pi * radius * radius
    }
    init( radius: Double) {
        self.radius = radius
    }
}

class Country : HasArea {
    var area: Double
    init( area: Double) {
        self.area = area
    }
}

class Animal {
    var legs: Int
    init( legs: Int) {
        self.legs = legs
    }
}

let objects: [AnyObject] = [
    Circle(radius: 2.0), Country(area: 243_610), Animal(legs: 4) ]

for object in objects {
    if let objectWithArea = object as? HasArea {
        print(" Area is \(objectWithArea.area)")
    } else {
        print(" Something that doesn't have an area")
    }
}

/* */

/*********************************************/
print(" \n Optional Protocol Requirement ")

@objc protocol CounterDataSource {
    @objc optional func incrementForCount(_ count:Int) -> Int
    @objc optional var fixedIncrement: Int {get}
}

class Counter {
    var count = 0
    var dataSource: CounterDataSource?
    
    func increment () {
        if let amount = dataSource?.incrementForCount?(count) {
            count  += amount
        } else if let amount = dataSource?.fixedIncrement {
            count += amount
        }
    }
}

@objc class ThreeSource: NSObject, CounterDataSource {
    var fixedIncrement = 3
}


let treesource = ThreeSource()
var counter = Counter()
counter.count = 0
counter.dataSource = treesource

//print(" \(counter.dataSource?.fixedIncrement), \(treesource.fixedIncrement) " )

for _ in 1...4 {
    counter.increment()
    //    print(counter.dataSource?.fixedIncrement)
    print(counter.count)
}



@objc class TowardsZeroSource:NSObject, CounterDataSource {
    func incrementForCount(_ count:Int) -> Int {
        //        print(" In TowardsZeroSource count=\(count)")
        if count == 0 {
            return 0
        } else if count < 0 {
            return 1
        } else {
            return -1
        }
    }
}

print(" \n More complex data source ")
counter.count = -4

counter.dataSource = TowardsZeroSource()


for _ in 1...5 {
    counter.increment()
    //   print(counter.dataSource!.incrementForCount!(counter.count))
    print(counter.count)
}


/************************************************/
