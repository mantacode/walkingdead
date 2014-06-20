EventEmitter = require('events').EventEmitter

describe 'walkingdead', ->

  Given -> @Zombie = class Zombie
    visit: (url, cb) -> cb null, @, 200
  
  Given -> @WalkingDead = requireSubject 'lib', {
    './../package.json':
      version: 1
    'zombie': @Zombie
  }

  Then -> expect(typeof @WalkingDead).toBe 'function'

  describe '.version', ->

    When -> @version = @WalkingDead.version
    Then -> expect(@version).toEqual 1

  describe '#', ->

    Given -> @res = @WalkingDead()
    Then -> expect(@res instanceof @WalkingDead).toBe true
    And -> expect(@res instanceof EventEmitter).toBe true
    And -> expect(@res.options).toEqual agents: []
    And -> expect(@res.listeners('walk')[0]).toBe @res.onWalk
    And -> expect(@res.listeners('walking')[0]).toBe @res.onWalking
    And -> expect(@res.listeners('walked')[0]).toBe @res.onWalked
    And -> expect(@res.listeners('error')[0]).toBe @res.onError

  describe '# (options:Object)', ->

    Given -> @options = agents: ['manta/1.0']
    When -> @res = @WalkingDead(@options)
    Then -> expect(@res.options).toEqual @options
  
  describe 'prototype', ->

    Given -> @url = 'http://www.manta.com'
    Given -> @cb = jasmine.createSpy('cb')
    Given -> @wd = @WalkingDead()

    describe '#onUrl (url:String)', ->

      Given -> spyOn(@wd,'walk')
      When -> @wd.onUrl @url
      Then -> expect(@wd.walk).toHaveBeenCalledWith @url, jasmine.any(Function)

    describe '#onUrl (url:String, cb:Function)', ->

      Given -> spyOn(@wd,'walk')
      When -> @wd.onUrl @url, @cb
      Then -> expect(@wd.walk).toHaveBeenCalledWith @url, @cb

    describe '#walk (url:String)', ->

      Given -> @paths = []
      Given -> spyOn(@paths,'push').andCallThrough()
      Given -> spyOn(@wd, 'paths').andReturn @paths
      Given -> @path = jasmine.createSpy()
      Given -> spyOn(@wd, 'path').andReturn @path
      Given -> spyOn(@wd, 'emit').andCallThrough()
      Given -> @cb = jasmine.createSpy 'cb'
      When -> @res = @wd.walk @path, @cb
      Then -> expect(@res).toBe @wd
      And -> expect(@wd.path).toHaveBeenCalledWith @path, @cb
      And -> expect(@wd.paths).toHaveBeenCalled()
      And -> expect(@paths.push).toHaveBeenCalledWith @path
      And -> expect(@wd.emit).toHaveBeenCalledWith 'walk'
      And -> expect(@wd.walking()).toBe true

    describe '#paths', ->

      When -> @res = @wd.paths()
      Then -> expect(typeof @res).toEqual 'object'
      And -> expect(@res).toEqual []

    describe '#path (url:String, cb:Function)', ->

      Given -> spyOn(@wd,'process').andCallThrough()
      Given -> @path = @wd.path @url, @cb
      Given -> @next = jasmine.createSpy('next')
      When -> @path(@next)
      Then -> expect(typeof @path).toBe 'function'
      And -> expect(@path.url).toBe @url
      And -> expect(@wd.process).toHaveBeenCalledWith @url, jasmine.any(Function)
      And -> expect(@next).toHaveBeenCalledWith null, @wd.zombie(), 200
      And -> expect(@cb).toHaveBeenCalledWith null, @wd.zombie(), 200

    describe '#process (url:String, cb:Function)', ->

      Given -> spyOn @wd.zombie(), 'visit'
      When -> @wd.process @url, @cb
      Then -> expect(@wd.zombie().visit).toHaveBeenCalledWith @url, @cb

    describe '#zombie', ->

      When -> @res = @wd.zombie()
      Then -> expect(typeof @res).toBe 'object'
      And -> expect(@res instanceof @Zombie).toBe true

    describe '#walking', ->

      Then -> expect(@wd.walking()).toBe false

    describe '#onWalk', ->

      Given -> @wd.paths().push @wd.path @url, @cb
      Given -> spyOn(@wd, 'emit').andCallThrough()
      When -> @wd.onWalk()
      Then -> expect(@wd.emit.argsForCall[0]).toEqual ['walking', @url]
      And -> expect(@wd.emit.argsForCall[1]).toEqual ['walked', @url, @wd.zombie(), 200]
      And -> expect(@wd.emit.argsForCall[2]).toEqual ['done']

    describe '#onWalking', ->

      When -> @wd.onWalking()
      Then -> expect(@wd.walking()).toBe true

    describe '#onWalked', ->

      When -> @wd.onWalked()
      Then -> expect(@wd.walking()).toBe false

    describe '#onError', ->
      
      Given -> spyOn console, 'error'
      Given -> @err = 'error'
      When -> @wd.onError @err
      Then -> expect(console.error).toHaveBeenCalledWith @err

