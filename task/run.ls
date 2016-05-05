require! \electron-prebuilt

export run = ->*
  spawn "#{electron-prebuilt} ."
