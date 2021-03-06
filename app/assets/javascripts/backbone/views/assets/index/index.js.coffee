#=require "backbone/models/asset"
#=require "./sidebar"
#=require "./panel"
#=require "./show"
#=require "fileuploader"
#=require "ace/ace"
#=require "ace/theme-clouds"
#=require "ace/mode-html"
#=require "ace/mode-css"
#=require "ace/mode-javascript"
App.Views.Asset.Index.Index = Backbone.View.extend
  el: '#main'

  initialize: ->
    self = this
    @templateEditor()
    @render()

  render: ->
    self = this
    @assets = {}
    _(@options.data).each (assets, name) ->
      collection = new App.Collections.Assets assets
      self.assets[name] = collection
      collection.each (asset) -> new App.Views.Asset.Index.Show model: asset, name: name
      collection.bind 'add', (asset) -> new App.Views.Asset.Index.Show(model: asset, name: name).show()
    new App.Views.Asset.Index.Sidebar(data: @options.data, assets: @assets)
    new App.Views.Asset.Index.Panel()

  templateEditor: ->
    window.TemplateEditor =
      editor: null
      current: null # The current theme file entity object editing
      html_mode: require("ace/mode/html").Mode
      css_mode: require("ace/mode/css").Mode
      js_mode: require("ace/mode/javascript").Mode
      UndoManager: require("ace/undomanager").UndoManager
      EditSession: require("ace/edit_session").EditSession
      RequiredFiles: required_files
      text_extensions: ['wmls','csv','vsc','qxb','qxt','kml','rb','ltx','ps','sl','cc','qxd','fsc','shar','txt','coffee','cmd','php','liquid','xpm','t','js','imagemap','csh','roff','html','htmlx','texinfo','cpp','htm','bat','vcs','atc','smi','c','phtml','py','pht','xslt','rtx','ai','tex','hqx','ccc','dat','xmt_txt','svg','xlsx','dtd','troff','eps','hpp','xps','qwt','shtml','atom','h','xhtml','xsl','qxl','man','vcf','x_t','hlp','pl','rhtml','qwd','xbm','wml','eol','sgm','json','rst','htc','etx','hh','xml','m4u','yaml','eml','kmz','tcl','yml','texi','asc','acutc','rbw','smil','rdf','imap','sh','mxu','tr','htx','css','si','jad','latex','tsv']
      image_extensions: [ 'jpg', 'gif', 'png', 'jpeg' ]
