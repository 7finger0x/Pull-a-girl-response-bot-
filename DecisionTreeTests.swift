import Foundation

// MARK: - Unit Tests
func testValidateDecisionTree() {
    let logger = Logger()
    do {
        let validTree = try loadDecisionTree(from: "Resources/decision_tree.json")
        assert(validateDecisionTree(validTree, logger: logger), "Valid tree should pass validation")

        // Test invalid tree (missing node)
        var invalidTree = validTree
        invalidTree["node_2A"]?.children?["positive"] = "missing_node"
        assert(!validateDecisionTree(invalidTree, logger: logger), "Tree with missing node should fail validation")

        // Test circular reference
        var circularTree = validTree
        circularTree["node_2A"]?.children?["positive"] = "root"
        assert(!validateDecisionTree(circularTree, logger: logger), "Tree with circular reference should fail validation")

        // Test missing root
        var noRootTree = validTree
        noRootTree.removeValue(forKey: "root")
        assert(!validateDecisionTree(noRootTree, logger: logger), "Tree without root should fail validation")
    } catch {
        assert(false, "Failed to load decision tree: \(error)")
    }
    logger.close()
}

func testClassifyResponse() {
    let logger = Logger()
    let positiveResponse = "That was an amazing day with my friends! I loved it!"
    let neutralResponse = "It was okay, I guess."
    let negativeResponse = "Nah, nothing special, whatever."

    assert(classifyResponse(positiveResponse, logger: logger) == "positive", "Expected positive classification")
    assert(classifyResponse(neutralResponse, logger: logger) == "neutral", "Expected neutral classification")
    assert(classifyResponse(negativeResponse, logger: logger) == "negative", "Expected negative classification")
    assert(classifyResponse("Short!", logger: logger) == "negative", "Short response should be negative")
    assert(classifyResponse("Tell me about you! What's your story?", logger: logger) == "positive", "Engaging response should be positive")
    logger.close()
}

func testExtractAttributes() {
    let response = "I loved that day! Did you have fun?"
    let attributes = extractAttributes(from: response)

    assert((attributes["sentiment"] as? Double) == 1.0, "Expected positive sentiment")
    assert((attributes["length"] as? Int) == response.count, "Expected correct length")
    assert((attributes["hasQuestion"] as? Bool) == true, "Expected hasQuestion to be true")
    assert((attributes["wordCount"] as? Int) == response.split(separator: " ").count, "Expected correct word count")
}

func testTraverseTree() {
    let logger = Logger()
    do {
        let tree = try loadDecisionTree(from: "Resources/decision_tree.json")
        let mockResponses: [String: String] = [
            "root": "Building a treehouse was awesome!",
            "node_2A": "I’d add a zip line!",
            "node_3A": "Family moments get me.",
            "node_4A": "Let’s have a picnic!",
            "Outcome?": "yes"
        ]
        let responseProvider: (String) -> String? = { mockResponses[$0] }
        learningData.removeAll()
        traverseTree(startingAt: "root", tree: tree, responseProvider: responseProvider, logger: logger)
        assert(learningData.count == 4, "Expected 4 learning data entries")
        assert(learningData.last?.outcome == "success", "Expected successful outcome")
    } catch {
        assert(false, "Failed to load decision tree: \(error)")
    }
    logger.close()
}

func runTests() {
    print("Running tests...")
    testValidateDecisionTree()
    testClassifyResponse()
    testExtractAttributes()
    testTraverseTree()
    print("All tests passed!")
}

runTests()
