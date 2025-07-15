.PHONY: help test lint docs generate clean

help:
	@echo "Available commands:"
	@echo "  make test       - Run unit tests"
	@echo "  make test-all   - Run all tests including integration"
	@echo "  make lint       - Run RuboCop linting"
	@echo "  make docs       - Build documentation"
	@echo "  make generate   - Generate Ruby client from OpenAPI spec"
	@echo "  make clean      - Clean generated files"

test:
	bundle exec rake test:unit

test-all:
	bundle exec rake test:all

lint:
	bundle exec rubocop

docs:
	npm run docs:build
	bundle exec yard doc

docs-serve:
	npm run docs:dev

generate:
	./scripts/generate_client.sh

clean:
	rm -rf coverage/ docs/api/ docs/api.html _site/ site/