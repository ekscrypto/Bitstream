import PackageDescription

let package = Package(
		name: "Bitstream",
		dependencies: [
			.Package(url: "https://github.com/ekscrypto/Bitter", "2.0.7")
		]
)
