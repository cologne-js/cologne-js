
test:
	@CONNECT_ENV=test ./support/expresso/bin/expresso 

index.html: index.js
	dox --title "Connect Form" \
		--ribbon "http://github.com/visionmedia/connect-form" \
		$< > $@

.PHONY: test