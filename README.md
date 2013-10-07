Edit With X
===========

Allow user to edit web-page on Chrome textareas with any text editor.

(I'm using Mac 10.8.x and [Sublime Text 3](http://www.sublimetext.com/3) now.)

## Screenshots

![](https://raw.github.com/fukayatsu/edit-with-x-crx/master/screenshots/edit-with-x-usage.png)
---
![](https://raw.github.com/fukayatsu/edit-with-x-crx/master/screenshots/edit-with-x-config.png)

## Servers
Google Chrome can't open text editor directory. So you need a server.

- Mac app (using HTTP)
    - [EditWithX-0.0.1.zip](https://github.com/fukayatsu/edit-with-x-crx/blob/master/servers/mac-http/build/EditWithX-0.0.1.zip?raw=true) (written in macruby)
- Ruby (using HTTP)
    - [servers/ruby-http](https://github.com/fukayatsu/edit-with-x-crx/tree/master/servers/ruby-http)
- Ruby (using WebSocket)
    - [servers/ruby-ws](https://github.com/fukayatsu/edit-with-x-crx/tree/master/servers/ruby-ws)

## Configuration

```yml
# protocol (http or ws)
# protocol: ws # web WebSocket
protocol: http # use HTTP

# port (default 51234)
port: 51234

# editor path
# editor: "gvim" # gvim (not tested)
# editor: "/Applications/MacVim.app/Contents/MacOS/mvim" # macvim
editor: "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"

# open file command
# command: "${editor} -f +${line} ${file}"        # for vim
command: "${editor} -w ${file}:${line}:${col}" # for sublime text

# tempfile extension (default: '.md')
# ext: '.txt'
ext: '.md'

# open editor with shortcut key in textarea (default: false)
shortcut: e.metaKey && e.keyCode == 73   #  this is "cmd + i" # `e` is JS event

# open editor with double-click in textarea (dafault: false)
# double_click: true

# output log message via console.log (default: false)
# debug: true

# reflesh interval in ms (default: 1000)
# interval: 3000

# change textarea color while editing
color: '#4169e1'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## LICENSE:

(The MIT License)

Copyright (c) 2013 fukayatsu

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
