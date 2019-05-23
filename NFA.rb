require 'set'

class FARule < Struct.new(:state, :character, :next_state)
  def applies_to?(state, character)
    self.state == state && self.character == character
  end
  def follow
    next_state
  end
  def inspect
    "#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>"
  end
end

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map{|state| follow_rules_for(state, character)}.to_set
  end
  def follow_rules_for(state, character)
    rules_for(state, character).map(&:follow)
  end
  def rules_for(state, character)
    rules.select {|rule| rule.applies_to?(state, character)}
  end
end

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  def accepting?
    (current_states & accept_states).any?
  end
  def read_character(char)
    self.current_states = rulebook.next_states(self.current_states, char)
  end
  def read_string(str)
    str.chars.each do |char|
      read_character(char)
    end
  end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accept?(string)
    to_nfa.tap {|nfa| nfa.read_string(string)}.accepting?
  end
  def to_nfa
    NFA.new(Set[start_state], accept_states, rulebook)
  end
end

rulebook = NFARulebook.new([
  FARule.new(1, 'a', 1), FARule.new(1, 'b', 1), FARule.new(1, 'b', 2),
  FARule.new(2, 'a', 3), FARule.new(2, 'b', 3),
  FARule.new(3, 'a', 4), FARule.new(3, 'b', 4)
])

nfa_design = NFADesign.new(1, [4], rulebook)

puts nfa_design.accept?('bbbbb')
