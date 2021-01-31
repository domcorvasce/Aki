.PHONY: install

install:
	swift build -c release
	codesign -f --sign ${SIGNING_CERT} .build/release/Aki --entitlements=Aki.entitlements
	cp .build/release/Aki /usr/local/bin/aki
