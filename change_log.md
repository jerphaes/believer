# 0.1
- Initial commit

## 0.1.1 - 0.1.4
- Bug fixes

# 0.2
- Support for connection pooling
- More class docs
- Created a column class, with improved type mapping
- Support for Merb environment
- Relations

## 0.2.1
- Fixed the gemspec runtime dependency versions

## 0.2.2
- Added collection methods to relation collection
- Small bugfixes
- Fixed non working test module (Believer::Test::TestRunLifeCycle)

## 0.2.3
- Fixed typo in Gem description

## 0.2.4
- Logging using ActiveSupport LogSubscriber
- Extra configuration options

## 0.2.5
- Added allow_filtering method to Believer::Query
- Added consistency level support using method
- Support for pluck method

## 0.2.6
- Basic support for collection attributes: list, set and map. Only reads and full updates are supported, not partial (e.g. UPDATE users SET favs['author'] = 'Ed Poe' WHERE id = 'jsmith')
- Addded Update class for saving already persisted objects
- Counter support

## 0.2.7
- Small bugfix in Counter class

# 0.2.8
- Small fix regariding the setting of the consitency level
- Added pluck and all to Believer::Base class methods

# 0.2.9 - 0.2.10
- ActiveModel 4 support

# 0.2.11 - 0.2.12
- Slightly faster result rows to objects conversion for large result sets

# 0.2.13
- pluck method bugfix

# 0.2.14
- Added a more efficient any? method to the Query interface
- Renamed Counter reset! method to undo_changes!
- Counter reset! method sets the counter to 0

# 0.2.15
- Counter bugfixes

# 0.2.16
- Small bugfixes

# 0.2.17
- Environment improvements

# 0.2.18
- Added method update_all to query
