//
//  Feed.swift
//  Account
//
//  Created by Maurice Parker on 11/15/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import RSCore

public protocol Feed: FeedIdentifiable, ArticleFetcher, DisplayNameProvider, UnreadCountProvider {

}
