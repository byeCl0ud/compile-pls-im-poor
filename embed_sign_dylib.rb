require 'xcodeproj'

project_path = 'src/MeloNX/MeloNX.xcodeproj'
dylib_name = 'Ryujinx.Headless.SDL2.dylib'
target_name = 'MeloNX'

project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == target_name }

# Find the file reference
dylib_file = project.files.find { |f| f.path == dylib_name }

# Add it to the "Embed Frameworks" phase
embed_phase = target.copy_files_build_phases.find do |phase|
  phase.name == 'Embed Frameworks'
end

unless embed_phase
  embed_phase = target.new_copy_files_build_phase('Embed Frameworks')
  embed_phase.symbol_dst_subfolder_spec = :frameworks
end

build_file = embed_phase.add_file_reference(dylib_file)
build_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }

project.save
puts "✅ Embedded and set to sign #{dylib_name} for target #{target_name}"
