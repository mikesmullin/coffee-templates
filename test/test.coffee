CoffeeTemplates = require '../js/coffee-templates'
assert = require('chai').assert

describe 'CoffeeTemplates', ->
  engine = template = out = _expecting = globals = undefined
  expecting = (s)-> _expecting = s

  beforeEach ->
    template = out = _expecting = ''
    globals = {}
    engine = new CoffeeTemplates format: false, autoescape: false # defaults

  describe 'CoffeeCup Clone', ->
    afterEach ->
      if template and not out
        out = engine.render template, globals
      if _expecting is ''
        console.log JSON.stringify out
        assert false, 'no expectation set'
      else
        assert.equal out, _expecting
      assert.ok typeof doctype is 'undefined' # ensure no global leaks

    it 'renders tags with no ending', ->
      template = ->
        div()
      expecting '<div></div>'

    it 'renders tags with attribute objects, with no ending', ->
      template = ->
        div id: 'hamster'
      expecting '<div id="hamster"></div>'

    it 'renders tags with attribute objects, ending with string', ->
      template = ->
        div id: 'block-1', class: 'block', 'content'
      expecting "<div id=\"block-1\" class=\"block\">content</div>"

    it 'renders tags with attribute objects, ending with function', ->
      template = ->
        div id: 'block-1', class: 'block', ->
          p 'content'
      expecting "<div id=\"block-1\" class=\"block\"><p>content</p></div>"

    it 'renders html comments alone', ->
      template = ->
        comment 'humans'
      expecting '<!--humans-->'

    it 'renders html comments with functions', ->
      template = ->
        comment 'humans', ->
          div id: 'are', 'kind of smelly'
      expecting "<!--humans<div id=\"are\">kind of smelly</div>-->"

    it 'renders all html5 tags, including "var" tag using literal()', ->
      template = ->
        doctype(5);a();abbr();address();area();article();aside();audio();b();base();bdi();bdo();blockquote();body();br();button();canvas();caption();cite();code();col();colgroup();command();data();datagrid();datalist();dd();del();details();dfn();div();dl();dt();em();embed();eventsource();fieldset();figcaption();figure();footer();form();h1();h2();h3();h4();h5();h6();head();header();hgroup();hr();html();i();iframe();img();input();ins();kbd();keygen();label();legend();li();link();mark();map();menu();meta();meter();nav();noscript();object();ol();optgroup();option();output();p();param();pre();progress();q();ruby();rp();rt();s();samp();script();section();select();small();source();span();strong();style();sub();summary();sup();table();tbody();td();textarea();tfoot();th();thead();time();title();tr();track();u();ul();video();wbr()
        literal '<var></var>'
      expecting "<!doctype html><a></a><abbr></abbr><address></address><area/><article></article><aside></aside><audio></audio><b></b><base/><bdi></bdi><bdo></bdo><blockquote></blockquote><body></body><br/><button></button><canvas></canvas><caption></caption><cite></cite><code></code><col/><colgroup></colgroup><command></command><data></data><datagrid></datagrid><datalist></datalist><dd></dd><del></del><details></details><dfn></dfn><div></div><dl></dl><dt></dt><em></em><embed></embed><eventsource></eventsource><fieldset></fieldset><figcaption></figcaption><figure></figure><footer></footer><form></form><h1></h1><h2></h2><h3></h3><h4></h4><h5></h5><h6></h6><head></head><header></header><hgroup></hgroup><hr/><html></html><i></i><iframe></iframe><img/><input/><ins></ins><kbd></kbd><keygen></keygen><label></label><legend></legend><li></li><link/><mark></mark><map></map><menu></menu><meta/><meter></meter><nav></nav><noscript></noscript><object></object><ol></ol><optgroup></optgroup><option></option><output></output><p></p><param/><pre></pre><progress></progress><q></q><ruby></ruby><rp></rp><rt></rt><s></s><samp></samp><script></script><section></section><select></select><small></small><source></source><span></span><strong></strong><style></style><sub></sub><summary></summary><sup></sup><table></table><tbody></tbody><td></td><textarea></textarea><tfoot></tfoot><th></th><thead></thead><time></time><title></title><tr></tr><track></track><u></u><ul></ul><video></video><wbr></wbr><var></var>"

    it 'renders plain text with text()', ->
      template = ->
        div ->
          text 'hello'
      expecting '<div>hello</div>'

    it 'can escape text and attributes', ->
      engine = new CoffeeTemplates escape: true
      template = ->
        p "& D'oh! ><"
        div data: "& D'oh! ><"
        text "& D'oh! ><"
      expecting "<p>&amp; D&#39;oh! &gt;&lt;</p><div data=\"&amp; D&#39;oh! &gt;&lt;\"></div>&amp; D&#39;oh! &gt;&lt;"

    it 'renders local variables', ->
      globals = user: name: 'Jimmy'
      template = ->
        p "Welcome #{@user.name}!"
      expecting "<p>Welcome Jimmy!</p>"

    it 'renders handlebars markup', ->
      globals = title: 'Christmas List'
      template = ->
        p 'Hello, {{name}}!'
        p 'Here are your Christmas lists ({{santa_laugh}}):'
        table ->
          thead ->
            tr ->
              block 'each children, name', ->
                th '{{name}}'
          tbody ->
            tr ->
              block 'each children, name', ->
                td ->
                  block 'each list', ->
                    ul ->
                      li '{{this}}'
      expecting "<p>Hello, {{name}}!</p><p>Here are your Christmas lists ({{santa_laugh}}):</p><table><thead><tr>{{each children, name}}<th>{{name}}</th>{{/each}}</tr></thead><tbody><tr>{{each children, name}}<td>{{each list}}<ul><li>{{this}}</li></ul>{{/each}}</td>{{/each}}</tr></tbody></table>"

    it 'can iterate local variables', ->
      # test borrowed from ck lib
      globals =
        title: 'my first website!'
        posts: [{
          name: 'Mike'
          comment: 'Hello'
        },{
          name: 'Bob'
          comment: 'How are you?'
        }]
      template = ->
        doctype 5
        html ->
          head ->
            title @title
          body ->
            div id: 'content', ->
              for post in @posts
                div class: 'post', ->
                  p post.name
                  div post.comment
            form method: 'post', ->
              ul ->
                li -> input name: 'name'
                li -> textarea name: 'comment'
                li -> input type: 'submit'
      expecting "<!doctype html><html><head><title>my first website!</title></head><body><div id=\"content\"><div class=\"post\"><p>Mike</p><div>Hello</div></div><div class=\"post\"><p>Bob</p><div>How are you?</div></div></div><form method=\"post\"><ul><li><input name=\"name\"/></li><li><textarea name=\"comment\"></textarea></li><li><input type=\"submit\"/></li></ul></form></body></html>"

    it 'renders style and script tags', ->
      template = ->
        style '''
          body {font-family: sans-serif}
          header, nav, section, footer {display: block}
        '''
        script '''
          alert('hello!');
          console.log('how are you');
        '''
      expecting "<style>body {font-family: sans-serif}\nheader, nav, section, footer {display: block}</style><script>alert('hello!');\nconsole.log('how are you');</script>"

    it 'appends what tag functions return if it is a string', ->
      template = ->
        p ->
          text 'hello.'
          a href: '/', 'this is the hard way'
          '.'
      expecting '<p>hello.<a href="/">this is the hard way</a>.</p>'

    it 'returns rendered output as string with render()', ->
      template = ->
        p "hello.#{render -> a href: '/', 'this is the easy way'}."
      expecting '<p>hello.<a href="/">this is the easy way</a>.</p>'

    it 'renders markup manually with literal', ->
      template = ->
        literal '<var>tag is annoying in coffeescript/javascript</var>'
      expecting "<var>tag is annoying in coffeescript/javascript</var>"

    it 'renders ie conditional comments', ->
      template = ->
        ie 'gte IE8', ->
          link href: 'ie.css', rel: 'stylesheet'
      expecting "<!--[if gte IE8]><link href=\"ie.css\" rel=\"stylesheet\"/><![endif]-->"

    it 'optionally renders formatted output', ->
      engine = new CoffeeTemplates format: true
      template = ->
        doctype 5
        html ->
          head ->
            meta charset: 'utf-8'
            title "#{@title or 'Untitled'} | A completely plausible website"
            meta(name: 'description', content: @description) if @description?
            link rel: 'stylesheet', href: '/css/app.css'
      expecting "<!doctype html>\n<html>\n  <head>\n    <meta charset=\"utf-8\"/>\n    <title>Untitled | A completely plausible website</title>\n    <link rel=\"stylesheet\" href=\"/css/app.css\"/>\n  </head>\n</html>\n"

    it 'renders selector-style #id and .class names', ->
      template = ->
        div '#hamster', ->
          div '.cat', ->
            div '#gerbil.rat', ->
      expecting "<div id=\"hamster\"><div class=\"cat\"><div id=\"gerbil\" class=\"rat\"></div></div></div>"

    it 'renders with compiled coffeescript', ->
      template = ->
        coffeescript ->
          jQuery ->
            alert 'Alerts suck!'
      expecting "<script>return jQuery(function() {\n              return alert('Alerts suck!');\n            });</script>"

    it 'can compile coffeestylesheet ->'

  describe 'Handlebars Clone', ->
    it 'compiles Handlebars/Mustache/string templates to strings', ->
      stache = 'Hello, {{name}}!'
      globals =
        name: 'Mike'
      template_fn = CoffeeTemplates.compile stache
      out = template_fn globals
      assert.equal "Hello, Mike", out

  describe 'NoEngine Template Functions', ->
    it 'compiles Handlebars/Mustache/string templates to stand-alone functions', ->
      stache = 'Hello, {{name}}!'
      template_fn = CoffeeTemplates.compile stache
      assert.equal "function anonymous(g) {\nwith(g||{}){var o=\"\",w=function(f,a){o=\"\";f.apply({},a);return o};return \"Hello, \"+name}\n}", template_fn.toString()

    it 'compiles multiple Handlebars/Mustache/string templates to a single function, WITHOUT helpers', ->
      staches =
        'A': 'Hi, {{name}}!'
        'B': 'Bye, {{name}}!'
      templates_fn = CoffeeTemplates.compileAll staches, omit_helpers: true
      assert.typeOf templates_fn, 'function'
      assert.equal "function anonymous(n,g) {\nvar o=\"\";with(g){var w=function(f,a){o=\"\";f.apply({},a);return o},t={\n\"A\":function(){return \"Hi, \"+name},\n\"B\":function(){return \"Bye, \"+name},\n}};o+=t[n]();return o\n}", templates_fn.toString()
      assert.equal 'Hi, Mike', templates_fn 'A', name: 'Mike'
      assert.equal 'Bye, Mike', templates_fn 'B', name: 'Mike'

    it "templates_fn() won't error when called without options", ->
      templates =
        'test': 'hello'
      templates = CoffeeTemplates.compileAll templates
      out = templates 'test'
      expecting 'hello'

  describe 'All-in-One: CoffeeCup+Handlebars+Helpers', ->
    it 'compiles multiple Handlebars/Mustache/string templates to a single function, WITH helpers (default)', ->
      staches =
        'A': 'Hi, {{name}}!'
        'B': 'Bye, {{name}}!'
      templates_fn = CoffeeTemplates.compileAll staches
      assert.equal "function anonymous(n,g) {\nvar o=\"\";var c={},p=\"partial\",l=\"layout\",content_for=function(s,f){c[s]=f},yields=function(s){var b=c[s];b&&((c[s]=\"\")||b())},z=function(g){var y=o,n;if(g&&g.l&&(n=g.l.pop())){c[\"content\"]=function(){o+=y};o=\"\";g[p](n,g);}},__if=function(v,f){v&&v.length!==0&&f()},each=function(o,f){for (var k in o)o.hasOwnProperty(k)&&f.apply(o[k],[k,o[k]])};g=g||{};g.l=[g[l]];g[l]=function(n){g.l.push(n)};g[p]=function(n,e){e=e||{};for(var k in g){e[k]=e[k]||g[k]};with(e){var w=function(f,a){o=\"\";f.apply({},a);return o},t={\n\"A\":function(){return \"Hi, \"+name},\n\"B\":function(){return \"Bye, \"+name},\n}};o+=t[n]();z(g)};g[p](n,g);z(g);return o\n}", templates_fn.toString()

    it 'can compile {{if logic}}{{/if}} blocks', ->
      templates =
        'A': engine.render ->
          p 'the variable is'
          block 'if v', ->
            p '{{v}}'
      templates_fn = CoffeeTemplates.compileAll templates
      out = templates_fn 'A', v: true
      assert.equal "<p>the variable is</p><p>true</p>", out
      templates =
        'A': engine.render ->
          p 'the variable is'
          block 'if !v', ->
            p '{{v}}'
      templates_fn = CoffeeTemplates.compileAll templates
      out = templates_fn 'A', v: false
      assert.equal "<p>the variable is</p><p>false</p>", out
      templates =
        'A': engine.render ->
          p 'the variable is'
          block '#if typeof v==="undefined"', ->
            p 'not defined'
      templates_fn = CoffeeTemplates.compileAll templates
      out = templates_fn 'A'
      assert.equal "<p>the variable is</p><p>not defined</p>", out

    it 'can compile including other templates using partial()', ->
      templates =
        'A': engine.render ->
          p 'Its fun to'
          partial 'B'
        'B': '<p>use partials to</p>{{partial "C"}}{{/partial}}'
        'C': engine.render ->
          p 'include reusable bits from'
          partial 'D'
        'D': '''
          <p>other templates</p>
          {{partial "E"}}{{/partial}}
          '''
        'E': 'but avoid creating circular dependencies :)'
      assert.deepEqual {"A":"<p>Its fun to</p>{{partial \"B\"}}{{/partial}}","B":"<p>use partials to</p>{{partial \"C\"}}{{/partial}}","C":"<p>include reusable bits from</p>{{partial \"D\"}}{{/partial}}","D":"<p>other templates</p>\n{{partial \"E\"}}{{/partial}}","E":"but avoid creating circular dependencies :)"}, templates
      templates_fn = CoffeeTemplates.compileAll templates
      out = templates_fn 'A'
      assert.equal '<p>Its fun to</p><p>use partials to</p><p>include reusable bits from</p><p>other templates</p>\nbut avoid creating circular dependencies :)', out

    it 'can compile across templates with content_for() and yields()', ->
      templates =
        'throwerCoffee': engine.render ->
          content_for 'head', ->
            script '''
              alert("the coffee versions of content_for(), yields(), partial(), etc. only compile to stache versions");
              '''
          comment "because its better to perform those tasks at the last minute and at the NoEngine function level, anyway."
        'throwerStache': '<p>It\'s nice.</p>{{content_for "foot"}}<script>alert("yep");</script>{{/content_for}}'
        'catcherCoffee': engine.render ->
          html ->
            partial 'throwerCoffee'
            head ->
              meta charset: 'utf-8'
              yields 'head'
            body ->
              partial 'throwerStache'
              partial 'catcherStache'
        'catcherStache': '''
          <footer>
            {{yields "foot"}}{{/yields}}
          </footer>
          '''
      assert.deepEqual {"throwerCoffee":"{{content_for \"head\"}}<script>alert(\"the coffee versions of content_for(), yields(), partial(), etc. only compile to stache versions\");</script>{{/content_for}}<!--because its better to perform those tasks at the last minute and at the NoEngine function level, anyway.-->","throwerStache":"<p>It's nice.</p>{{content_for \"foot\"}}<script>alert(\"yep\");</script>{{/content_for}}","catcherCoffee":"<html>{{partial \"throwerCoffee\"}}{{/partial}}<head><meta charset=\"utf-8\"/>{{yields \"head\"}}{{/yields}}</head><body>{{partial \"throwerStache\"}}{{/partial}}{{partial \"catcherStache\"}}{{/partial}}</body></html>","catcherStache":"<footer>\n  {{yields \"foot\"}}{{/yields}}\n</footer>"}, templates
      templates = CoffeeTemplates.compileAll templates
      out = templates 'catcherCoffee'
      assert.equal "<html><!--because its better to perform those tasks at the last minute and at the NoEngine function level, anyway.--><head><meta charset=\"utf-8\"/><script>alert(\"the coffee versions of content_for(), yields(), partial(), etc. only compile to stache versions\");</script></head><body><p>It's nice.</p><footer>\n  <script>alert(\"yep\");</script>\n</footer></body></html>", out

    it 'can compile with layout named from outside; template_fn(..., layout: "")', ->
      templates =
        'A': engine.render ->
          p '#content', 'Hello'
        'B': engine.render ->
          div '#wrapper', ->
            yields 'content'
          p 'Goodbye'
      templates = CoffeeTemplates.compileAll templates
      out = templates 'A', layout: 'B'
      assert.equal "<div id=\"wrapper\"><p id=\"content\">Hello</p></div><p>Goodbye</p>", out

    it 'can compile with layout named from inside; calling layout()', ->
      templates =
        'A': engine.render ->
          p '#content', 'Hello'
          layout 'B'
        'B': engine.render ->
          div '#wrapper', ->
            yields 'content'
          p 'Goodbye'
      templates = CoffeeTemplates.compileAll templates # defines templates variable
      out = templates 'A'
      assert.equal "<div id=\"wrapper\"><p id=\"content\">Hello</p></div><p>Goodbye</p>", out

    it 'can wrap layouts recursively named inside, outside, or both', ->
      templates =
        'views/A': ->
          div '#A', ->
            text 'hi'
            yields 'content'
            layout 'views/B'
        'views/B': ->
          div '#B', ->
            yields 'content'
            layout 'views/C'
        'views/C': ->
          div '#C', -> yields 'content'
        'layouts/html5': ->
          doctype 5
          html ->
            head ->
              title 'Test'
              yields 'head'
            body ->
              yields 'content'
              yields 'foot'
        'layouts/dashboard': ->
          content_for 'head', ->
            link rel: 'stylesheet', href: 'test.css'
          div '#dashboard', ->
            yields 'content'
          content_for 'foot', ->
            script src: 'test.js'
          layout 'layouts/html5'
      for k of templates
        templates[k] = engine.render templates[k]
      templates_fn = CoffeeTemplates.compileAll templates
      assert.equal "function anonymous(n,g) {\nvar o=\"\";var c={},p=\"partial\",l=\"layout\",content_for=function(s,f){c[s]=f},yields=function(s){var b=c[s];b&&((c[s]=\"\")||b())},z=function(g){var y=o,n;if(g&&g.l&&(n=g.l.pop())){c[\"content\"]=function(){o+=y};o=\"\";g[p](n,g);}},__if=function(v,f){v&&v.length!==0&&f()},each=function(o,f){for (var k in o)o.hasOwnProperty(k)&&f.apply(o[k],[k,o[k]])};g=g||{};g.l=[g[l]];g[l]=function(n){g.l.push(n)};g[p]=function(n,e){e=e||{};for(var k in g){e[k]=e[k]||g[k]};with(e){var w=function(f,a){o=\"\";f.apply({},a);return o},t={\n\"views/A\":function(){return \"<div id=\\\"A\\\">hi\"+w(yields,[\"content\"])+w(layout,[\"views/B\"])+\"</div>\"},\n\"views/B\":function(){return \"<div id=\\\"B\\\">\"+w(yields,[\"content\"])+w(layout,[\"views/C\"])+\"</div>\"},\n\"views/C\":function(){return \"<div id=\\\"C\\\">\"+w(yields,[\"content\"])+\"</div>\"},\n\"layouts/html5\":function(){return \"<!doctype html><html><head><title>Test</title>\"+w(yields,[\"head\"])+\"</head><body>\"+w(yields,[\"content\"])+w(yields,[\"foot\"])+\"</body></html>\"},\n\"layouts/dashboard\":function(){return w(content_for,[\"head\",function(){o+=\"<link rel=\\\"stylesheet\\\" href=\\\"test.css\\\"/>\"}])+\"<div id=\\\"dashboard\\\">\"+w(yields,[\"content\"])+\"</div>\"+w(content_for,[\"foot\",function(){o+=\"<script src=\\\"test.js\\\"><\"+\"/script>\"}])+w(layout,[\"layouts/html5\"])},\n}};o+=t[n]();z(g)};g[p](n,g);z(g);return o\n}", templates_fn.toString()
      out = templates_fn 'views/A', layout: 'layouts/dashboard'
      assert.equal "<!doctype html><html><head><title>Test</title><link rel=\"stylesheet\" href=\"test.css\"/></head><body><div id=\"dashboard\"><div id=\"C\"><div id=\"B\"><div id=\"A\">hi</div></div></div></div><script src=\"test.js\"></script></body></html>", out
