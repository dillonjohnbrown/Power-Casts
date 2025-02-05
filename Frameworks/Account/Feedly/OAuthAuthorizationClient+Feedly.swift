//
//  OAuthAuthorizationClient+NetNewsWire.swift
//  Account
//
//  Created by Kiel Gillard on 8/11/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import Foundation

extension OAuthAuthorizationClient {
	
	static var feedlyCloudClient: OAuthAuthorizationClient {
		/// Models private NetNewsWire client secrets.
		/// These placeholders are substitued at build time using a Run Script phase with build settings.
		/// https://developer.feedly.com/v3/auth/#authenticating-a-user-and-obtaining-an-auth-code
		return OAuthAuthorizationClient(id: "{FEEDLY_CLIENT_ID}",
										redirectUri: "netnewswire://auth/feedly",
										state: nil,
										secret: "{FEEDLY_CLIENT_SECRET}")
	}
	
	static var feedlySandboxClient: OAuthAuthorizationClient {
		/// We use this funky redirect URI because ASWebAuthenticationSession will try to load http://localhost URLs.
		/// See https://developer.feedly.com/v3/sandbox/ for more information.
		/// The return value models public sandbox API values found at:
		/// https://groups.google.com/forum/#!topic/feedly-cloud/WwQWMgDmOuw
		/// They are due to expire on November 30 2019.
		return OAuthAuthorizationClient(id: "sandbox",
										redirectUri: "urn:ietf:wg:oauth:2.0:oob",
										state: nil,
										secret: "ReVGXA6WekanCxbf")
	}
}
