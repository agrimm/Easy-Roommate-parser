class NotesParser
  def initialize(notes_file)
    @notes_text = notes_file.read
  end

  def reject_existing_people(people)
    results = Array.new(people)
    @notes_text.split("\n").each do |line|
      next unless line =~ /from|of/
      results.delete_if do |person|
        line.include?(person.easyroommate_id)
      end
    end
    results
  end
end
