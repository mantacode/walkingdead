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

  describe '# (options:Object)', ->

    Given -> @options = agents: ['manta/1.0']
    When -> @res = @Walker(@options)
    Then -> expect(@res.options).toEqual @options
  
  describe 'prototype', ->

    Given -> @url = 'http://www.manta.com'
    Given -> @url = 'manta/1.0'
    Given -> @cb = jasmine.createSpy('cb')
    Given -> @walker = @Walker()
    Given -> spyOn(@walker,'emit').andCallThrough()

    describe '#onUrl (url:String)', ->

      Given -> spyOn(@walker,'walk')
      When -> @walker.onUrl @url
      Then -> expect(@walker.walk).toHaveBeenCalledWith @url, jasmine.any(Function)

    describe '#onUrl (url:String, cb:Function)', ->

      Given -> spyOn(@walker,'walk')
      When -> @walker.onUrl @url, @cb
      Then -> expect(@walker.walk).toHaveBeenCalledWith @url, @cb

    describe '#walk (url:String, cb:Function)', ->

      Given -> @paths = []
      Given -> spyOn(@paths,'push').andCallThrough()
      Given -> spyOn(@walker, 'paths').andReturn @paths
      Given -> @path = jasmine.createSpy()
      Given -> spyOn(@walker, 'path').andReturn @path
      Given -> spyOn(@walker, 'onWalk').andCallThrough()
      Given -> @cb = jasmine.createSpy 'cb'
      When -> @res = @walker.walk @url, @cb
      Then -> expect(@res).toBe @walker
      And -> expect(@walker.path).toHaveBeenCalledWith @url, @ua, @cb
      And -> expect(@walker.paths).toHaveBeenCalled()
      And -> expect(@paths.push).toHaveBeenCalledWith @path
      And -> expect(@walker.onWalk).toHaveBeenCalled()
      And -> expect(@walker.emit).toHaveBeenCalledWith 'walk'
      And -> expect(@walker.walking()).toBe true

    describe '#paths', ->

      When -> @res = @walker.paths()
      Then -> expect(typeof @res).toEqual 'object'
      And -> expect(@res).toEqual []

    describe '#path (url:String, ua:String, cb:Function)', ->

      Given -> spyOn(@walker,'process').andCallThrough()
      Given -> @path = @walker.path @url, @ua, @cb
      Given -> @next = jasmine.createSpy('next')
      When -> @path(@next)
      Then -> expect(typeof @path).toBe 'function'
      And -> expect(@path.url).toBe @url
      And -> expect(@path.ua).toBe @ua
      And -> expect(@walker.process).toHaveBeenCalledWith @url, @ua, jasmine.any(Function)
      And -> expect(@next).toHaveBeenCalledWith null, @walker.zombie(), 200
      And -> expect(@cb).toHaveBeenCalledWith null, @walker.zombie(), 200

    describe '#process (url:String, ua:String, cb:Function)', ->

      Given -> spyOn @walker.zombie(), 'visit'
      When -> @walker.process @url, @ua, @cb
      Then -> expect(@walker.zombie().visit).toHaveBeenCalledWith @url, @cb

    describe '#zombie', ->

      When -> @res = @walker.zombie()
      Then -> expect(typeof @res).toBe 'object'
      And -> expect(@res instanceof @Zombie).toBe true

    describe '#walking', ->

      Then -> expect(@walker.walking()).toBe false

    describe '#onWalk', ->

      Given -> @walker.paths().push @walker.path @url, @ua, @cb
      When -> @walker.onWalk()
      And -> expect(@walker.emit.argsForCall[0]).toEqual ['walk']
      And -> expect(@walker.emit.argsForCall[1]).toEqual ['walking', @url, @ua]
      And -> expect(@walker.emit.argsForCall[2]).toEqual ['walked', @url, @ua, @walker.zombie(), 200]
      And -> expect(@walker.emit.argsForCall[3]).toEqual ['done']

    describe '#onWalking (url:String, ua:String)', ->

      When -> @walker.onWalking @url, @ua
      Then -> expect(@walker.walking()).toBe true
      And -> expect(@walker.emit).toHaveBeenCalledWith 'walking', @url, @ua

    describe '#onWalked (url:String, ua:String, zombie:Zombie, status:mixed)', ->

      When -> @walker.onWalked @url, @ua, @walker.zombie(), 200
      Then -> expect(@walker.walking()).toBe false
      And -> expect(@walker.emit).toHaveBeenCalledWith 'walked', @url, @ua, @walker.zombie(), 200

    describe '#onError (err:Error, url:String, ua:String, zombie:Zombie, status:mixed)', ->
      
      Given -> spyOn console, 'error'
      Given -> @err = 'error'
      Given -> @walker.on 'error', @cb
      When -> @walker.onError @err, @url, @ua, @walker.zombie(), 500
      Then -> expect(console.error).toHaveBeenCalledWith @err
      And -> expect(@walker.emit).toHaveBeenCalledWith 'error', @err, @url, @ua, @walker.zombie(), 500
      And -> expect(@cb).toHaveBeenCalledWith @err, @url, @ua, @walker.zombie(), 500

