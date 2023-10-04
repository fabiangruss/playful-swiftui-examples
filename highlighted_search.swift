// Parent view with the search functionality.
// Search here is based on a Person object with first- and possibly lastName
struct PersonAddingSheet: View {

  @State private var searchText: String = ""
  // ...
  var body: some View {
    // ...
    // Calculate search results (not case sensitive)
    var searchResults: [Person] {
      if searchText.isEmpty {
        return persons
      } else {
        return persons.filter {
          var name = "\($0.firstName)"
          if $0.lastName != nil {
            name += " \($0.lastName!)"
          }
          return name.lowercased().contains(searchText.lowercased())
        }
      }
    }
    // ...
    // Hand over current searchText to element
    ForEach(searchResults, id: \.id) { singlePerson in
      PersonListElement(person: singlePerson, numberOfUpdates: n, searchText: searchText)
    }
  }
}


// Child view that displays search highlighting
struct PersonListElement: View {
    var person: Person
    var numberOfUpdates: Int
    var searchText: String

  // This function builds the highlighted text
    func highlightedText(for string: String) -> some View {
        guard !searchText.isEmpty, let range = string.range(of: searchText, options: .caseInsensitive) else {
            // Default text
            return AnyView(Text(string).tinyCardHeader(fontWeight: .medium))
        }
    
        let prefix = String(string[string.startIndex..<range.lowerBound])
        let match = String(string[range])
        let suffix = String(string[range.upperBound..<string.endIndex])

        return AnyView(
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                // Here you can set different font weights or styles
                Text(prefix).tinyCardHeader(fontWeight: .medium)
                Text(match).tinyCardHeader(color: .accentColorPrimary, fontWeight: .bold)
                Text(suffix).tinyCardHeader(fontWeight: .medium)
            }
        )
    }

    var body: some View {
        HStack { HStack {
            VStack(alignment: .leading, spacing: 0) {
                Avatar(person: person, size: 44.0)
                    .padding(.bottom, 8)

                highlightedText(for: person.firstName + (person.lastName != nil ? " " + person.lastName! : ""))
                    .padding(.bottom, 4)

                Text("\(numberOfUpdates) updates")
                    .tinyCardSubtitle()
            }
            Spacer()
        }
        .frame(height: 124)

        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.buttonGrey)
        .cornerRadius(22)
        }
    }
}

  
        
