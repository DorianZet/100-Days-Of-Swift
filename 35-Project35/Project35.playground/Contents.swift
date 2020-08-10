import UIKit
import GameplayKit

// All the random methods that take an in parameter accept a range to work with. For example:
let int1 = Int.random(in: 0...10)
let int2 = Int.random(in: 0..<10)
let double1 = Double.random(in: 1000...10000)
let float1 = Float.random(in: -100...100)

Bool.random() // returns true or false randomly.

// To produce a truly random number you'd use the nextInt() method like this:
print(GKRandomSource.sharedRandom().nextInt())

// As an alternative, try using the nextInt(upperBound:) method, which works identically to arc4random():
print(GKRandomSource.sharedRandom().nextInt(upperBound: 6)) // that will return a random number from 0 to 5 using the system's built-in random number generator.

// Generating a random true/false value:
print(GKRandomSource.sharedRandom().nextBool())

// Generating a random floating-pount number between 0 and 1:
print(GKRandomSource.sharedRandom().nextUniform())





// GameplayKit has 3 sources of random numbers:
// GKLinearCongruetialRandomSource: has high performance but the lowest randomness
// GKMersenneTwisterRandomSource: has high randomness but the lowest performance
// GKARC4RandomSource: has good performance and good randomness - in the words of Apple, "it's going to be your Goldilocks random source".

// To generate a random number between 0 and 19 using an ARC4 random source that you can SAVE TO DISK, you'd use this:
let arc4 = GKARC4RandomSource()
arc4.nextInt(upperBound: 20)

// If you REALLY want the maximum possible randomness for your app or game, try the Mersenne Twister source instead:
let mersenne = GKMersenneTwisterRandomSource()
mersenne.nextInt(upperBound: 20)

// IMPORTANT: Apple recommends that you force flush its ARC4 random number generator before using it for anything important, otherwise it will generate sequences that can be guessed to begin with. Apple suggests dropping at least first 769 values, so let's round it up to the nearest pleasing value: 1024:
arc4.dropValues(1024)





// GameplayKit has built-in 6-sided dice in its API:
let d6 = GKRandomDistribution.d6() // create a 6-sided dice
d6.nextInt() // throw the dice
if d6.nextInt() == 1 {
    print("1)")
}

// 20 sided dice:
let d20 = GKRandomDistribution.d20() // create a 20-sided dice
d20.nextInt() // throw the dice

// 11,539 sided dice:
let crazyDice = GKRandomDistribution(lowestValue: 1, highestValue: 11539) // create a 11539-sided dice
crazyDice.nextInt() // throw the dice

// When we create a random distribution in the way described above, iOS automatically creates a random source for you using an unspecified algorithm. If we want one particular random source, there are special constructors for that:
let rand = GKMersenneTwisterRandomSource()
let distribution = GKRandomDistribution(randomSource: rand, lowestValue: 10, highestValue: 20)
print(distribution.nextInt())


// GKShuffledDistribution - an anti-clustering distribution, which means it shapes the distribution of random numbers so that you are less likely to get repeats. This means it will go through every possible number before you see a repeat, which makes a truly perfect distribution of numbers. For example, the code below generates the numbers 1 to 6 in a random order. To be clear, that code literally will generate the number 1 once, the number 2 once, etc., up to 6, but the order is random. This makes GKShuffleDistribution a so called "fair-distribution", because ever number will appear an equal number of times:
let shuffled = GKShuffledDistribution.d6()
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())

// GKGaussianDistribution - distribution which causes the random numbers to bias towards the mean average of the range. So if your range is from 0 to 20, you'll get more numbers like 10, 11 and 12, fewer numbers like 8,9, 13 and 14, and decreasing amounts of any numbers outside of that. In short - the closer the numbers is to the average of the number range (which in this case, is 10), the more chance we have to get it. It's perfect for when you want random things to happen, but you also want to steer that randomness so that has a degree of AVERAGENESS to it:
let gaussian = GKGaussianDistribution.d20()
print(gaussian.nextInt())
print(gaussian.nextInt())
print(gaussian.nextInt())
print(gaussian.nextInt())
print(gaussian.nextInt())
print(gaussian.nextInt())





// Many Swift game projects use this Fisher-Yates array shuffle alogrithm implemented in Swift by Nate Cook:
extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swapAt(i, j)
        }
    }
}

// With GameplayKit there is a specific method we can call that does a similar thing: arrayByShufflingObjects(in:). It returns a new array rather than modifying the original, whereas Nate's extension shuffles in place. If we wanted to set up a lottery, we could create an array containing the numbers 1 to 49, randomize its order, then pick the first six balls:
let lotteryBalls = [Int](1...49)
let shuffledBalls = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lotteryBalls)
print(shuffledBalls[0])
print(shuffledBalls[1])
print(shuffledBalls[2])
print(shuffledBalls[3])
print(shuffledBalls[4])
print(shuffledBalls[5])

// When you use a seed value, your random number generator becomes predictable - you can always predict exactly what "random" numbers get generated. But that's OK, because you can generate the seeds using a separate random number generator, so you're guaranteed uniqueness. Here's our lottery example rewritten using a fixed seed value of 1001:
let fixedLotteryBalls = [Int](1...49)
let fixedShuffledBalls = GKMersenneTwisterRandomSource(seed: 1001).arrayByShufflingObjects(in: fixedLotteryBalls)
print(fixedShuffledBalls[0])
print(fixedShuffledBalls[1])
print(fixedShuffledBalls[2])
print(fixedShuffledBalls[3])
print(fixedShuffledBalls[4])
print(fixedShuffledBalls[5])
// Once we run that code, we'll see that the balls are SHUFFLED IDENTICALLY EVERY TIME. It's a random order - but predictably random!





