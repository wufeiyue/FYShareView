Pod::Spec.new do |s|

  s.name         = "FYShareView"
  s.version      = "1.0.1"
  s.summary      = "简单可信赖的分享视图"
  s.description  = <<-DESC
很精简的分享视图
                   DESC

  s.homepage     = "http://www.wufeiyue.com"

  s.license      = { :type => "MIT", :file => "LICENSE.md" }

  s.author             = { "Angelo" => "ieppeo@163.com" }
  
  s.platform     = :ios
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/wufeiyue/FYShareView.git", :tag => "1.0.1" }
  s.source_files  = "Classes", "Classes/*"

