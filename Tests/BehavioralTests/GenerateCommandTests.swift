//
//  GenerateCommandTests.swift
//  
//
//  Created by Eneko Alonso on 11/2/19.
//

import XCTest
import Basic
import System

class GenerateCommandTests: XCTestCase {

    static override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: "Documentation")
//        try? FileManager.default.removeItem(atPath: "Temp")
    }

    func testUnknownBuildAction() throws {
        let result = try generateDocs(parameters: "")
        XCTAssertEqual(result.standardOutput, "")
        XCTAssertTrue(result.standardError.contains("xcodebuild: error: Unknown build action"))
    }

    func testDefaultSourceDocsDemo() throws {
        let result = try generateDocs(parameters: "--spm-module", "SourceDocsDemo")
        XCTAssertTrue(result.standardOutput.hasPrefix("Generating Markdown documentation..."))
        XCTAssertTrue(result.standardOutput.hasSuffix("Done 🎉"))

        let files = [
            "README.md",
            "classes/ACLTestClass.md",
            "classes/Person.md",
            "enums/AnimalKind.md",
            "enums/Baz.md",
            "extensions/AnimalOwner.md",
            "extensions/Dog.md",
            "extensions/Foo.Bar.Baz.md",
            "extensions/Foo.Bar.md",
            "extensions/Foo.md",
            "extensions/Nameable.md",
            "methods/globalMethod(param1:param2:).md",
            "protocols/Aging.md",
            "protocols/Animal.md",
            "protocols/AnimalOwner.md",
            "protocols/Human.md",
            "protocols/LivingThing.md",
            "protocols/Nameable.md",
            "protocols/OwnableAnimal.md",
            "protocols/Pet.md",
            "protocols/Speaker.md",
            "structs/Bar.md",
            "structs/Dog.md",
            "structs/Foo.md"
        ]

        for file in files {
            XCTAssertTrue(FileManager.default.fileExists(atPath: "Documentation/Reference/\(file)"))
        }
    }

    func testREADME() throws {
        let result = try generateDocs(parameters: "--spm-module", "TestSubjects",
                                      "--input-folder", projectRootDirectory.path,
                                      "--output-folder", "Temp/Docs", "-m")
        XCTAssertTrue(result.standardOutput.hasSuffix("Done 🎉"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: "Temp/Docs/TestSubjects/README.md"))
    }

    func testPublicClass() throws {
        try generateDocs(parameters: "--spm-module", "TestSubjects",
                         "--input-folder", projectRootDirectory.path,
                         "--output-folder", "Temp/Docs", "-m")

        let contents = try String(contentsOfFile: "Temp/Docs/TestSubjects/classes/Foo.md")
        XCTAssertTrue(contents.contains("This is a public class named Foo"))
        XCTAssertTrue(contents.contains("public class Foo"))
        XCTAssertTrue(contents.contains("This is a public method on a public class"))
        XCTAssertTrue(contents.contains("public func publicMethod()"))
        XCTAssertFalse(contents.contains("This is an internal method on a public class"))
        XCTAssertFalse(contents.contains("func internalMethod()"))
        XCTAssertFalse(contents.contains("This is a fileprivate method on a public class"))
        XCTAssertFalse(contents.contains("fileprivate func filePrivateMethod()"))
        XCTAssertFalse(contents.contains("This is a private method on a public class"))
        XCTAssertFalse(contents.contains("private func privateMethod()"))
    }

    func testPublicClassWithInternalACL() throws {
        try generateDocs(parameters: "--spm-module", "TestSubjects",
                         "--input-folder", projectRootDirectory.path,
                         "--output-folder", "Temp/Docs", "-m",
                         "--min-acl", "internal")

        let contents = try String(contentsOfFile: "Temp/Docs/TestSubjects/classes/Foo.md")
        XCTAssertTrue(contents.contains("This is a public class named Foo"))
        XCTAssertTrue(contents.contains("public class Foo"))
        XCTAssertTrue(contents.contains("This is a public method on a public class"))
        XCTAssertTrue(contents.contains("public func publicMethod()"))
        XCTAssertTrue(contents.contains("This is an internal method on a public class"))
        XCTAssertTrue(contents.contains("func internalMethod()"))
        XCTAssertFalse(contents.contains("This is a fileprivate method on a public class"))
        XCTAssertFalse(contents.contains("fileprivate func filePrivateMethod()"))
        XCTAssertFalse(contents.contains("This is a private method on a public class"))
        XCTAssertFalse(contents.contains("private func privateMethod()"))
    }

    func testPublicClassWithFilePrivateACL() throws {
        try generateDocs(parameters: "--spm-module", "TestSubjects",
                         "--input-folder", projectRootDirectory.path,
                         "--output-folder", "Temp/Docs", "-m",
                         "--min-acl", "fileprivate")

        let contents = try String(contentsOfFile: "Temp/Docs/TestSubjects/classes/Foo.md")
        XCTAssertTrue(contents.contains("This is a public class named Foo"))
        XCTAssertTrue(contents.contains("public class Foo"))
        XCTAssertTrue(contents.contains("This is a public method on a public class"))
        XCTAssertTrue(contents.contains("public func publicMethod()"))
        XCTAssertTrue(contents.contains("This is an internal method on a public class"))
        XCTAssertTrue(contents.contains("func internalMethod()"))
        XCTAssertTrue(contents.contains("This is a fileprivate method on a public class"))
        XCTAssertTrue(contents.contains("fileprivate func filePrivateMethod()"))
        XCTAssertFalse(contents.contains("This is a private method on a public class"))
        XCTAssertFalse(contents.contains("private func privateMethod()"))
    }

    func testPublicClassWithPrivateACL() throws {
        try generateDocs(parameters: "--spm-module", "TestSubjects",
                         "--input-folder", projectRootDirectory.path,
                         "--output-folder", "Temp/Docs", "-m",
                         "--min-acl", "private")

        let contents = try String(contentsOfFile: "Temp/Docs/TestSubjects/classes/Foo.md")
        XCTAssertTrue(contents.contains("This is a public class named Foo"))
        XCTAssertTrue(contents.contains("public class Foo"))
        XCTAssertTrue(contents.contains("This is a public method on a public class"))
        XCTAssertTrue(contents.contains("public func publicMethod()"))
        XCTAssertTrue(contents.contains("This is an internal method on a public class"))
        XCTAssertTrue(contents.contains("func internalMethod()"))
        XCTAssertTrue(contents.contains("This is a fileprivate method on a public class"))
        XCTAssertTrue(contents.contains("fileprivate func filePrivateMethod()"))
        XCTAssertTrue(contents.contains("This is a private method on a public class"))
        XCTAssertTrue(contents.contains("private func privateMethod()"))
    }

    @discardableResult
    private func generateDocs(parameters: String...) throws -> ProcessResult {
        let params = ["generate"] + parameters
        return try system(command: binaryURL.path, parameters: params, captureOutput: true)
    }
}
