require 'xcodeproj'
require 'fileutils'

PROJECT_ROOT    = File.expand_path(File.dirname(__FILE__))
APP_DIR         = File.join(PROJECT_ROOT, 'TrackerIOS')
PROJECT_PATH    = File.join(PROJECT_ROOT, 'TrackerIOS.xcodeproj')
BUNDLE_ID       = 'com.tracker.busjourney.ios'
DEPLOY_TARGET   = '16.0'

# Remove stale project
FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)

# ── Build configurations ────────────────────────────────────────────────────
['Debug', 'Release'].each do |name|
  xcconfig_path = File.join(PROJECT_ROOT, "#{name}.xcconfig")
  ref = project.main_group.new_reference(xcconfig_path)
  ref.source_tree = '<absolute>'
  project.build_configuration_list[name].base_configuration_reference = ref
  project.build_configuration_list[name].build_settings.merge!(
    'IPHONEOS_DEPLOYMENT_TARGET' => DEPLOY_TARGET,
    'SWIFT_VERSION' => '5.8'
  )
end

# ── App target ───────────────────────────────────────────────────────────────
app_target = project.new_target(:application, 'TrackerIOS', :ios, DEPLOY_TARGET)

['Debug', 'Release'].each do |name|
  xcconfig_path = File.join(PROJECT_ROOT, "#{name}.xcconfig")
  ref = project.main_group.files.find { |f| f.real_path.to_s == xcconfig_path }
  ref ||= project.main_group.new_reference(xcconfig_path).tap { |r| r.source_tree = '<absolute>' }
  cfg = app_target.build_configuration_list[name]
  cfg.base_configuration_reference = ref
  cfg.build_settings.merge!(
    'PRODUCT_BUNDLE_IDENTIFIER'                => BUNDLE_ID,
    'SWIFT_VERSION'                            => '5.8',
    'IPHONEOS_DEPLOYMENT_TARGET'               => DEPLOY_TARGET,
    'INFOPLIST_FILE'                           => 'TrackerIOS/Resources/Info.plist',
    'TARGETED_DEVICE_FAMILY'                   => '1',
    'ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'    => 'YES',
    'ENABLE_PREVIEWS'                          => 'YES',
    'SWIFT_EMIT_LOC_STRINGS'                   => 'YES',
    'ASSETCATALOG_COMPILER_APPICON_NAME'       => 'AppIcon',
    'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME' => 'AccentColor',
    'CODE_SIGN_STYLE'                          => 'Automatic',
    'DEVELOPMENT_TEAM'                         => '',
  )
end

# ── Collect all Swift source files ───────────────────────────────────────────
swift_files = Dir.glob(File.join(APP_DIR, '**', '*.swift'))

swift_files.each do |abs_path|
  ref = project.main_group.new_reference(abs_path)
  ref.source_tree = '<absolute>'
  app_target.source_build_phase.add_file_reference(ref)
end

# ── Resources ────────────────────────────────────────────────────────────────
assets_path = File.join(APP_DIR, 'Resources', 'Assets.xcassets')
assets_ref = project.main_group.new_reference(assets_path)
assets_ref.source_tree = '<absolute>'
app_target.resources_build_phase.add_file_reference(assets_ref)

# ── Frameworks ────────────────────────────────────────────────────────────────
mapkit_ref = project.frameworks_group.new_reference('System/Library/Frameworks/MapKit.framework')
mapkit_ref.source_tree = 'SDKROOT'
app_target.frameworks_build_phase.add_file_reference(mapkit_ref)

# ── Tests target ─────────────────────────────────────────────────────────────
test_dir = File.join(PROJECT_ROOT, 'TrackerIOSTests')
Dir.mkdir(test_dir) unless Dir.exist?(test_dir)

test_file = File.join(test_dir, 'TrackerIOSTests.swift')
File.write(test_file, <<~SWIFT) unless File.exist?(test_file)
  import XCTest
  @testable import TrackerIOS

  final class TrackerIOSTests: XCTestCase {
      func testSearchUseCaseSkipsShortQuery() async {
          let repo = MockJourneyRepository()
          let useCase = SearchStopPointsUseCase(repository: repo)
          let result = await useCase.execute(query: "a")
          if case .success(let stops) = result {
              XCTAssertTrue(stops.isEmpty)
          } else {
              XCTFail("Expected success with empty list")
          }
      }
  }

  private final class MockJourneyRepository: JourneyRepository {
      func searchStopPoints(query: String) async -> Result<[StopPoint], Error> { .success([]) }
      func planJourney(from: String, to: String) async -> JourneyPlanResult { .noResults("mock") }
  }
SWIFT

test_target = project.new_target(:unit_test_bundle, 'TrackerIOSTests', :ios, DEPLOY_TARGET)
test_ref = project.main_group.new_reference(test_file)
test_ref.source_tree = '<absolute>'
test_target.source_build_phase.add_file_reference(test_ref)
test_target.add_dependency(app_target)

['Debug', 'Release'].each do |name|
  cfg = test_target.build_configuration_list[name]
  cfg.build_settings.merge!(
    'SWIFT_VERSION'                => '5.8',
    'IPHONEOS_DEPLOYMENT_TARGET'   => DEPLOY_TARGET,
    'PRODUCT_BUNDLE_IDENTIFIER'    => "#{BUNDLE_ID}.tests",
    'TEST_HOST' => '$(BUILT_PRODUCTS_DIR)/TrackerIOS.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/TrackerIOS',
    'BUNDLE_LOADER' => '$(TEST_HOST)',
  )
end

project.save
puts "✅  TrackerIOS.xcodeproj generated (#{swift_files.count} Swift files)"
