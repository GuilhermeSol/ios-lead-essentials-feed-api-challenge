//
//  FeedImageItemMapper.swift
//  FeedAPIChallenge
//
//  Created by Guilherme Sol on 11/09/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageItemMapper {
	
	private static var OK_200:Int{ 200 }
	
	private struct Root: Decodable {
		let items: [FeedImageItem]
		var feedItems: [FeedImage] {
			items.map({ $0.feedImage })
		}
	}

	private struct FeedImageItem: Decodable {
		let image_id: String
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var feedImage: FeedImage {
			FeedImage(id: UUID(uuidString: image_id)!,
			          description: image_desc,
			          location: image_loc,
			          url: image_url)
		}
	}
	
	private init(){}
	
	static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200,
		      let items = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(items.feedItems)
	}
	
}
