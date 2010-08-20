class NotesParser
  def initialize(notes_file)
    @notes_text = notes_file.read
  end

  def reject_existing_people(people)
    results = Array.new(people)
    @notes_text.split("\n").each do |line|
      next unless line =~ /from|of/
      results.delete_if do |person|
        regexp = Regexp.compile(Regexp.escape(person.firstname) + " +(from|of) +" + Regexp.escape(person.suburb), true)
        line =~ regexp
      end
    end
    results
  end
end
