all:
	make run
deploy:
	git push heroku master
run:
	coffee app.coffee
css:	
	compass compile
logs:
	heroku addons:open loggly
