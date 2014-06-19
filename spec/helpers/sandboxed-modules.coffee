SandboxedModule = require('sandboxed-module')
SandboxedModule.registerBuiltInSourceTransformer("istanbul")

global.requireSubject = (path, requires) ->
  SandboxedModule.require("./../../#{path}",  {requires})
