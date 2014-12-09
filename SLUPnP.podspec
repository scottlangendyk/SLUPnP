Pod::Spec.new do |s|
  s.name         = "SLUPnP"
  s.version      = "0.1.0"
  s.summary      = "A modern UPnP library for OSX."
  s.homepage     = "https://bitbucket.org/scottlangendyk/SLUPnP"
  s.license      = "COMMERCIAL"
  s.author       = { "Scott Langendyk" => "scott@langendyk.com" }
  s.source       = { :git => "git@bitbucket.org:scottlangendyk/SLUPnP.git", :tag => s.version.to_s }

  s.platform     = :osx, "10.8"
  s.requires_arc = true

  s.source_files = "Classes/*.{h,m}"

  s.subspec "SSDP" do |ss|
    ss.source_files = "Classes/SSDP/*.{h,m}"
  end

  s.subspec "HTTP" do |ss|
    ss.source_files = "Classes/HTTP/*.{h,m}"
  end

  s.dependency "CocoaAsyncSocket", "~> 7.4"
  s.dependency "AFNetworking",     "~> 2.4"
end
