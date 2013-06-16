describe 'String Extensions', ->
  describe 'when decapitalizing a string', ->
    it 'returns the expected decapitalized string', ->
      expect('String'.decapitalize()).toEqual('string')
      expect('MultiString'.decapitalize()).toEqual('multiString')

  describe 'when finding out if a string starts with another string', ->
    it 'returns true for the start of the string', ->
      expect('string'.startsWith('s')).toBeTruthy()

    it 'returns false for anything else in the string', ->
      expect('string'.startsWith('t')).toBeFalsy()

    it 'returns false for anything else not in the string', ->
      expect('string'.startsWith('a')).toBeFalsy()

  describe 'when finding out if a string ends with another string', ->
    it 'returns true for the end of the string', ->
      expect('string'.endsWith('g')).toBeTruthy()

    it 'returns false for anything else in the string', ->
      expect('string'.endsWith('t')).toBeFalsy()

    it 'returns false for anything else not in the string', ->
      expect('string'.endsWith('a')).toBeFalsy()
