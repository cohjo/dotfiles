DOTFILES := $(CURDIR)

.PHONY: link editors tools nvim setup doctor

link:
	./scripts/link-editors.sh

editors: link

tools:
	./scripts/install-language-tools.sh

nvim:
	./scripts/setup-nvim.sh

setup: tools

doctor:
	nvim --version | head -n 1
	nvim --headless "+lua print(vim.fn.stdpath('config'))" +qa
