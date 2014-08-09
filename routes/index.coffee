express = require 'express'
router = express.Router()

fs = require 'fs'
path = require 'path'
git = require 'gift'
YAML = require 'yamljs'
_ = require 'lodash'

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
	res.render 'config', { app: req.params.app, config: configuration }
	# res.json configuration

router.post '/config/:app/:file', (req, res) ->
	configFile = path.join(apps,req.params.app,"config",req.params.file + ".yml")
	data = YAML.stringify(req.body)
	fs.writeFile configFile, data, ->
		res.redirect 'back'
	# configFiles = _.filter fs.readdirSync(configDir), (item) -> 
	# 	item.slice(-4) is ".yml"
	# configuration = {}
	# configFiles.forEach (item) ->
	# 	configuration[item.slice(0,-4)] = require(path.join(configDir, item))
	# res.render 'config', { app: req.params.app, config: configuration }


module.exports = router
