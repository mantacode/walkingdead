describe 'walkingdead', ->
  
  Given -> @WalkingDead = requireSubject 'lib', {
    './../package.json':
      version: 1
  }

  Then -> expect(typeof @WalkingDead).toBe 'function'

  describe '#', ->

    Then -> expect(@WalkingDead() instanceof @WalkingDead)

  describe '.version', ->

    When -> @version = @WalkingDead.version
    Then -> expect(@version).toEqual 1

