#
#
#

isString = (obj)->
  toString.call(obj) is '[object String]'

isArray = (obj)->
  toString.call(obj) is '[object Array]'

class exports.UTF16 extends Array
  constructor: (string)->
    super
    for v in UTF16.unpack string
      @push v
      
  pack: ->
    UTF16.pack @codes

  toString: ->
    @pack()
  
  @unpack: (string)->
    utf16 = []
    throw new TypeError("Parameter 'string' must be a string") unless isString(string)

    for _, i in string
      utf16.push string.charCodeAt i      
    utf16

  @pack: (array)->
    str = ''
    
    throw new TypeError("Parameter 'array' must be a array") unless isArray(array)
    
    for i in array
      str += String.fromCharCode i
    str

class Char
  @unpack: (string)->
    utf16 = UTF16.unpack string
    tmp = []
    n = 0
    for v in utf16
      if v <= 0xff
        tmp[n++] = v
      else
        tmp[n++] = v >> 8
        tmp[n++] = v & 0xff
    tmp
                                                                    
  @pack: (char)->
    UTF16.pack char

class exports.UTF8

  codes = ''
  
  constructor: (string)->
    #

  @toUTF8: (utf16)->
    throw new TypeError("Parameter 'utf16' must be a array") unless isArray(utf16)
    
    utf8 = []
    idx = 0
    j = 0
    for c in utf16
      if c <= 0x7f
        utf8[idx++] = c
      else if c <= 0x7ff
        utf8[idx++] = 0xc0 | (c >>> 6 )
        utf8[idx++] = 0x80 | (c & 0x3f)
      else if c <= 0xffff
        utf8[idx++] = 0xe0 | (c >>> 12 )
        utf8[idx++] = 0x80 | ((c >>> 6 ) & 0x3f)
        utf8[idx++] = 0x80 | (c & 0x3f)
      else
        j = 4
        j++ while ( c >> ( 6 * j ) ) 
        utf8[idx++] = (( 0xff00 >>> j ) & 0xff) | (c >>> ( 6 * --j ) )
        utf8[idx++] = 0x80 | ((c >>> (6*j)) & 0x3f) while --j
    utf8
