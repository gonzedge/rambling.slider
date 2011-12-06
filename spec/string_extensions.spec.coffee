require '../src/string_extensions'

describe 'String Extensions', ->
  describe 'when finding out if a string contains a given string', ->
    it 'should return true for a contained string', ->
      expect('string'.contains('s')).toBeTruthy()

    it 'should return false for a non contained string', ->
      expect('string'.contains('z')).toBeFalsy()

  describe 'when decapitalizing a string', ->
    it 'should return the expected decapitalized string', ->
      expect('String'.decapitalize()).toEqual('string')
      expect('MultiString'.decapitalize()).toEqual('multiString')

  describe 'when finding out if a string starts with another string', ->
    it 'should return true for the start of the string', ->
      expect('string'.startsWith('s')).toBeTruthy()

    it 'should return false for anything else in the string', ->
      expect('string'.startsWith('t')).toBeFalsy()

    it 'should return false for anything else not in the string', ->
      expect('string'.startsWith('a')).toBeFalsy()

  describe 'when finding out if a string ends with another string', ->
    it 'should return true for the end of the string', ->
      expect('string'.endsWith('g')).toBeTruthy()

    it 'should return false for anything else in the string', ->
      expect('string'.endsWith('t')).toBeFalsy()

    it 'should return false for anything else not in the string', ->
      expect('string'.endsWith('a')).toBeFalsy()
