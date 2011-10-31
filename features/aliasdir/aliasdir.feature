@aliasdir
Feature: Running aliasdir

  In order to be able to save time switching directories
  As a command line user
  I want to be able to easily alias directories
  
  Scenario: Aliasing a directory
    Given I execute: 
    """
      mkdir tmp/foo                          # make temp directory
      pushd tmp/foo                          # move to temp directory
      ../../lib/aliasdir.rb aliasdircuketest # alias the temp directory
      popd                                   # move back to original directory
    """
    When I execute and capture:
    """
      eval `lib/aliasdir.rb --dump` # make all aliases available
      aliasdircuketest              # use the new alias
      pwd                           # capture the directory
    """
    Then the captured output should show me I'm in the "tmp/foo" directory
  
  Scenario: Re-using an alias for a different directory
    Given I execute: 
    """
      mkdir tmp/foo                          # make temp directory
      mkdir tmp/bar                          # make 2nd temp directory
      pushd tmp/foo                          # move to temp directory
      ../../lib/aliasdir.rb aliasdircuketest # alias the temp directory
      cd ../bar                              # move to new temp directory
      ../../lib/aliasdir.rb aliasdircuketest # overwrite the existing alias
      popd                                   # move back to original directory
    """
    When I execute and capture:
    """
      eval `lib/aliasdir.rb --dump` # make all aliases available
      aliasdircuketest              # use the new alias
      pwd                           # capture the directory
    """
    Then the captured output should show me I'm in the "tmp/bar" directory

  Scenario: Removing an alias to a directory
    Given I execute: 
    """
      mkdir tmp/foo                          # make temp directory
      pushd tmp/foo                          # move to temp directory
      ../../lib/aliasdir.rb aliasdircuketest # alias the temp directory
      popd                                   # move back to original directory
    """
    When I execute and capture:
    """
      eval `lib/aliasdir.rb --dump` # make all aliases available
      aliasdircuketest              # use the new alias
      pwd                           # capture the directory
    """
    Then the captured output should show me I'm in the "tmp/foo" directory
    When I execute and capture:
    """
      eval `lib/aliasdir.rb --remove aliasdircuketest` # remove the test alias directory
      cat ~/.aliasdir
    """
    Then the captured output should not contain "aliasdircuketest"
