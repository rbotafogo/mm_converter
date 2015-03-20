require 'rbconfig'

##########################################################################################
# Configuration. Remove setting before publishing Gem.
##########################################################################################

# set to true if development environment
$DVLP = true

# Set to 'cygwin' when in cygwin
$ENV = 'cygwin'

# Set development dependency: those are gems that are also in development and thus not
# installed in the gem directory.  Need a way of accessing them
$DEPEND=["MDArray"]

##########################################################################################

# the platform
@platform = 
  case RUBY_PLATFORM
  when /mswin/ then 'windows'
  when /mingw/ then 'windows'
  when /bccwin/ then 'windows'
  when /cygwin/ then 'windows-cygwin'
  when /java/
    require 'java' #:nodoc:
    if java.lang.System.getProperty("os.name") =~ /[Ww]indows/
      'windows-java'
    else
      'default-java'
    end
  else 'default'
  end

#---------------------------------------------------------------------------------------
# Add path to load path
#---------------------------------------------------------------------------------------

def mklib(path, home_path = true)
  
  if (home_path)
    lib = path + "/lib"
  else
    lib = path
  end
  
  $LOAD_PATH << lib
  
end

##########################################################################################
# Prepare environment to work inside Cygwin
##########################################################################################

if $ENV == 'cygwin'
  
  #---------------------------------------------------------------------------------------
  # Return the cygpath of a path
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    `cygpath -a -p -m #{path}`.tr("\n", "")
  end
  
else
  
  #---------------------------------------------------------------------------------------
  # Return  the path
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    path
  end
  
end

#---------------------------------------------------------------------------------------
# Set the project directories
#---------------------------------------------------------------------------------------

class MMConverter

  @home_dir = File.expand_path File.dirname(__FILE__)

  class << self
    attr_reader :home_dir
  end

  @project_dir = MMConverter.home_dir + "/.."
  @doc_dir = MMConverter.home_dir + "/doc"
  @lib_dir = MMConverter.home_dir + "/lib"
  @src_dir = MMConverter.home_dir + "/src"
  @target_dir = MMConverter.home_dir + "/target"
  @test_dir = MMConverter.home_dir + "/test"
  @vendor_dir = MMConverter.home_dir + "/vendor"
  
  class << self
    attr_reader :project_dir
    attr_reader :doc_dir
    attr_reader :lib_dir
    attr_reader :src_dir
    attr_reader :target_dir
    attr_reader :test_dir
    attr_reader :vendor_dir
  end

  @build_dir = MMConverter.src_dir + "/build"

  class << self
    attr_accessor :build_dir
  end

  @classes_dir = MMConverter.build_dir + "/classes"

  class << self
    attr_reader :classes_dir
  end

end

#---------------------------------------------------------------------------------------
# Set dependencies
#---------------------------------------------------------------------------------------

def depend(name)
  
  dependency_dir = MMConverter.project_dir + "/" + name
  mklib(dependency_dir)
  
end

# depends also on local taskjuggler
# mklib(MMConverter.home_dir + "../vendor/taskjuggler-3.5.0")

##########################################################################################
# If development
##########################################################################################

if ($DVLP == true)

  mklib(MMConverter.home_dir)
  
  # Add dependencies here
  # depend(<other_gems>)
  $DEPEND.each do |dep|
    depend(dep)
  end if $DEPEND

  #----------------------------------------------------------------------------------------
  # If we need to test for coverage
  #----------------------------------------------------------------------------------------
  
  if $COVERAGE == 'true'
  
    require 'simplecov'
    
    SimpleCov.start do
      @filters = []
      add_group "MMConverter", "lib/scicom"
    end
    
  end

end

