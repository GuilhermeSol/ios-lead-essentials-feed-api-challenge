//
//  FeedImageItemMapper.swift
//  FeedAPIChallenge
//
//  Created by Guilherme Sol on 11/09/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal class FeedImageItemMapper {
	
	private struct Root: Decodable {
		var items: [FeedImageItem]
		var feedItems: [FeedImage] {
			items.compactMap({ $0.feedImage })
		}
	}

	private struct FeedImageItem: Decodable {
		var image_id: String
		var image_desc: String?
		var image_loc: String?
		var image_url: URL

		var feedImage: FeedImage {
			FeedImage(id: UUID(uuidString: image_id)!,
			          description: image_desc,
			          location: image_loc,
			          url: image_url)
		}
	}

	internal static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200,
		      let items = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(items.feedItems)
	}
	
}
