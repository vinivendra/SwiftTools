
import Foundation

/// Pad a number with a `0` to the left if needed. Created especially for minutes/seconds in time formatting (e.g. `"10:05"`)
func padTime(_ time: Int) -> String {
	if time < 10 {
		return "0\(time)"
	}
	else {
		return "\(time)"
	}
}

public extension Array where Element: RandomAccessCollection, Element.Index == Int {
	/// Pretty prints this Array as a two-dimensional table using Unicode box characters.
	func display() {
		guard !self.isEmpty else {
			return
		}

		var maxLengths: [Int] = []
		for index in self[0].indices {
			let maxLength = self.map { "\($0[index])".count }.max()!
			maxLengths.append(maxLength)
		}

		var result = ""

		result += tableLine(maxLengths, left: "┌", middle: "─", cross: "┬", right: "┐")
		result += "\n"

		for (row, rowLimit) in self.enumeratedWithLimits() {
			result += "│ "
			for (index, itemLimit) in row.indices.enumeratedWithLimits() {
				let item = row[index]
				let maxLength = maxLengths[index]

				let string = "\(item)"
				result += string

				for _ in string.count..<maxLength {
					result += " "
				}

				if itemLimit != .end {
					result += " │ "
				}
				else {
					result += " │"
				}
			}
			result += "\n"

			if rowLimit != .end {
				result += tableLine(maxLengths, left: "├", middle: "─", cross: "┼", right: "┤")
				result += "\n"
			}
		}

		result += tableLine(maxLengths, left: "└", middle: "─", cross: "┴", right: "┘")
		result += "\n"

		print(result)
	}
}

public extension Array {
	/// Pretty prints this Array using Unicode box characters.
	func display() {
		self.map { [$0] }.display()
	}

	/// Returns the first `n` elements of the Array (as an Array).
	func first(_ n: Int) -> [Element] {
		return Array(self.dropLast(self.count - n))
	}

	/// Turns a one-dimensional Array into a two-dimensional one using `size` as the size of the rows.
	func fold(in size: Int) -> [[Element]] {
		var result: [[Element]] = []
		for i in stride(from: 0, to: self.count, by: size) {
			guard i + size - 1 < self.count else {
				break
			}

			var row: [Element] = []
			for j in i..<(i+size) {
				row.append(self[j])
			}
			result.append(row)
		}

		return result
	}

	/// Returns `nil` if the index is out of bounds.
	subscript (safe safeIndex: Int) -> Element? {
		if safeIndex > 0, safeIndex < self.count {
			return self[safeIndex]
		}
		else {
			return nil
		}
	}
}
