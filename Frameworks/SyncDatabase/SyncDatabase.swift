//
//  SyncDatabase.swift
//  NetNewsWire
//
//  Created by Maurice Parker on 5/14/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import Foundation
import RSDatabase

public final class SyncDatabase {
	
	private let syncStatusTable: SyncStatusTable
	
	public init(databaseFilePath: String) {
		
		let queue = RSDatabaseQueue(filepath: databaseFilePath, excludeFromBackup: false)
		self.syncStatusTable = SyncStatusTable(queue: queue)
		
		queue.createTables(usingStatementsSync: SyncDatabase.tableCreationStatements)
		queue.vacuumIfNeeded()

	}
	
	public func insertStatuses(_ statuses: [SyncStatus], completionHandler: (() -> ())? = nil) {
		syncStatusTable.insertStatuses(statuses, completionHandler: completionHandler)
	}
	
	public func selectForProcessing() -> [SyncStatus] {
		return syncStatusTable.selectForProcessing()
	}
	
	public func selectPendingCount() -> Int {
		return syncStatusTable.selectPendingCount()
	}
	
	public func resetSelectedForProcessing(_ articleIDs: [String], completionHandler: (() -> ())? = nil) {
		syncStatusTable.resetSelectedForProcessing(articleIDs, completionHandler: completionHandler)
	}
	
    public func deleteSelectedForProcessing(_ articleIDs: [String], completionHandler: (() -> ())? = nil) {
		syncStatusTable.deleteSelectedForProcessing(articleIDs, completionHandler: completionHandler)
	}
	
}

// MARK: - Private

private extension SyncDatabase {
	
	static let tableCreationStatements = """
	CREATE TABLE if not EXISTS syncStatus (articleID TEXT NOT NULL, key TEXT NOT NULL, flag BOOL NOT NULL DEFAULT 0, selected BOOL NOT NULL DEFAULT 0, PRIMARY KEY (articleID, key));
	"""
}
