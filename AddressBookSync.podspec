Pod::Spec.new do |s|
  s.name             = "AddressBookSync"
  s.version          = "0.6.0"
  s.summary          = "Address Book sync library"
  s.homepage         = "https://github.com/taka0125/AddressBookSync"
  s.license          = 'MIT'
  s.author           = { "Takahiro Ooishi" => "taka0125@gmail.com" }
  s.source           = { :git => "https://github.com/taka0125/AddressBookSync.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/taka0125'
  s.requires_arc     = true

  s.ios.deployment_target = "8.0"

  s.subspec 'Scan' do |ss|
    ss.source_files = 'Pod/Classes/Scan/*.swift'
    ss.weak_framework = ['AddressBook', 'Contacts']
    ss.dependency 'IDZSwiftCommonCrypto'
  end

  s.subspec 'Sync' do |ss|
    ss.source_files = 'Pod/Classes/Sync/*.swift'
    ss.dependency 'AddressBookSync/Scan'
    ss.dependency 'Realm', '>= 0.103'
    ss.dependency 'RealmSwift', '>= 0.103'
  end
end
