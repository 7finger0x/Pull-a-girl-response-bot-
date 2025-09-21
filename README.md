# Conversation Decision Tree

A Swift-based decision tree for guiding engaging conversations, with advanced response analysis, logging, and external tree definition.

## Overview

This project implements a decision tree to navigate conversation flows based on user responses. It includes sentiment analysis, validation, logging, and unit tests, with the tree defined in an external JSON file for easy updates.

## Features

- **Decision Tree**: Loaded from `Resources/decision_tree.json` for modularity.
- **Validation**: Checks for missing nodes, circular references, and invalid structures.
- **Advanced Response Analysis**: Heuristic-based sentiment classification (positive/neutral/negative).
- **Logging**: Logs traversal, classifications, and errors to console and `conversation.log`.
- **Unit Tests**: Comprehensive tests for validation, classification, attributes, and traversal.
- **Cross-Platform**: Pure Swift, compatible with macOS/Linux (no iOS-specific dependencies).

## Setup

1. **Requirements**:
   - Swift 5.9 or later
   - macOS or Linux environment

2. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/decision-tree-conversation.git
   cd decision-tree-conversation
