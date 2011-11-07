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
