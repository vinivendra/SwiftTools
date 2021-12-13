
import Foundation

// MARK: - String
public extension String {
	/// Split the String using the given separators. Returns String objects.
	func split(_ separator: Character) -> [String] {
		return split(separator: separator).map { String($0) }
	}

	/// Removes all spaces from the string.
	func removingWhitespace() -> String {
		return self.replacingOccurrences(of: " ", with: "")
	}
}

public extension String {
	subscript(int: Int) -> Character {
		let index = self.index(self.startIndex, offsetBy: int)
		return self[index]
	}
}

// MARK: - Date
public extension String {
	/// Interprets a String as a date using the given format.
	func toDate(_ format: String) -> Date {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		let date = formatter.date(from: self)
		if date == nil {
			print("Unable to parse date \"\(self)\" using format \"\(format)\"")
		}
		return date!
	}
}

public extension Date {
	/// Helps finding the difference in time between two dates.
	static func -(left: Date, right: Date) -> TimeInterval {
		return left.timeIntervalSinceReferenceDate - right.timeIntervalSinceReferenceDate
	}
}

public extension TimeInterval {
	/// How many minutes are in this TimeInterval.
	func roundToMinutes() -> Int {
		return Int(self) / 60
	}

	/// How many Hours are in this TimeInterval.
	func roundToHours() -> Int {
		return self.roundToMinutes() / 60
	}

	/// This TimeInterval formatted as an hours String (e.g. `"10:05"`).
	func toHours() -> String {
		let hours = self.roundToHours()
		let minutes = self.roundToMinutes() - hours * 60
		return "\(hours):\(padTime(minutes))"
	}
}

// MARK: - Iterations
/// Helper type for enumerating a collection with a flag indicating whether an element is a start element, a middle element, or an end element.
public enum IterationLimit {
	case start
	case middle
	case end
}

public extension Collection {
	/// Enumerates a collection with a flag indicating whether an element is a start element, a middle element, or an end element.
	func enumeratedWithLimits() -> Zip2Sequence<Self, [IterationLimit]> {
		if self.count == 1 {
			return zip(self, [.end])
		}
		else if self.count == 2 {
			return zip(self, [.start, .end])
		}
		else {
			var limits: [IterationLimit] = [.start]
			for _ in 0..<(self.count - 2) {
				limits.append(.middle)
			}
			limits.append(.end)
			return zip(self, limits)
		}
	}
}

// MARK: - Statistics
public extension Collection where Element: Numeric {
	func sum() -> Element {
		return reduce(0, +)
	}
}

public extension Array where Element: FloatingPoint {
	func average() -> Element {
		return self.sum() / Element(exactly: self.count)!
	}
}

public extension Array where Element == Int {
	func average() -> Element {
		return self.sum() / self.count
	}
}

// MARK: - Errors
infix operator !!: NilCoalescingPrecedence
public extension Optional {
	static func !! (left: Wrapped?, right: String) -> Wrapped {
		guard let left = left else {
			fatalError(right)
		}
		return left
	}
}

// MARK: - Network
public extension URLRequest {
	// MARK: Strings

	/// Runs a GET request for the given URL (synchronously) and returns the result, decoded as a String.
	static func getAsString(_ urlString: String) -> String? {
		let url = URL(string: urlString)!
		return URLRequest.getAsString(url)
	}

	/// Runs a GET request for the given URL (synchronously) and returns the result, decoded as a String.
	static func getAsString(_ url: URL) -> String? {
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		return request.getAsString()
	}

	/// Runs the URLRequest (synchronously) and returns the result, decoded as a String.
	func getAsString() -> String? {
		var done = false

		var result: String?
		URLSession.shared.dataTask(with: self) { (data, response, error) in
			guard error == nil else { print(error!.localizedDescription); return }
			guard let data = data else { print("Empty data"); return }

			if let stringResponse = String(data: data, encoding: .utf8) {
				result = stringResponse
			}

			done = true
		}.resume()

		while !done { }

		return result
	}

	// MARK: Data

	/// Runs a GET request for the given URL (synchronously) and returns the result, as raw Data.
	static func getAsData(_ urlString: String) -> Data? {
		let url = URL(string: urlString)!
		return URLRequest.getAsData(url)
	}

	/// Runs a GET request for the given URL (synchronously) and returns the result, as raw Data.
	static func getAsData(_ url: URL) -> Data? {
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		return request.getAsData()
	}

	/// Runs the URLRequest (synchronously) and returns the result, as raw Data.
	func getAsData() -> Data? {
		var done = false

		var result: Data?
		URLSession.shared.dataTask(with: self) { (data, response, error) in
			guard error == nil else { print(error!.localizedDescription); return }
			guard let data = data else { print("Empty data"); return }

			result = data

			done = true
		}.resume()

		while !done { }

		return result
	}
}

// MARK: - Data

public extension Int {
	/// The number of megabytes in this data, formated to be human-readable.
	/// Inspired by: https://stackoverflow.com/questions/42722498/print-the-size-megabytes-of-data-in-swift
	var kilobytesString: String {
		let byteCountFormatter = ByteCountFormatter()
		byteCountFormatter.allowedUnits = [.useKB]
		byteCountFormatter.countStyle = .file
		return byteCountFormatter.string(fromByteCount: Int64(self))
	}

	/// The number of megabytes in this data, formated to be human-readable.
	/// Inspired by: https://stackoverflow.com/questions/42722498/print-the-size-megabytes-of-data-in-swift
	var megabytesString: String {
		let byteCountFormatter = ByteCountFormatter()
		byteCountFormatter.allowedUnits = [.useMB]
		byteCountFormatter.countStyle = .file
		return byteCountFormatter.string(fromByteCount: Int64(self))
	}
}

public extension Data {
	/// The number of bytes in this data.
	var bytes: Int {
		return self.count
	}

	/// The number of kilobytes in this data (truncated).
	var kilobytes: Int {
		return self.bytes / 1024
	}

	/// The number of megabytes in this data (truncated).
	var megabytes: Int {
		return self.kilobytes / 1024
	}

	/// The number of megabytes in this data, formated to be human-readable.
	/// Inspired by: https://stackoverflow.com/questions/42722498/print-the-size-megabytes-of-data-in-swift
	var kilobytesString: String {
		return self.count.kilobytesString
	}

	/// The number of megabytes in this data, formated to be human-readable.
	/// Inspired by: https://stackoverflow.com/questions/42722498/print-the-size-megabytes-of-data-in-swift
	var megabytesString: String {
		return self.count.megabytesString
	}
}
