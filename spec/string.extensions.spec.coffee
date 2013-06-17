describe 'String Extensions', ->
  describe '#decapitalize', ->
    it 'returns the expected decapitalized string', ->
      expect('String'.decapitalize()).toEqual 'string'
      expect('MultiString'.decapitalize()).toEqual 'multiString'

  describe '#startsWith', ->
    it 'returns true for the start of the string', ->
      expect('string'.startsWith('s')).toBeTruthy()

    it 'returns false for anything else in the string', ->
      expect('string'.startsWith('t')).toBeFalsy()

    it 'returns false for anything else not in the string', ->
      expect('string'.startsWith('a')).toBeFalsy()

  describe '#endsWith', ->
    it 'returns true for the end of the string', ->
      expect('string'.endsWith('g')).toBeTruthy()

    it 'returns false for anything else in the string', ->
      expect('string'.endsWith('t')).toBeFalsy()

    it 'returns false for anything else not in the string', ->
      expect('string'.endsWith('a')).toBeFalsy()
