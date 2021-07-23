guard :rspec, cmd: "bundle exec rspec" do
  spec_dic = "spec"
  # RSpec files
  watch("spec/spec_helper.rb") { spec_dic }
  watch("spec/rails_helper.rb") { spec_dic }
  watch(%r{^spec/support/(.+)\.rb$}) { spec_dic }
  watch(%r{^spec/.+_spec\.rb$})
  # Engine files
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb)$}) { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
end
