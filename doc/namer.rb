  
  vowels = %w{a e i o u}
  consonants = ('a'..'z').to_a - vowels - ["q"]
  
  first_vowels = %w{a e o u}
  second_vowels = %w{a o u}
  
  consonants.each do |c1|
    consonants.each do |c2|
      first_vowels.each_with_index do |v1, i|
        second_vowels.each_with_index do |v2, j|
          print "\n" if i==0 && j==0
          print c1 + v1 + c2 + v2 + "  "
        end
      end
    end
  end
