require 'calabash-cucumber/launcher'

Before('@reset_app_btw_scenarios') do
  if xamarin_test_cloud?
    ENV['RESET_BETWEEN_SCENARIOS'] = '1'
  elsif LaunchControl.target_is_simulator?
    target = LaunchControl.target
    simulator = RunLoop::Device.device_with_identifier(target)
    app = RunLoop::App.new(ENV['APP'] || ENV['APP_BUNDLE_PATH'])
    bridge = RunLoop::CoreSimulator.new(simulator, app)
    bridge.reset_app_sandbox
  else
    LaunchControl.install_on_physical_device
  end
end