//
//  ArticleUtilities.swift
//  NetNewsWire
//
//  Created by Brent Simmons on 7/25/15.
//  Copyright © 2015 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import RSCore
import Articles
import Account

// These handle multiple accounts.

@discardableResult
func markArticles(_ articles: Set<Article>, statusKey: ArticleStatus.Key, flag: Bool) -> Set<Article>? {
	
	let d: [String: Set<Article>] = accountAndArticlesDictionary(articles)
	var updatedArticles = Set<Article>()

	for (accountID, accountArticles) in d {
		
		guard let account = AccountManager.shared.existingAccount(with: accountID) else {
			continue
		}

		if let accountUpdatedArticles = account.markArticles(accountArticles, statusKey: statusKey, flag: flag) {
			updatedArticles.formUnion(accountUpdatedArticles)
		}

	}
	
	return updatedArticles
}

private func accountAndArticlesDictionary(_ articles: Set<Article>) -> [String: Set<Article>] {
	
	let d = Dictionary(grouping: articles, by: { $0.accountID })
	return d.mapValues{ Set($0) }
}

extension Article {
	
	var webFeed: WebFeed? {
		return account?.existingWebFeed(withWebFeedID: webFeedID)
	}
	
	var preferredLink: String? {
		if let url = url, !url.isEmpty {
			return url
		}
		if let externalURL = externalURL, !externalURL.isEmpty {
			return externalURL
		}
		return nil
	}
	
	var body: String? {
		return contentHTML ?? contentText ?? summary
	}
	
	var logicalDatePublished: Date {
		return datePublished ?? dateModified ?? status.dateArrived
	}

	func iconImage() -> IconImage? {
		if let authors = authors, authors.count == 1, let author = authors.first {
			if let image = appDelegate.authorAvatarDownloader.image(for: author) {
				return image
			}
		}
		
		if let authors = webFeed?.authors, authors.count == 1, let author = authors.first {
			if let image = appDelegate.authorAvatarDownloader.image(for: author) {
				return image
			}
		}

		guard let webFeed = webFeed else {
			return nil
		}
		
		let feedIconImage = appDelegate.webFeedIconDownloader.icon(for: webFeed)
		if feedIconImage != nil {
			return feedIconImage
		}
		
		if let faviconImage = appDelegate.faviconDownloader.faviconAsIcon(for: webFeed) {
			return faviconImage
		}
		
		return FaviconGenerator.favicon(webFeed)
	}
}

// MARK: Path

struct ArticlePathKey {
	static let accountID = "accountID"
	static let accountName = "accountName"
	static let webFeedID = "webFeedID"
	static let articleID = "articleID"
}

extension Article {

	public var pathUserInfo: [AnyHashable : Any] {
		return [
			ArticlePathKey.accountID: accountID,
			ArticlePathKey.accountName: account?.nameForDisplay ?? "",
			ArticlePathKey.webFeedID: webFeedID,
			ArticlePathKey.articleID: articleID
		]
	}

}

// MARK: SortableArticle

extension Article: SortableArticle {
	
	var sortableName: String {
		return webFeed?.name ?? ""
	}
	
	var sortableDate: Date {
		return logicalDatePublished
	}
	
	var sortableArticleID: String {
		return articleID
	}
	
	var sortableWebFeedID: String {
		return webFeedID
	}
	
}
