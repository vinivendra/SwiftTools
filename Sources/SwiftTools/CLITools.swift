
/// Open the file and return its contents.
public func open(_ fileName: String) -> String {
	return try! String(contentsOfFile: fileName)
}

/// Helper for displaying an array as a table
func tableLine(_ maxLengths: [Int], left: String, middle: String, cross: String, right: String) -> String {
	var result = left + middle
	for (index, limit) in maxLengths.indices.enumeratedWithLimits() {
		let maxLength = maxLengths[index]

		for _ in 0..<maxLength {
			result += middle
		}

		if limit != .end {
			result += middle + cross + middle
		}
		else {
			result += middle + right
		}
	}

	return result
}
