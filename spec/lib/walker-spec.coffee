EventEmitter = require('events').EventEmitter

describe 'Walker', ->

  Given -> @Zombie = class Zombie
    visit: (url, cb) -> cb null, @, 200
  
  Given -> @Walker = requireSubject 'lib/walker', {
    'zombie': @Zombie
  }

  Then -> expect(typeof @Walker).toBe 'function'

  describe '#', ->

    Given -> @res = @Walker()
    Then -> expect(@res instanceof @Walker).toBe true
    And -> expect(@res instanceof EventEmitter).toBe true
    And -> expect(@res.options).toEqual agents: []
    And -> expect(@res.listeners('walk')[0]).toBe @res.onWalk
    And -> expect(@res.listeners('walking')[0]).toBe @res.onWalking
    And -> expect(@res.listeners('walked')[0]).toBe @res.onWalked
    And -> expect(@res.listeners('error')[0]).toBe @res.onError

  describe '# (options:Object)', ->

    Given -> @options = agents: ['manta/1.0']
    When -> @res = @Walker(@options)
    Then -> expect(@res.options).toEqual @options
  
  describe 'prototype', ->

    Given -> @url = 'http://www.manta.com'
    Given -> @cb = jasmine.createSpy('cb')
    Given -> @walker = @Walker()

    describe '#onUrl (url:String)', ->

      Given -> spyOn(@walker,'walk')
      When -> @walker.onUrl @url
      Then -> expect(@walker.walk).toHaveBeenCalledWith @url, jasmine.any(Function)

    describe '#onUrl (url:String, cb:Function)', ->

      Given -> spyOn(@walker,'walk')
      When -> @walker.onUrl @url, @cb
      Then -> expect(@walker.walk).toHaveBeenCalledWith @url, @cb

    describe '#walk (url:String)', ->

      Given -> @paths = []
      Given -> spyOn(@paths,'push').andCallThrough()
      Given -> spyOn(@walker, 'paths').andReturn @paths
      Given -> @path = jasmine.createSpy()
      Given -> spyOn(@walker, 'path').andReturn @path
      Given -> spyOn(@walker, 'emit').andCallThrough()
      Given -> @cb = jasmine.createSpy 'cb'
      When -> @res = @walker.walk @url, @cb
      Then -> expect(@res).toBe @walker
      And -> expect(@walker.path).toHaveBeenCalledWith @url, @cb
      And -> expect(@walker.paths).toHaveBeenCalled()
      And -> expect(@paths.push).toHaveBeenCalledWith @path
      And -> expect(@walker.emit).toHaveBeenCalledWith 'walk'
      And -> expect(@walker.walking()).toBe true

    describe '#paths', ->

      When -> @res = @walker.paths()
      Then -> expect(typeof @res).toEqual 'object'
      And -> expect(@res).toEqual []

    describe '#path (url:String, cb:Function)', ->

      Given -> spyOn(@walker,'process').andCallThrough()
      Given -> @path = @walker.path @url, @cb
      Given -> @next = jasmine.createSpy('next')
      When -> @path(@next)
      Then -> expect(typeof @path).toBe 'function'
      And -> expect(@path.url).toBe @url
      And -> expect(@walker.process).toHaveBeenCalledWith @url, jasmine.any(Function)
      And -> expect(@next).toHaveBeenCalledWith null, @walker.zombie(), 200
      And -> expect(@cb).toHaveBeenCalledWith null, @walker.zombie(), 200

    describe '#process (url:String, cb:Function)', ->

      Given -> spyOn @walker.zombie(), 'visit'
      When -> @walker.process @url, @cb
      Then -> expect(@walker.zombie().visit).toHaveBeenCalledWith @url, @cb

    describe '#zombie', ->

      When -> @res = @walker.zombie()
      Then -> expect(typeof @res).toBe 'object'
      And -> expect(@res instanceof @Zombie).toBe true

    describe '#walking', ->

      Then -> expect(@walker.walking()).toBe false

    describe '#onWalk', ->

      Given -> @walker.paths().push @walker.path @url, @cb
      Given -> spyOn(@walker, 'emit').andCallThrough()
      When -> @walker.onWalk()
      Then -> expect(@walker.emit.argsForCall[0]).toEqual ['walking', @url]
      And -> expect(@walker.emit.argsForCall[1]).toEqual ['walked', @url, @walker.zombie(), 200]
      And -> expect(@walker.emit.argsForCall[2]).toEqual ['done']

    describe '#onWalking (url:String)', ->

      When -> @walker.onWalking()
      Then -> expect(@walker.walking()).toBe true

    describe '#onWalked (url:String, zombie:Zombie, status:mixed)', ->

      When -> @walker.onWalked()
      Then -> expect(@walker.walking()).toBe false

    describe '#onError (err:Error, url:String, zombie:Zombie, status:mixed)', ->
      
      Given -> spyOn console, 'error'
      Given -> @err = 'error'
      When -> @walker.onError @err
      Then -> expect(console.error).toHaveBeenCalledWith @err

