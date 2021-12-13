
import Foundation

/// Open the file and interpret it as JSON.
public func openJSON(_ fileName: String) -> JSON {
	return open(fileName).toJSON()
}

/// Turn the String into a JSON object.
public extension String {
	func toJSON() -> JSON {
		if let data = self.data(using: .utf8) {
			do {
				let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
				return SwiftTools.toJSON(jsonObject)
			} catch {
				print(error.localizedDescription)
			}
		}
		fatalError("Failed to convert")
	}
}

/// Turn any (compatible) object into a JSON object.
public func toJSON(_ any: Any) -> JSON {
	if let object = any as? [String: Any] {
		var result = [String: JSON]()
		for tuple in object {
			let json = toJSON(tuple.value)
			result[tuple.key] = json
		}
		return .object(result)
	}
	else if let array = any as? [Any] {
		var result = [JSON]()
		for element in array {
			let json = toJSON(element)
			result.append(json)
		}
		return .array(result)
	}
	else if let int = any as? Int {
		return .int(int)
	}
	else if let double = any as? Double {
		return .double(double)
	}
	else if let string = any as? String {
		if let int = Int(string) {
			return .int(int)
		}
		else if let double = Double(string) {
			return .double(double)
		}
		else {
			return .string(string)
		}
	}
	else if any is NSNull {
		return .null
	}
	else {
		fatalError("Failed to convert unknown object to JSON: \(any)")
	}
}

/// A JSON object that can include any type supported by JSON.
/// Created dynamically, without checking any specific properties or types.
/// Supports dynamic member lookup, so properties can be accessed directly (e.g. json.myProperty).
/// Final properties should be casted to the appropriate types with `toDouble`, `toArray`, etc.
/// Supports pretty printing with `prettyPrint()` or `display()`.
@dynamicMemberLookup
public enum JSON: PrintableAsTree {
	case object([String: JSON])
	case array([JSON])
	case double(Double)
	case int(Int)
	case string(String)
	case null

	/// `myJson.myProperty`
	public subscript(dynamicMember member: String) -> JSON {
		switch self {
		case let .object(dictionary):
			return dictionary[member]!
		default:
			fatalError("No member \"\(member)\"")
		}
	}

	/// `myJson.myProperty` returning `nil` if the property isn't there.
	public subscript(safe member: String) -> JSON? {
		switch self {
		case let .object(dictionary):
			return dictionary[member]
		default:
			return nil
		}
	}

	/// `json.myProperty[0]`
	public subscript(int: Int) -> JSON {
		switch self {
		case let .array(array):
			return array[int]
		default:
			fatalError("Not an array")
		}
	}

	/// `json.myProperty.toArray.map { ... }`
	public var toArray: [JSON] {
		switch self {
		case let .array(array):
			return array
		default:
			fatalError("Not an array")
		}
	}

	/// `json.myProperty.toDictionary["foo"]`
	public var toDictionary: [String: JSON] {
		switch self {
		case let .object(object):
			return object
		default:
			fatalError("Not an object")
		}
	}

	/// `json.myProperty.toDouble`
	public var toDouble: Double {
		switch self {
		case let .double(double):
			return double
		default:
			fatalError("Not a double")
		}
	}

	/// `json.myProperty.toInt`
	public var toInt: Int {
		switch self {
		case let .int(int):
			return int
		default:
			fatalError("Not an int")
		}
	}

	/// `json.myProperty.toString`
	public var toString: String {
		switch self {
		case let .string(string):
			return string
		default:
			fatalError("Not a string")
		}
	}

	/// `json.myProperty.isNull`: checks if the object is present or if it's a JSON `null`.
	public var isNull: Bool {
		switch self {
		case .null:
			return true
		default:
			return false
		}
	}

	/// Conformance to `PrintableAsTree`
	public var treeDescription: String {
		switch self {
		case .object:
			return "object"
		case .array:
			return "array"
		case let .double(double):
			return String(double)
		case let .int(int):
			return String(int)
		case let .string(string):
			return String(string)
		case .null:
			return "null"
		}
	}

	/// Conformance to `PrintableAsTree`
	public var printableSubtrees: List<PrintableAsTree?> {
		switch self {
		case let .object(dictionary):
			return List(dictionary.map { tuple in
				switch tuple.value {
				case .object, .array:
					return PrintableTree(tuple.key, [tuple.value])
				default:
					return PrintableTree("\(tuple.key) → \(tuple.value)")
				}
			})
		case let .array(array):
			return List(array)
		default:
			return []
		}
	}

	public func display() {
		prettyPrint()
	}
}
