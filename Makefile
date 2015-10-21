
build:
	tools/mdbuild.py
	cp -R media _build
	cp -R resources _build
	
serve:
	cd _build; python -m SimpleHTTPServer

sysdeps:
	sudo apt-get install python-html2text python-markdown python-pip git
	sudo pip install mdx-anchors-away mdx-callouts mdx-foldouts

clean:
	rm -rf _build

.PHONY: build serve sysdeps clean
