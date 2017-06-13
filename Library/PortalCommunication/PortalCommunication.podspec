
#

Pod::Spec.new do |s|



  s.name         = "PortalCommunication"
  s.version      = "1.0.0"
  s.summary      = "PortalCommunication"


  s.description  = "PortalCommunication"

  s.homepage     = "https://github.com/vasiliorlov/PortalCommunication/tree/master/Library"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"



  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }



  s.author             = { "Vasilij Orlov" => "Vasilij_Orlov@STYLESOFT.BY" }
  # Or just: s.author    = "Vasilij Orlov"
  # s.authors            = { "Vasilij Orlov" => "Vasilij_Orlov@STYLESOFT.BY" }
  # s.social_media_url   = "http://twitter.com/Vasilij Orlov"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
   s.platform     = :ios, "8.2"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :path => '.' }



  s.source_files 	 = "PortalCommunication", "PortalCommunication/**/*.{h,m,swift}", "PortalCommunication/AsyncOperation.xcdatamodeld", "PortalCommunication/AsyncOperation.xcdatamodeld/*.xcdatamodel"  
  s.resources 		 = ["PortalCommunication/AsyncOperation.xcdatamodeld", "PortalCommunication/AsyncOperation.xcdatamodeld/*.xcdatamodel" ]
  s.exclude_files	 = "Classes/Exclude"
  s.preserve_paths       = "PortalCommunication/AsyncOperation.xcdatamodeld"
 
  s.resource_bundles = {'PortalCommunication' => ['PortalCommunication/*.xcdatamodeld']}





 

    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }


   s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
    s.dependency "Alamofire"
  #  s.dependency "RealmSwift"

end
