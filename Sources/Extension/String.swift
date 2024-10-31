
import Foundation

extension String {
    /// Removes HTML tags from the string, returning a plain text version.
    func removingHTMLTags() -> String {
        let pattern = "<.*?>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.utf16.count)
        // Replace all matches of the pattern with an empty string
        let plainText = regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "") ?? self
        return plainText
    }
}
