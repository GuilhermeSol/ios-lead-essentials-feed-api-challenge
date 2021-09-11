//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

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

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			if let feedResult = self?.map(result: result){
				completion(feedResult)
			}
		}
	}

	private func map(result: Result<(Data, HTTPURLResponse), Swift.Error>) -> FeedLoader.Result {
		switch result {
		case let .success((data, response)):
			guard response.statusCode == 200,
			      let items = try? JSONDecoder().decode(Root.self, from: data) else {
				return .failure(Error.invalidData)
			}
			return .success(items.feedItems)
		case .failure:
			return .failure(Error.connectivity)
		}
	}
	
}
