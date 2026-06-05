#!/usr/bin/env python3
"""Generate a valid Xcode project.pbxproj for SalariaSales."""

from __future__ import annotations

import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = "SalariaSales"

_counter = 0


def uid() -> str:
    global _counter
    _counter += 1
    # 24 uppercase hex characters; first character is never '0'.
    value = f"B1{_counter:022X}"
    assert len(value) == 24
    return value


def swift_files(folder: str) -> list[str]:
    base = ROOT / folder
    return sorted(str(p.relative_to(ROOT)).replace("\\", "/") for p in base.rglob("*.swift"))


def rel_path(full: str, root_folder: str) -> str:
    prefix = f"{root_folder}/"
    return full[len(prefix) :] if full.startswith(prefix) else os.path.basename(full)


def main() -> None:
    app_swift = swift_files(PROJECT)
    test_swift = swift_files(f"{PROJECT}Tests")
    resources = [
        f"{PROJECT}/Resources/jobs_fallback.json",
        f"{PROJECT}/Resources/Assets.xcassets",
    ]
    info_plist = f"{PROJECT}/Info.plist"

    ids = {name: uid() for name in [
        "project", "app_target", "test_target", "app_product", "test_product",
        "app_sources", "test_sources", "app_resources", "app_fw", "test_fw",
        "root", "products", "app_group", "test_group", "proxy", "test_dep",
        "proj_cfgs", "app_cfgs", "test_cfgs",
        "dbg_proj", "rel_proj", "dbg_app", "rel_app", "dbg_test", "rel_test",
    ]}

    file_ref = {path: uid() for path in app_swift + test_swift + resources + [info_plist]}
    build_file = {path: uid() for path in app_swift + test_swift}
    res_json_bf = uid()
    res_assets_bf = uid()

    out: list[str] = []

    def add(line: str = "") -> None:
        out.append(line)

    add("// !$*UTF8*$!")
    add("{")
    add("\tarchiveVersion = 1;")
    add("\tclasses = {")
    add("\t};")
    add("\tobjectVersion = 54;")
    add("\tobjects = {")

    add("\n/* Begin PBXBuildFile section */")
    for path in app_swift:
        name = os.path.basename(path)
        add(
            f"\t\t{build_file[path]} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref[path]} /* {name} */; }};"
        )
    for path in test_swift:
        name = os.path.basename(path)
        add(
            f"\t\t{build_file[path]} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref[path]} /* {name} */; }};"
        )
    add(
        f"\t\t{res_json_bf} /* jobs_fallback.json in Resources */ = {{isa = PBXBuildFile; fileRef = {file_ref[resources[0]]} /* jobs_fallback.json */; }};"
    )
    add(
        f"\t\t{res_assets_bf} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {file_ref[resources[1]]} /* Assets.xcassets */; }};"
    )
    add("/* End PBXBuildFile section */")

    add("\n/* Begin PBXContainerItemProxy section */")
    add(
        f"\t\t{ids['proxy']} /* PBXContainerItemProxy */ = {{isa = PBXContainerItemProxy; containerPortal = {ids['project']} /* Project object */; proxyType = 1; remoteGlobalIDString = {ids['app_target']}; remoteInfo = {PROJECT}; }};"
    )
    add("/* End PBXContainerItemProxy section */")

    add("\n/* Begin PBXFileReference section */")
    add(
        f"\t\t{ids['app_product']} /* {PROJECT}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {PROJECT}.app; sourceTree = BUILT_PRODUCTS_DIR; }};"
    )
    add(
        f"\t\t{ids['test_product']} /* {PROJECT}Tests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = {PROJECT}Tests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};"
    )
    for path in app_swift:
        name = os.path.basename(path)
        add(
            f"\t\t{file_ref[path]} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {rel_path(path, PROJECT)}; sourceTree = \"<group>\"; }};"
        )
    for path in test_swift:
        name = os.path.basename(path)
        add(
            f"\t\t{file_ref[path]} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {rel_path(path, f'{PROJECT}Tests')}; sourceTree = \"<group>\"; }};"
        )
    add(
        f"\t\t{file_ref[resources[0]]} /* jobs_fallback.json */ = {{isa = PBXFileReference; lastKnownFileType = text.json; path = Resources/jobs_fallback.json; sourceTree = \"<group>\"; }};"
    )
    add(
        f"\t\t{file_ref[resources[1]]} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Resources/Assets.xcassets; sourceTree = \"<group>\"; }};"
    )
    add(
        f"\t\t{file_ref[info_plist]} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};"
    )
    add("/* End PBXFileReference section */")

    add("\n/* Begin PBXFrameworksBuildPhase section */")
    for key in ("app_fw", "test_fw"):
        add(f"\t\t{ids[key]} /* Frameworks */ = {{")
        add("\t\t\tisa = PBXFrameworksBuildPhase;")
        add("\t\t\tbuildActionMask = 2147483647;")
        add("\t\t\tfiles = (")
        add("\t\t\t);")
        add("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
        add("\t\t};")
    add("/* End PBXFrameworksBuildPhase section */")

    add("\n/* Begin PBXGroup section */")
    add(f"\t\t{ids['root']} = {{")
    add("\t\t\tisa = PBXGroup;")
    add("\t\t\tchildren = (")
    add(f"\t\t\t\t{ids['app_group']} /* {PROJECT} */,")
    add(f"\t\t\t\t{ids['test_group']} /* {PROJECT}Tests */,")
    add(f"\t\t\t\t{ids['products']} /* Products */,")
    add("\t\t\t);")
    add("\t\t\tsourceTree = \"<group>\";")
    add("\t\t};")

    add(f"\t\t{ids['products']} /* Products */ = {{")
    add("\t\t\tisa = PBXGroup;")
    add("\t\t\tchildren = (")
    add(f"\t\t\t\t{ids['app_product']} /* {PROJECT}.app */,")
    add(f"\t\t\t\t{ids['test_product']} /* {PROJECT}Tests.xctest */,")
    add("\t\t\t);")
    add("\t\t\tname = Products;")
    add("\t\t\tsourceTree = \"<group>\";")
    add("\t\t};")

    add(f"\t\t{ids['app_group']} /* {PROJECT} */ = {{")
    add("\t\t\tisa = PBXGroup;")
    add("\t\t\tchildren = (")
    for path in app_swift + resources + [info_plist]:
        add(f"\t\t\t\t{file_ref[path]} /* {os.path.basename(path)} */,")
    add("\t\t\t);")
    add(f"\t\t\tpath = {PROJECT};")
    add("\t\t\tsourceTree = \"<group>\";")
    add("\t\t};")

    add(f"\t\t{ids['test_group']} /* {PROJECT}Tests */ = {{")
    add("\t\t\tisa = PBXGroup;")
    add("\t\t\tchildren = (")
    for path in test_swift:
        add(f"\t\t\t\t{file_ref[path]} /* {os.path.basename(path)} */,")
    add("\t\t\t);")
    add(f"\t\t\tpath = {PROJECT}Tests;")
    add("\t\t\tsourceTree = \"<group>\";")
    add("\t\t};")
    add("/* End PBXGroup section */")

    add("\n/* Begin PBXNativeTarget section */")
    add(f"\t\t{ids['app_target']} /* {PROJECT} */ = {{")
    add("\t\t\tisa = PBXNativeTarget;")
    add(f"\t\t\tbuildConfigurationList = {ids['app_cfgs']} /* Build configuration list for PBXNativeTarget \"{PROJECT}\" */;")
    add("\t\t\tbuildPhases = (")
    add(f"\t\t\t\t{ids['app_sources']} /* Sources */,")
    add(f"\t\t\t\t{ids['app_fw']} /* Frameworks */,")
    add(f"\t\t\t\t{ids['app_resources']} /* Resources */,")
    add("\t\t\t);")
    add("\t\t\tbuildRules = (")
    add("\t\t\t);")
    add("\t\t\tdependencies = (")
    add("\t\t\t);")
    add(f"\t\t\tname = {PROJECT};")
    add(f"\t\t\tproductName = {PROJECT};")
    add(f"\t\t\tproductReference = {ids['app_product']} /* {PROJECT}.app */;")
    add('\t\t\tproductType = "com.apple.product-type.application";')
    add("\t\t};")

    add(f"\t\t{ids['test_target']} /* {PROJECT}Tests */ = {{")
    add("\t\t\tisa = PBXNativeTarget;")
    add(
        f"\t\t\tbuildConfigurationList = {ids['test_cfgs']} /* Build configuration list for PBXNativeTarget \"{PROJECT}Tests\" */;"
    )
    add("\t\t\tbuildPhases = (")
    add(f"\t\t\t\t{ids['test_sources']} /* Sources */,")
    add(f"\t\t\t\t{ids['test_fw']} /* Frameworks */,")
    add("\t\t\t);")
    add("\t\t\tbuildRules = (")
    add("\t\t\t);")
    add("\t\t\tdependencies = (")
    add(f"\t\t\t\t{ids['test_dep']} /* PBXTargetDependency */,")
    add("\t\t\t);")
    add(f"\t\t\tname = {PROJECT}Tests;")
    add(f"\t\t\tproductName = {PROJECT}Tests;")
    add(f"\t\t\tproductReference = {ids['test_product']} /* {PROJECT}Tests.xctest */;")
    add('\t\t\tproductType = "com.apple.product-type.bundle.unit-test";')
    add("\t\t};")
    add("/* End PBXNativeTarget section */")

    add("\n/* Begin PBXProject section */")
    add(f"\t\t{ids['project']} /* Project object */ = {{")
    add("\t\t\tisa = PBXProject;")
    add("\t\t\tattributes = {")
    add("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
    add("\t\t\t\tLastSwiftUpdateCheck = 1500;")
    add("\t\t\t\tLastUpgradeCheck = 1500;")
    add("\t\t\t\tTargetAttributes = {")
    add(f"\t\t\t\t\t{ids['app_target']} = {{")
    add("\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;")
    add("\t\t\t\t\t};")
    add(f"\t\t\t\t\t{ids['test_target']} = {{")
    add("\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;")
    add(f"\t\t\t\t\t\tTestTargetID = {ids['app_target']};")
    add("\t\t\t\t\t};")
    add("\t\t\t\t};")
    add("\t\t\t};")
    add(f"\t\t\tbuildConfigurationList = {ids['proj_cfgs']} /* Build configuration list for PBXProject \"{PROJECT}\" */;")
    add('\t\t\tcompatibilityVersion = "Xcode 14.0";')
    add("\t\t\tdevelopmentRegion = en;")
    add("\t\t\thasScannedForEncodings = 0;")
    add("\t\t\tknownRegions = (")
    add("\t\t\t\ten,")
    add("\t\t\t\tBase,")
    add("\t\t\t);")
    add(f"\t\t\tmainGroup = {ids['root']};")
    add(f"\t\t\tproductRefGroup = {ids['products']} /* Products */;")
    add('\t\t\tprojectDirPath = "";')
    add('\t\t\tprojectRoot = "";')
    add("\t\t\ttargets = (")
    add(f"\t\t\t\t{ids['app_target']} /* {PROJECT} */,")
    add(f"\t\t\t\t{ids['test_target']} /* {PROJECT}Tests */,")
    add("\t\t\t);")
    add("\t\t};")
    add("/* End PBXProject section */")

    add("\n/* Begin PBXResourcesBuildPhase section */")
    add(f"\t\t{ids['app_resources']} /* Resources */ = {{")
    add("\t\t\tisa = PBXResourcesBuildPhase;")
    add("\t\t\tbuildActionMask = 2147483647;")
    add("\t\t\tfiles = (")
    add(f"\t\t\t\t{res_json_bf} /* jobs_fallback.json in Resources */,")
    add(f"\t\t\t\t{res_assets_bf} /* Assets.xcassets in Resources */,")
    add("\t\t\t);")
    add("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    add("\t\t};")
    add("/* End PBXResourcesBuildPhase section */")

    add("\n/* Begin PBXSourcesBuildPhase section */")
    add(f"\t\t{ids['app_sources']} /* Sources */ = {{")
    add("\t\t\tisa = PBXSourcesBuildPhase;")
    add("\t\t\tbuildActionMask = 2147483647;")
    add("\t\t\tfiles = (")
    for path in app_swift:
        add(f"\t\t\t\t{build_file[path]} /* {os.path.basename(path)} in Sources */,")
    add("\t\t\t);")
    add("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    add("\t\t};")

    add(f"\t\t{ids['test_sources']} /* Sources */ = {{")
    add("\t\t\tisa = PBXSourcesBuildPhase;")
    add("\t\t\tbuildActionMask = 2147483647;")
    add("\t\t\tfiles = (")
    for path in test_swift:
        add(f"\t\t\t\t{build_file[path]} /* {os.path.basename(path)} in Sources */,")
    add("\t\t\t);")
    add("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    add("\t\t};")
    add("/* End PBXSourcesBuildPhase section */")

    add("\n/* Begin PBXTargetDependency section */")
    add(
        f"\t\t{ids['test_dep']} /* PBXTargetDependency */ = {{isa = PBXTargetDependency; target = {ids['app_target']} /* {PROJECT} */; targetProxy = {ids['proxy']} /* PBXContainerItemProxy */; }};"
    )
    add("/* End PBXTargetDependency section */")

    def config(cid: str, name: str, settings: dict[str, str]) -> None:
        add(f"\t\t{cid} /* {name} */ = {{")
        add("\t\t\tisa = XCBuildConfiguration;")
        add("\t\t\tbuildSettings = {")
        for key, value in settings.items():
            add(f"\t\t\t\t{key} = {value};")
        add("\t\t\t};")
        add(f"\t\t\tname = {name};")
        add("\t\t};")

    add("\n/* Begin XCBuildConfiguration section */")
    config(ids["dbg_proj"], "Debug", {
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "CLANG_ENABLE_MODULES": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "COPY_PHASE_STRIP": "NO",
        "DEBUG_INFORMATION_FORMAT": "dwarf",
        "ENABLE_TESTABILITY": "YES",
        "GCC_DYNAMIC_NO_PIC": "NO",
        "GCC_OPTIMIZATION_LEVEL": "0",
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
        "ONLY_ACTIVE_ARCH": "YES",
        "SDKROOT": "iphoneos",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
        "SWIFT_OPTIMIZATION_LEVEL": '"-Onone"',
        "SWIFT_VERSION": "5.0",
    })
    config(ids["rel_proj"], "Release", {
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "CLANG_ENABLE_MODULES": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "COPY_PHASE_STRIP": "NO",
        "DEBUG_INFORMATION_FORMAT": '"dwarf-with-dsym"',
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
        "SDKROOT": "iphoneos",
        "SWIFT_COMPILATION_MODE": "wholemodule",
        "SWIFT_VERSION": "5.0",
        "VALIDATE_PRODUCT": "YES",
    })
    app_settings = {
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "GENERATE_INFOPLIST_FILE": "NO",
        "INFOPLIST_FILE": f"{PROJECT}/Info.plist",
        "LD_RUNPATH_SEARCH_PATHS": (
            "$(inherited) @executable_path/Frameworks"
        ),
        "MARKETING_VERSION": "1.0",
        "PRODUCT_BUNDLE_IDENTIFIER": "com.salaria.jobs",
        "PRODUCT_NAME": "$(TARGET_NAME)",
        "SWIFT_EMIT_LOC_STRINGS": "YES",
        "SWIFT_VERSION": "5.0",
        "TARGETED_DEVICE_FAMILY": "1",
    }
    # Quote settings that contain spaces
    app_settings["LD_RUNPATH_SEARCH_PATHS"] = '"$(inherited) @executable_path/Frameworks"'
    test_settings = {
        "BUNDLE_LOADER": "$(TEST_HOST)",
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "GENERATE_INFOPLIST_FILE": "YES",
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
        "MARKETING_VERSION": "1.0",
        "PRODUCT_BUNDLE_IDENTIFIER": "com.salaria.jobs.tests",
        "PRODUCT_NAME": "$(TARGET_NAME)",
        "SWIFT_EMIT_LOC_STRINGS": "NO",
        "SWIFT_VERSION": "5.0",
        "TARGETED_DEVICE_FAMILY": "1",
        "TEST_HOST": (
            f'"$(BUILT_PRODUCTS_DIR)/{PROJECT}.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/{PROJECT}"'
        ),
    }
    config(ids["dbg_app"], "Debug", app_settings)
    config(ids["rel_app"], "Release", app_settings)
    config(ids["dbg_test"], "Debug", test_settings)
    config(ids["rel_test"], "Release", test_settings)
    add("/* End XCBuildConfiguration section */")

    add("\n/* Begin XCConfigurationList section */")
    for list_id, configs in (
        (ids["proj_cfgs"], [(ids["dbg_proj"], "Debug"), (ids["rel_proj"], "Release")]),
        (ids["app_cfgs"], [(ids["dbg_app"], "Debug"), (ids["rel_app"], "Release")]),
        (ids["test_cfgs"], [(ids["dbg_test"], "Debug"), (ids["rel_test"], "Release")]),
    ):
        add(f"\t\t{list_id} /* Build configuration list for PBXProject \"{PROJECT}\" */ = {{")
        add("\t\t\tisa = XCConfigurationList;")
        add("\t\t\tbuildConfigurations = (")
        for cid, cname in configs:
            add(f"\t\t\t\t{cid} /* {cname} */,")
        add("\t\t\t);")
        add("\t\t\tdefaultConfigurationIsVisible = 0;")
        add("\t\t\tdefaultConfigurationName = Release;")
        add("\t\t};")
    add("/* End XCConfigurationList section */")

    add("\t};")
    add(f"\trootObject = {ids['project']} /* Project object */;")
    add("}")

    xcodeproj = ROOT / f"{PROJECT}.xcodeproj"
    (xcodeproj / "project.pbxproj").write_text("\n".join(out) + "\n", encoding="utf-8")

    scheme_path = xcodeproj / "xcshareddata" / "xcschemes" / f"{PROJECT}.xcscheme"
    scheme_path.parent.mkdir(parents=True, exist_ok=True)
    scheme_path.write_text(
        f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{ids['app_target']}"
               BuildableName = "{PROJECT}.app"
               BlueprintName = "{PROJECT}"
               ReferencedContainer = "container:{PROJECT}.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      codeCoverageEnabled = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{ids['test_target']}"
               BuildableName = "{PROJECT}Tests.xctest"
               BlueprintName = "{PROJECT}Tests"
               ReferencedContainer = "container:{PROJECT}.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{ids['app_target']}"
            BuildableName = "{PROJECT}.app"
            BlueprintName = "{PROJECT}"
            ReferencedContainer = "container:{PROJECT}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{ids['app_target']}"
            BuildableName = "{PROJECT}.app"
            BlueprintName = "{PROJECT}"
            ReferencedContainer = "container:{PROJECT}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
""",
        encoding="utf-8",
    )

    workspace = xcodeproj / "project.xcworkspace" / "contents.xcworkspacedata"
    workspace.parent.mkdir(parents=True, exist_ok=True)
    workspace.write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<Workspace\n   version = "1.0">\n'
        '   <FileRef\n      location = "self:">\n   </FileRef>\n'
        '</Workspace>\n',
        encoding="utf-8",
    )

    # Validate unique object definitions (references may repeat IDs).
    import re

    text = (xcodeproj / "project.pbxproj").read_text()
    definitions = re.findall(r"^\t\t(B1[0-9A-F]{22}) /\*", text, re.MULTILINE)
    if len(definitions) != len(set(definitions)):
        raise SystemExit("Duplicate object definitions in project.pbxproj")
    if re.search(r"^\t\t0[0-9A-F]{23} /\*", text, re.MULTILINE):
        raise SystemExit("Object ID starts with 0 (invalid for Xcode parser)")

    print(f"Wrote {xcodeproj / 'project.pbxproj'} ({len(definitions)} objects)")
    print(f"App target: {ids['app_target']}")
    print(f"Test target: {ids['test_target']}")


if __name__ == "__main__":
    main()
