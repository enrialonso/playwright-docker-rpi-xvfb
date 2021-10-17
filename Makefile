SHELL=/bin/bash

build:
	docker build --pull --rm -t playwrigright-docker-rpi-xvfb .

run:
	docker run --rm -it --name playwrigright-docker-rpi-xvfb playwrigright-docker-rpi-xvfb