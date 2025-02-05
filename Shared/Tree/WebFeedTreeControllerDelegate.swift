//
//  SidebarTreeControllerDelegate.swift
//  NetNewsWire
//
//  Created by Brent Simmons on 7/24/16.
//  Copyright © 2016 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import RSTree
import Articles
import Account

final class WebFeedTreeControllerDelegate: TreeControllerDelegate {

	func treeController(treeController: TreeController, childNodesFor node: Node) -> [Node]? {
		
		if node.isRoot {
			return childNodesForRootNode(node)
		}
		if node.representedObject is Container {
			return childNodesForContainerNode(node)
		}
		if node.representedObject is SmartFeedsController {
			return childNodesForSmartFeeds(node)
		}

		return nil
	}	
}

private extension WebFeedTreeControllerDelegate {
	
	func childNodesForRootNode(_ rootNode: Node) -> [Node]? {

		// The top-level nodes are Smart Feeds and accounts.

		let smartFeedsNode = rootNode.existingOrNewChildNode(with: SmartFeedsController.shared)
		smartFeedsNode.canHaveChildNodes = true
		smartFeedsNode.isGroupItem = true

		return [smartFeedsNode] + sortedAccountNodes(rootNode)
	}

	func childNodesForSmartFeeds(_ parentNode: Node) -> [Node] {

		return SmartFeedsController.shared.smartFeeds.map { parentNode.existingOrNewChildNode(with: $0) }
	}

	func childNodesForContainerNode(_ containerNode: Node) -> [Node]? {

		let container = containerNode.representedObject as! Container

		var children = [AnyObject]()
		children.append(contentsOf: Array(container.topLevelWebFeeds))
		if let folders = container.folders {
			children.append(contentsOf: Array(folders))
		}

		var updatedChildNodes = [Node]()

		children.forEach { (representedObject) in

			if let existingNode = containerNode.childNodeRepresentingObject(representedObject) {
				if !updatedChildNodes.contains(existingNode) {
					updatedChildNodes += [existingNode]
					return
				}
			}

			if let newNode = self.createNode(representedObject: representedObject, parent: containerNode) {
				updatedChildNodes += [newNode]
			}
		}

		return updatedChildNodes.sortedAlphabeticallyWithFoldersAtEnd()
	}

	func createNode(representedObject: Any, parent: Node) -> Node? {
		
		if let webFeed = representedObject as? WebFeed {
			return createNode(webFeed: webFeed, parent: parent)
		}
		if let folder = representedObject as? Folder {
			return createNode(folder: folder, parent: parent)
		}
		if let account = representedObject as? Account {
			return createNode(account: account, parent: parent)
		}

		return nil
	}
	
	func createNode(webFeed: WebFeed, parent: Node) -> Node {

		return parent.createChildNode(webFeed)
	}
	
	func createNode(folder: Folder, parent: Node) -> Node {

		let node = parent.createChildNode(folder)
		node.canHaveChildNodes = true
		return node
	}

	func createNode(account: Account, parent: Node) -> Node {

		let node = parent.createChildNode(account)
		node.canHaveChildNodes = true
		node.isGroupItem = true
		return node
	}

	func sortedAccountNodes(_ parent: Node) -> [Node] {

		let nodes = AccountManager.shared.sortedActiveAccounts.map { (account) -> Node in
			let accountNode = parent.existingOrNewChildNode(with: account)
			accountNode.canHaveChildNodes = true
			accountNode.isGroupItem = true
			return accountNode
		}
		return nodes
	}

	func nodeInArrayRepresentingObject(_ nodes: [Node], _ representedObject: AnyObject) -> Node? {
		
		for oneNode in nodes {
			if oneNode.representedObject === representedObject {
				return oneNode
			}
		}
		return nil
	}
}
