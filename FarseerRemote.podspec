Pod::Spec.new do |s|
  s.name         = "FarseerRemote"
  s.version      = "1.2.0"
  s.summary      = "A test time analyse tool."
  s.description  = <<-DESC
  In Farseer, the log is divided into five levels, Fatal, Error, Warning, Log and Minor. It will be outputted to the terminal or central device with different colors according to its own level. The log can be acquired wirelessly through Bluetooth in real-time. Farseer can only display the selected part filtered by level, file, method name or line number. Farseer can use central device to access the launching target application device, view the sandbox directory, get the target file in the sandbox. Central device will keep all other device’s logs, for compare and analyze between different time periods.
                   DESC

  s.homepage     = "https://github.com/winterbesos/Farseer"
  s.license      = "MIT"
  s.author             = { "Salo" => "2680914103@qq.com" }
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"

  s.source       = { :git => "https://github.com/winterbesos/Farseer.git", :tag => "#{s.version}" }
  s.source_files  = "Farseer_Project/Farseer_Remote/*.{h,m}", "Farseer_Project/Farseer_Remote/**/*.{h,m}",
                    "Farseer_Project/FarseerBase/*.{h,m}"

  s.frameworks = "Foundation", "CoreBluetooth"
end
