import Foundation
import CloudKit

struct TriviaQuestion: Identifiable {
    let id: UUID
    let question: String
    let answer: String
    let options: [String]
    
    init(record: CKRecord) {
        // Generate UUID from record ID or create a new one
        if let uuidString = record["id"] as? String,
           let uuid = UUID(uuidString: uuidString) {
            self.id = uuid
        } else {
            self.id = UUID()
        }
        
        self.question = record["question"] as? String ?? ""
        self.answer = record["answer"] as? String ?? ""
        self.options = record["options"] as? [String] ?? []
    }
    
    init(id: UUID = UUID(), question: String, answer: String, options: [String]) {
        self.id = id
        self.question = question
        self.answer = answer
        self.options = options
    }
    
    static let sampleQuestions = [
        TriviaQuestion(
            id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "If 3x + 7 = 22, what is the value of x?",
            answer: "5",
            options: ["3", "5", "7", "8"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the area of a circle with radius 4?",
            answer: "16π",
            options: ["8π", "12π", "16π", "20π"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Find the value of x: 2x² - 8x + 6 = 0",
            answer: "3",
            options: ["1", "2", "3", "4"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the derivative of y = x³?",
            answer: "3x²",
            options: ["x²", "2x", "3x²", "3x"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Choose the word that best completes the sentence: The concert was _____ by over a thousand people.",
            answer: "attended",
            options: ["attend", "attends", "attending", "attended"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "D621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the measure of an exterior angle of a regular pentagon?",
            answer: "72°",
            options: ["60°", "72°", "108°", "120°"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "1621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence contains a split infinitive?",
            answer: "She decided to quickly run to the store.",
            options: [
                "She quickly ran to the store.",
                "She decided to quickly run to the store.",
                "She ran to the store quickly.",
                "Quickly, she ran to the store."
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "2621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the value of cos(60°)?",
            answer: "0.5",
            options: ["0", "0.5", "0.866", "1"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "3621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "If f(x) = 2x + 3 and g(x) = x² - 1, what is f(g(2))?",
            answer: "5",
            options: ["3", "5", "7", "9"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "4621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence demonstrates correct subject-verb agreement?",
            answer: "The team of players practices daily.",
            options: [
                "The team of players practice daily.",
                "The team of players practices daily.",
                "The team of players are practicing daily.",
                "The team of players were practicing daily."
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "5621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the sum of the first 10 positive integers?",
            answer: "55",
            options: ["45", "50", "55", "60"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "6621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which word is a synonym for 'ephemeral'?",
            answer: "transient",
            options: ["permanent", "transient", "eternal", "enduring"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "7621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Solve for x: |x - 3| = 7",
            answer: "10 or -4",
            options: ["4 or -4", "10 or -4", "3 or -3", "7 or -7"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "8621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence contains an appositive?",
            answer: "My brother, an excellent chef, cooked dinner.",
            options: [
                "My brother cooked dinner quickly.",
                "My brother, an excellent chef, cooked dinner.",
                "My brother cooked dinner for us.",
                "The dinner my brother cooked was excellent."
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "9621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the probability of rolling a sum of 7 with two dice?",
            answer: "1/6",
            options: ["1/6", "1/8", "1/12", "1/36"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "AA21E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which is the correct spelling?",
            answer: "accommodate",
            options: ["accomodate", "accommodate", "acommodate", "acomodate"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "BB21E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the square root of 169?",
            answer: "13",
            options: ["11", "12", "13", "14"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "CC21E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which literary term describes a comparison using 'like' or 'as'?",
            answer: "simile",
            options: ["metaphor", "simile", "personification", "alliteration"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "DD21E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "If 5x + 3y = 15 and 2x - y = 4, what is x?",
            answer: "2",
            options: ["1", "2", "3", "4"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "EE21E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the volume of a cube with side length 3?",
            answer: "27",
            options: ["9", "18", "27", "36"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "FF21E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence contains a misplaced modifier?",
            answer: "Barking loudly, the girl walked the dog.",
            options: [
                "The dog barked loudly while walking.",
                "Barking loudly, the girl walked the dog.",
                "The girl walked the barking dog.",
                "The dog was barking loudly during the walk."
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "AA11E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the slope of a line perpendicular to y = 2x + 1?",
            answer: "-1/2",
            options: ["2", "-2", "1/2", "-1/2"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "BB11E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which word is an example of onomatopoeia?",
            answer: "buzz",
            options: ["soft", "buzz", "quick", "slow"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "CC11E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the value of 3⁴?",
            answer: "81",
            options: ["27", "64", "81", "243"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "DD11E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence is in the passive voice?",
            answer: "The book was written by the author.",
            options: [
                "The author wrote the book.",
                "The book was written by the author.",
                "The author is writing the book.",
                "The author writes books."
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "EE11E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the mean of the numbers 2, 4, 6, 8, 10?",
            answer: "6",
            options: ["5", "6", "7", "8"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "FF11E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which punctuation mark is used to separate items in a series?",
            answer: "comma",
            options: ["period", "comma", "semicolon", "colon"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "AA22E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the square root of -16?",
            answer: "4i",
            options: ["4i", "-4", "4", "undefined"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "BB22E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which of these is a coordinating conjunction?",
            answer: "but",
            options: ["however", "although", "unless", "but"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "CC22E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the area of a triangle with base 6 and height 8?",
            answer: "24",
            options: ["24", "48", "12", "36"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "DD22E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which word is an antonym for 'benevolent'?",
            answer: "malicious",
            options: ["kind", "generous", "malicious", "charitable"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "EE22E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the value of π rounded to two decimal places?",
            answer: "3.14",
            options: ["3.14", "3.15", "3.16", "3.13"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "FF22E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence contains a compound subject?",
            answer: "John and Mary went to the store.",
            options: [
                "John went to the store.",
                "John and Mary went to the store.",
                "John went to the store and bought milk.",
                "Mary likes going to the store."
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "AA33E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the mode of the numbers 2, 3, 3, 4, 4, 4, 5?",
            answer: "4",
            options: ["2", "3", "4", "5"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "BB33E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which word contains a diphthong?",
            answer: "cloud",
            options: ["cat", "cloud", "bit", "set"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "CC33E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the perimeter of a square with area 16?",
            answer: "16",
            options: ["8", "12", "16", "20"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "DD33E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence is in the subjunctive mood?",
            answer: "If I were rich, I would travel the world.",
            options: [
                "I am rich.",
                "I will be rich.",
                "If I were rich, I would travel the world.",
                "I might be rich someday."
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "EE33E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the solution to 2ˣ = 8?",
            answer: "3",
            options: ["2", "3", "4", "6"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "FF33E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which rhetorical device repeats consonant sounds at the beginning of words?",
            answer: "alliteration",
            options: ["assonance", "alliteration", "consonance", "onomatopoeia"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "AA44E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the value of 5! (5 factorial)?",
            answer: "120",
            options: ["60", "120", "180", "240"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "BB44E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which word is a participle?",
            answer: "running",
            options: ["run", "runs", "running", "ran"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "CC44E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the circumference of a circle with diameter 10?",
            answer: "10π",
            options: ["5π", "10π", "20π", "25π"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "DD44E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence demonstrates parallel structure?",
            answer: "She likes hiking, swimming, and camping.",
            options: [
                "She likes hiking, to swim, and camps.",
                "She likes hiking, swimming, and camping.",
                "She likes to hike, swims, and camping.",
                "She likes to hike, swimming, and to camp."
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "EE44E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the sum of the angles in a pentagon?",
            answer: "540°",
            options: ["360°", "450°", "540°", "720°"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "FF44E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which is the correct order of operations?",
            answer: "Parentheses, Exponents, Multiplication/Division, Addition/Subtraction",
            options: [
                "Addition, Subtraction, Multiplication, Division",
                "Parentheses, Exponents, Multiplication/Division, Addition/Subtraction",
                "Exponents, Parentheses, Addition/Subtraction, Multiplication/Division",
                "Multiplication/Division, Addition/Subtraction, Parentheses, Exponents"
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "AA55E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the median of the numbers 1, 3, 3, 6, 7, 8, 9?",
            answer: "6",
            options: ["3", "5", "6", "7"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "BB55E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence contains a dependent clause?",
            answer: "Although it was raining, we went for a walk.",
            options: [
                "We went for a walk.",
                "Although it was raining, we went for a walk.",
                "The rain was heavy.",
                "We enjoyed our walk."
            ]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "CC55E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the value of log₁₀(100)?",
            answer: "2",
            options: ["1", "2", "10", "100"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "DD55E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which figure of speech is used in 'The stars danced in the sky'?",
            answer: "personification",
            options: ["simile", "metaphor", "personification", "hyperbole"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "EE55E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the simplified form of (x² + 2x + 1)/(x + 1)?",
            answer: "x + 1",
            options: ["x", "x + 1", "x - 1", "x + 2"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "FF55E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which word is an example of an oxymoron?",
            answer: "deafening silence",
            options: ["loud noise", "deafening silence", "bright light", "dark night"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "AA66E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the sum of the interior angles of a hexagon?",
            answer: "720°",
            options: ["540°", "630°", "720°", "810°"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "BB66E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "Which sentence uses the correct form of 'lie' or 'lay'?",
            answer: "I will lie down for a nap.",
            options: [
                "I will lay down for a nap.",
                "I will lie down for a nap.",
                "I laid myself down.",
                "The book is laying on the table."
            ]
        )
    ]
}
