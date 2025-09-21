import Foundation

// MARK: - Decision Tree Logic
var learningData: [LearningDataEntry] = []

/// Validates the decision tree structure
func validateDecisionTree(_ tree: [String: DecisionNode], logger: Logger) -> Bool {
    var isValid = true
    var visited: Set<String> = []
    var stack: [String] = []

    func checkNode(_ nodeId: String, path: [String]) -> Bool {
        if visited.contains(nodeId) {
            logger.log("Circular reference detected at node '\(nodeId)' in path: \(path.joined(separator: " -> "))", level: "ERROR")
            return false
        }
        guard let node = tree[nodeId] else {
            logger.log("Missing node: '\(nodeId)'", level: "ERROR")
            return false
        }
        guard ["question", "response", "terminus"].contains(node.type) else {
            logger.log("Invalid node type '\(node.type)' for node '\(nodeId)'", level: "ERROR")
            return false
        }
        if node.type != "terminus" {
            guard let children = node.children else {
                logger.log("Non-terminus node '\(nodeId)' has no children", level: "ERROR")
                return false
            }
            guard let defaultChild = node.default, children[defaultChild] != nil else {
                logger.log("Invalid or missing default child for node '\(nodeId)'", level: "ERROR")
                return false
            }
            visited.insert(nodeId)
            stack.append(nodeId)
            for childId in children.values {
                if !checkNode(childId, path: path + [nodeId]) {
                    return false
                }
            }
            stack.removeLast()
            visited.remove(nodeId)
        }
        return true
    }

    if tree["root"] == nil {
        logger.log("No root node defined", level: "ERROR")
        isValid = false
    }

    for nodeId in tree.keys {
        if !checkNode(nodeId, path: []) {
            isValid = false
        }
    }

    logger.log("Decision tree validation: \(isValid ? "Passed" : "Failed")")
    return isValid
}

/// Classifies a response using advanced heuristic-based analysis
func classifyResponse(_ text: String, logger: Logger) -> String {
    let lowercased = text.lowercased()
    let positiveWords = ["great", "love", "awesome", "fun", "amazing", "happy", "excited", "cool", "fantastic"]
    let negativeWords = ["no", "nah", "boring", "whatever", "not really", "bad", "sorry", "hate"]
    let emotionalWords = ["heart", "feel", "memory", "special", "deep", "personal"]
    let engagementWords = ["you", "we", "us", "?", "tell", "share"]

    var score = 0.0
    let wordCount = text.split(separator: " ").count

    // Sentiment scoring
    for word in positiveWords where lowercased.contains(word) { score += 1.0 }
    for word in negativeWords where lowercased.contains(word) { score -= 1.0 }
    for word in emotionalWords where lowercased.contains(word) { score += 0.5 }
    for word in engagementWords where lowercased.contains(word) { score += 0.3 }

    // Length-based adjustment
    if wordCount > 20 { score += 0.5 }
    else if wordCount < 5 { score -= 0.5 }

    // Punctuation and tone
    if text.contains("!") { score += 0.2 }
    if text.contains("...") || text.contains(":(") { score -= 0.2 }

    let classification: String
    if score > 0.8 {
        classification = "positive"
    } else if score >= -0.5 {
        classification = "neutral"
    } else {
        classification = "negative"
    }

    logger.log("Response: '\(text)' -> Score: \(score), Classified as: \(classification)")
    return classification
}

/// Extracts attributes from a response
func extractAttributes(from text: String) -> [String: Any] {
    let sentimentScore = classifyResponse(text, logger: Logger()) == "positive" ? 1.0 : (classifyResponse(text, logger: Logger()) == "neutral" ? 0.0 : -1.0)
    let length = text.count
    let containsQuestion = text.contains("?")
    let wordCount = text.split(separator: " ").count
    return [
        "sentiment": sentimentScore,
        "length": length,
        "hasQuestion": containsQuestion,
        "wordCount": wordCount
    ]
}

/// Simulates decision tree training (placeholder for ML)
func trainDecisionTree(logger: Logger) -> [String: Any]? {
    guard learningData.count >= 5 else {
        logger.log("Insufficient data for training (\(learningData.count) entries)", level: "WARNING")
        return nil
    }
    logger.log("Training model with \(learningData.count) examples...")
    // Placeholder: Replace with a lightweight ML library (e.g., swift-algorithms or external service)
    return ["mockModel": true]
}

/// Traverses the decision tree with a response provider
func traverseTree(startingAt nodeId: String, tree: [String: DecisionNode], responseProvider: (String) -> String?, logger: Logger) {
    guard validateDecisionTree(tree, logger: logger) else {
        logger.log("Cannot traverse invalid tree", level: "ERROR")
        return
    }

    var currentNodeId = nodeId
    while let node = tree[currentNodeId] {
        if let content = node.content {
            logger.log("Send/Say: \(content)")
        }
        if let test = node.test {
            logger.log("Evaluation Guide: \(test)")
        }
        if node.type == "terminus" {
            logger.log("End of questionnaire.")
            logger.log("Was the overall outcome successful? (yes/no): ")
            let outcomeInput = responseProvider("Outcome?")?.lowercased()
            if let outcome = outcomeInput, let lastIndex = learningData.indices.last {
                learningData[lastIndex].outcome = outcome == "yes" ? "success" : "failure"
            }
            break
        }

        let responseText = responseProvider(currentNodeId)
        guard let responseText = responseText, !responseText.isEmpty else {
            logger.log("No response received, moving to terminus_exit")
            currentNodeId = "terminus_exit"
            continue
        }

        let classification = classifyResponse(responseText, logger: logger)
        let attributes = extractAttributes(from: responseText)
        let nextAction = node.children?[classification] ?? node.default ?? "neutral"
        learningData.append(LearningDataEntry(
            responseText: responseText,
            attributes: attributes,
            action: nextAction,
            outcome: ""
        ))

        if let _ = trainDecisionTree(logger: logger) {
            logger.log("Learned suggestion: Using default action for now.")
        }

        if let children = node.children {
            currentNodeId = children[classification] ?? children[node.default ?? "neutral"] ?? "terminus_exit"
        } else {
            logger.log("No children for node '\(currentNodeId)', exiting", level: "ERROR")
            break
        }
    }
    logger.log("Collected learning data: \(learningData)")
}

// MARK: - Main Execution
func main() {
    let logger = Logger()
    do {
        let tree = try loadDecisionTree(from: "Resources/decision_tree.json")
        
        // Mock response provider for testing
        let mockResponses: [String: String] = [
            "root": "Building a treehouse with my dad was so much fun!",
            "node_2A": "I’d add a zip line to make it epic!",
            "node_3A": "Family moments always hit me hard.",
            "node_4A": "Let’s plan a picnic to relive it!",
            "Outcome?": "yes"
        ]
        
        let responseProvider: (String) -> String? = { nodeId in
            mockResponses[nodeId]
        }
        
        traverseTree(startingAt: "root", tree: tree, responseProvider: responseProvider, logger: logger)
        logger.close()
    } catch {
        logger.log("Failed to load decision tree: \(error)", level: "ERROR")
        logger.close()
    }
}

main()
