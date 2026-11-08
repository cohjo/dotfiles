PROFILE ?= core

.PHONY: setup configure link editors tools nvim doctor containers-start containers-stop containers-status
setup:
	./scripts/setup-dev.sh "$(PROFILE)"
configure:
	./scripts/configure-dev.sh
link:
	python3 ./scripts/link-dev.py
	./scripts/link-editors.sh
editors: link
tools:
	./scripts/setup-dev.sh "$(PROFILE)"
nvim:
	./scripts/setup-nvim.sh
doctor:
	./scripts/doctor.sh "$(PROFILE)"
containers-start:
	./scripts/containers.sh start
containers-stop:
	./scripts/containers.sh stop
containers-status:
	./scripts/containers.sh status
