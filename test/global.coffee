global.chai   = require 'chai'
global.assert = chai.assert
global.expect = chai.expect
global.eql    = assert.deepEqual
{sinon, spy}  = require 'sinon'
global.sinon  = sinon
global.spy    = spy
