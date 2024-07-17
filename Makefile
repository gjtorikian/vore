.PHONY: dist clean

TARGET = $(shell rustc -vV | sed -n 's|host: ||p')
SPIDER_VERSION = 1.99.5

dist:
	@echo $(TARGET)
	cargo install --root exe/$(TARGET) --version $(SPIDER_VERSION) --target $(TARGET) spider_cli; \

clean:
	rm -rf cmd
