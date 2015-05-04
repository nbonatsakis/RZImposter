Pod::Spec.new do |s|
  s.name             = "RZImposter"
  s.version          = "0.1.0"
  s.summary          = "A short description of RZImposter."
  s.description      = <<-DESC
                       An optional longer description of RZImposter

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/RZImposter"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Nick Bonatsakis" => "nbonatsakis@gmail.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/RZImposter.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'RZImposter/Classes/**/*'
  s.resource_bundles = {
    'RZImposter' => ['RZImposter/Assets/*.png']
  }

  s.dependency 'OHHTTPStubs', '~> 4.0.1'
end
