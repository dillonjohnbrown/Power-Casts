//
//  FeedlyGetStreamIdsOperation.swift
//  Account
//
//  Created by Kiel Gillard on 18/10/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import os.log

protocol FeedlyEntryIdenifierProviding: class {
	var resource: FeedlyResourceId { get }
	var entryIds: Set<String> { get }
}

protocol FeedlyGetStreamIdsOperationDelegate: class {
	func feedlyGetStreamIdsOperation(_ operation: FeedlyGetStreamIdsOperation, didGet streamIds: FeedlyStreamIds)
}

/// Single responsibility is to get the stream ids from Feedly.
final class FeedlyGetStreamIdsOperation: FeedlyOperation, FeedlyEntryIdenifierProviding, FeedlyUnreadEntryIdProviding {
	
	var entryIds: Set<String> {
		guard let ids = streamIds?.ids else {
			assert(isFinished, "This should only be called when the operation finishes without error.")
			assertionFailure("Has this operation been addeded as a dependency on the caller?")
			return []
		}
		return Set(ids)
	}
	
	private(set) var streamIds: FeedlyStreamIds?
	
	let account: Account
	let service: FeedlyGetStreamIdsService
	let continuation: String?
	let resource: FeedlyResourceId
	let unreadOnly: Bool?
	let newerThan: Date?
		
	init(account: Account, resource: FeedlyResourceId, service: FeedlyGetStreamIdsService, continuation: String? = nil, newerThan: Date? = nil, unreadOnly: Bool?) {
		self.account = account
		self.resource = resource
		self.service = service
		self.continuation = continuation
		self.newerThan = newerThan
		self.unreadOnly = unreadOnly
	}
	
	weak var streamIdsDelegate: FeedlyGetStreamIdsOperationDelegate?
	
	override func main() {
		guard !isCancelled else {
			didFinish()
			return
		}
		
		service.getStreamIds(for: resource, continuation: continuation, newerThan: newerThan, unreadOnly: unreadOnly) { result in
			switch result {
			case .success(let stream):
				self.streamIds = stream
				
				self.streamIdsDelegate?.feedlyGetStreamIdsOperation(self, didGet: stream)
				
				self.didFinish()
				
			case .failure(let error):
				self.didFinish(error)
			}
		}
	}
}
