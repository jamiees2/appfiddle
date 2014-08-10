express = require 'express'
router = express.Router()

fs = require 'fs'
path = require 'path'
git = require 'gift'
YAML = require 'yamljs'
_ = require 'lodash'
_S = require 'underscore.string'
mime = require 'mime'
proc = require 'child_process'
httpProxy = require 'http-proxy'

mime.define({
    'text/x-coffeescript': ['coffee']
    'text/x-scss': ['scss']
});

getDirs = () ->
    files = fs.readdirSync(apps)
    dirs = []

    for file in files
        if file[0] != '.'
            filePath = "#{apps}/#{file}"
            stat = fs.statSync(filePath)

            if stat.isDirectory()
                dirs.push(file)

    return dirs

cloneDir = (dirname, cb) ->
	git.clone "git@bitbucket.org:verdandi/loki.git", "#{apps}/#{dirname}", (err, repo) ->
  		console.log repo
  		cb()
apps = path.join(__dirname,'..','apps')

# GET home page.
router.get '/', (req, res) ->
  	res.render 'index', { title: "stuff", apps: getDirs() }

router.get '/create/:name', (req, res) ->
	cloneDir req.params.name, ->
		# TODO: Initialize all config files (underscore templates?)
  		res.redirect '/'

router.get '/config/:app', (req, res) ->
	configDir = path.join(apps,req.params.app,"config")
	configFiles = _.filter fs.readdirSync(configDir), (item) -> 
		item.slice(-4) is ".yml"
	configuration = {}
	configFiles.forEach (item) ->
		configuration[item.slice(0,-4)] = YAML.parse(fs.readFileSync(path.join(configDir, item)).toString())
	console.log configuration
	res.render 'config', { app: req.params.app, config: configuration, _S: _S }
	# res.json configuration

router.post '/config/:app/:file', (req, res) ->
	configFile = path.join(apps,req.params.app,"config",req.params.file + ".yml")
	data = YAML.stringify(req.body)
	fs.writeFile configFile, data, ->
		res.redirect 'back'

router.get '/edit/:app', (req,res) ->
	assetDir = path.join(apps,req.params.app,"assets")
	viewDir = path.join(apps,req.params.app,"views")

	jsFiles = _.filter fs.readdirSync(path.join(assetDir,"javascripts")), (item) ->
		path.extname(item) in [".coffee", ".js"]

	cssFiles = _.filter fs.readdirSync(path.join(assetDir,"stylesheets")), (item) ->
		path.extname(item) in [".scss", ".css"]

	htmlFiles = _.filter fs.readdirSync(viewDir), (item) ->
		path.extname(item) in [".slim", ".html", ".erb", ".haml"]

	return res.json
		html: htmlFiles
		js: jsFiles
		css: cssFiles
router.get '/edit/:app/:type/:file', (req,res) ->
	assetDir = path.join(apps,req.params.app,"assets")
	viewDir = path.join(apps,req.params.app,"views")
	file = null
	if req.params.type in ["javascripts", "stylesheets"]
		file = fs.readFileSync(path.join(assetDir,req.params.type,req.params.file))
	else if req.params.type is "stylesheets"
		file = fs.readFileSync(path.join(viewDir,req.params.type,req.params.file))

	return res.render 'editor', 
		data: file
		mime: mime.lookup(req.params.file)

router.get '/start/:app', (req,res) ->
	res.json(true)

appServers = {}
proxy = httpProxy.createProxyServer()
router.get '/app/:app/*', (req, res) ->
	app = req.params.app
	req.url = req.url.substring(req.url.indexOf("/",5))
	unless appServers[app]?
		port = _.random(27000,29000)
		shutdown = -> 
			appServers[app].process.kill('SIGINT')
			delete appServers[app]
		server = appServers[app] = {
			process: proc.spawn 'bundle', ['exec', 'rackup', '-p', port], {cwd: path.join(apps,app)}
			port: port
			shutdown: shutdown
			# timeout: setTimeout shutdown, 5000
		}
		# server.process.stdout.on 'data', (data) ->
		# 	console.log data
		# server.process.stderr.on 'data', (data) ->
		# 	console.log data
		process.on 'exit', shutdown
		return setTimeout(->
			responseProxy(req, res, server)
		, 2000)
	else
		responseProxy req, res, appServers[app]
responseProxy = (req, res, server) ->
	# clearTimeout server.timeout
	# server.timeout = setTimeout server.shutdown, 5000
	console.log server.port
	# res.json true
	proxy.web(req, res, { target: 'http://localhost:' + server.port })


module.exports = router
