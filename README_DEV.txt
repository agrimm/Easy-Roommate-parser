Overview of how the program works:

The EasyroommateParser has a ResultParser, and a NotesParser.

The ResultParser parses an HTML page containing a list of results, and returns a list of people.

The NotesParser parses a plain-text file containing notes on existing profiles. 
It checks whether the people listed by ResultParser are already described in the notes.

If there are people who are not described in the notes, they will be queued for downloading if they haven't been downloaded.
If they have been downloaded, then they will be examined and described as either compatible with the searcher, or incompatible.