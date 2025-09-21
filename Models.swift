import Foundation

// MARK: - Data Structures
struct DecisionNode: Codable {
    let type: String
    let content: String
    let test: String?
    let children: [String: String]?
    let `default`: String?
}

struct LearningDataEntry: Codable {
    let responseText: String
    let attributes: [String: Any]
    let action: String
    var outcome: String

    enum CodingKeys: String, CodingKey {
        case responseText, action, outcome, attributes
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(responseText, forKey: .responseText)
        try container.encode(action, forKey: .action)
        try container.encode(outcome, forKey: .outcome)
        let attributesDict = attributes.mapValues { value in
            if let number = value as? NSNumber {
                return number
            } else if let double = value as? Double {
                return NSNumber(value: double)
            } else if let bool = value as? Bool {
                return NSNumber(value: bool)
            }
            return value
        }
        try container.encode(attributesDict, forKey: .attributes)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        responseText = try container.decode(String.self, forKey: .responseText)
        action = try container.decode(String.self, forKey: .action)
        outcome = try container.decode(String.self, forKey: .outcome)
        let decodedAttributes = try container.decode([String: Any].self, forKey: .attributes)
        attributes = decodedAttributes
    }

    init(responseText: String, attributes: [String: Any], action: String, outcome: String) {
        self.responseText = responseText
        self.attributes = attributes
        self.action = action
        self.outcome = outcome
    }
}

// MARK: - JSON Loading
func loadDecisionTree(from filePath: String) throws -> [String: DecisionNode] {
    let url = URL(fileURLWithPath: filePath)
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode([String: DecisionNode].self, from: data)
}
