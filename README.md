# Why CoffeeTemplates?

 * 89% smaller download than [CoffeeCup](https://github.com/gradus/coffeecup) + [Handlebars](http://handlebarsjs.com/)--but compiles BOTH with just [257 lines](https://github.com/mikesmullin/coffee-templates/blob/stable/js/coffee-templates.js).
 * thats just [8.7KB](https://raw.github.com/mikesmullin/coffee-templates/stable/js/coffee-templates.js), [5.5KB minified](https://raw.github.com/mikesmullin/coffee-templates/stable/js/coffee-templates.min.js), and [2.6KB gzipped](https://raw.github.com/mikesmullin/coffee-templates/stable/js/coffee-templates.min.js.gz)
 * renders between [22%](http://jsperf.com/coffeecup-vs-coffee-templates) to [80% faster](http://jsperf.com/handlebars-vs-coffee-templates) as tested on node/chrome/v8
 * stand-alone client-side in browser or server-side with Node.js with NO [dependencies](https://github.com/mikesmullin/coffee-templates/blob/stable/package.json)
 * compiling to .js yields one-function-per-template which renders using ONLY string concatenation--the secret to its speed
 * when compiled to .js, no ancillary "engine" library is required to render the template functions. nor is one embedded within the functions.
 * compiling directly from `.coffee` to `.html` or aggregated `templates.js` eliminates a lot of inbetween middleware
 * this means delays, complexities, and potential for double-trees between client and server-side templating engines are eliminated
 * only one language to write; one language to teach/master; one language to rule them all!
 * common functions available to node/js/coffee also available in templates i.e. require() and executed in same scope

Inspired by [coffeecup](https://github.com/gradus/coffeecup),
 and [ck](https://github.com/aeosynth/ck),
 and [mini-handlebars](https://github.com/mikesmullin/mini-handlebars) libraries.

## And now, a Haiku

    5  template languages
    7  are low-level logical
    5  function recursions
    7  the author dared not express
    5  in the host language.
    
    5  syntactic sugar
    7  on low-level languages
    5  ala coffeescript
    7  brings template control to the
    5  speed where it belongs.

## Rendering Coffee to HTML

```coffeescript
# this line is only required within node
CoffeeTemplates = require 'coffee-templates'

# initialize new engine
engine = new CoffeeTemplates format: true

# provide template expression
doctype 5
html ->
  head ->
    meta charset: 'utf-8'
    title "#{@title or 'Untitled'} | A completely plausible website"
    meta(name: 'description', content: @description) if @description?

    link rel: 'stylesheet', href: '/css/app.css'

    style '''
      body {font-family: sans-serif}
      header, nav, section, footer {display: block}
    '''

    comment 'Stylus is not supported but CoffeeStyleshets might be'

    script src: '/js/jquery.js'

    coffeescript ->
      $(document).ready ->
        alert 'Alerts suck!'
  body ->
    header ->
      h1 @title or 'Untitled'

      nav ->
        ul ->
          (li -> a href: '/', -> 'Home') unless @path is '/'
          li -> a href: '/chunky', -> 'Bacon!'
          switch @user.role
            when 'owner', 'admin'
              li -> a href: '/admin', -> 'Secret Stuff'
            when 'vip'
              li -> a href: '/vip', -> 'Exclusive Stuff'
            else
              li -> a href: '/commoners', -> 'Just Stuff'

    div '#myid.myclass.anotherclass', style: 'position: fixed', ->
      p 'Divitis kills! Inline styling too.'

    section ->
      # A helper function you built and included.
      breadcrumb separator: '>', clickable: yes

      h2 "Let's count to 10:"
      p i for i in [1..10]

      # Another hypothetical helper.
      form_to @post, ->
        textbox '#title', label: 'Title:'
        textbox '#author', label: 'Author:'
        submit 'Save'

    footer ->
      # CoffeeScript comments. Not visible in the output document.
      comment 'HTML comments.'
      p 'Bye!'


locals =
  title: 'Best website'

# render coffee template to html
console.log engine.render template, locals
```

## Rendering Coffee to Handlebars
```coffeescript
engine = new CoffeeTemplates format: true, handlebars: true

template = ->
  ul ->
    for company in @companies
      block "each #{company}", ->
        li '{{this}}'

console.log handlebars_template = engine.render template,
  companies: [ 'google', 'yahoo' ]
```

Outputs:

```html
<ul>
  {{#each google}}
    <li>{{this}}</li>
  {{/each}}
  {{#each yahoo}}
    <li>{{this}}</li>
  {{/each}}
</ul>
```

## Improving Handlebars/Mustache
Notice that while regular Mustache/Handlebars templates still compile,
we took the liberty to engineer several improvements to the compiler:

 * {{#blocks arg...}}{{/blocks}} can also be written as {{blocks arg...}}{{/blocks}}
 * however, blocks are required to take at least one argument
 * blocks are just javascript functions
 * any function that implements `function(arg..., cb) { cb(arg...) }` can be executed by a block
 * a function need only be in the window/root scope to be used as a helper; no need to define iterators specially
 * blocks can take any number of arguments
 * blocks can also list callback function arguments within parenthesis ()
 * any character that is valid in a function or variable name is a valid block or block argument name
 * therefore, `<ul>{{$.each companies}}<li>{{this}}</li>{{/$.each}}</ul>` is valid
 * and so is, `<ul>{{jQuery.each people, (key, value)}}<li>{{key}}: {{value}}</li>{{/each}}</ul>`

```coffeescript
engine = new CoffeeTemplates format: true

console.log mustache_template = engine.render ->
  block "each company, (name, data)", ->
    h2 '{{name}}'
    ul ->
      block "each data.people", ->
        li '{{this}}'
```

Outputs:

```html
{{each company, (name, data)}}
  <h2>{{name}}</h2>
  <ul>
    {{each data.people}}
      <li>{{this}}</li>
    {{/each}}
  </ul>
{{/each}}
```

## Rendering Coffee/Handlebars/Mustache to a NoEngine JS Function
```coffeescript
mustache_template = '{{each company, (name, data)}}<h2>{{name}}</h2><ul>{{each data.people}}<li>{{this}}</li>{{/each}}</ul>{{/each}}'

console.log template_fn = CoffeeTemplates.compile mustache_template
```

Outputs:

```javascript
function anonymous(i) {
var o='',w=function(f,a){o='';f.apply(i, a);return o};return w(each,[i.company,function(name,data){o+="<h2>"+name+"</h2><ul>"+w(each,[data.people,function(){o+="<li>"+this+"</li>"}])+"</ul>"}])
}
```

This single function is a completely stand-alone version of your template, and is all that is needed to render the HTML.

Of course, this could also be used to render XML or some other markup, as well.

## Rendering a NoEngine JS Function to HTML
```coffeescript
window.each = (o, cb) ->
  for k of o
    cb.apply o[k], [k, o[k]]
  return

console.log html = template_fn company:
  goog: people: ['Larry Page', 'Sergey Brin']
  msft: people: ['Bill Gates']
```

Outputs:

```html
<h2>goog</h2><ul><li>Larry Page</li><li>Sergey Brin</li></ul><h2>msft</h2><ul><li>Bill Gates</li></ul>
```

## Rendering multiple templates to function
```coffeescript
console.log templates = ''+CoffeeTemplates.compileAll
  'views/users/index': mustache_template
  'views/users/index_by_company':mustache_template
```

Outputs:

```javascript
function anonymous(n,i) {
var o='',w=function(f,a){o='';f.apply(i, a);return o},t={}
t["views/users/index"]=function(){return w(each,[this.company,function(name,data){o+="<h2>"+name+"</h2><ul>"+w(each,[data.people,function(){o+="<li>"+this+"</li>"}])+"</ul>"}])}
t["views/users/index_by_company"]=function(){return w(each,[this.company,function(name,data){o+="<h2>"+name+"</h2><ul>"+w(each,[data.people,function(){o+="<li>"+this+"</li>"}])+"</ul>"}])}
return t[n].call(i)
}
```

From here you would normally save the function in a file like `static/public/assets/templates.js`.

## Further examples

As usual, for the latest examples, review the easy-to-follow [./test/test.coffee](https://github.com/mikesmullin/coffee-templates/blob/stable/test/test.coffee).

Or try it immediately in your browser with [codepen](http://codepen.io/mikesmullin/pen/nIytw).


## Useful Tools

* [Haml to HTML to CoffeeCup to JavaScript to CoffeeScript Converter](http://haml-html-coffeecup-javascript-coffeescript-converter.smullindesign.com/)
