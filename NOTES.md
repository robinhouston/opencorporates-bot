# My experience writing an Open Corporates bot

## Initial installation

I should explain here that, although I have done some work with Ruby and Rails, I do not use it every day (or even every month). Perhaps my initial difficulties would not have been encountered by someone who lives and breathes Ruby.

As the documentation suggests, I began by trying to install the skeleton bot:

    curl -s https://raw.github.com/openc/openc_bot/enumerators-and-iterators/create_simple_licence_bot.sh | bash

It attempted to install some RubyGems, and failed like this:

    Installing activesupport (4.0.2) /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/rubygems/installer.rb:163:in `install': activesupport requires Ruby version >= 1.9.3. (Gem::InstallError)
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/source.rb:101:in `install'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/rubygems_integration.rb:78:in `preserve_paths'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/source.rb:91:in `install'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/installer.rb:58:in `run'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/rubygems_integration.rb:93:in `with_build_args'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/installer.rb:57:in `run'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/spec_set.rb:12:in `each'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/spec_set.rb:12:in `each'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/installer.rb:49:in `run'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/installer.rb:8:in `install'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/cli.rb:222:in `install'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/vendor/thor/task.rb:22:in `send'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/vendor/thor/task.rb:22:in `run'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/vendor/thor/invocation.rb:118:in `invoke_task'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/vendor/thor.rb:246:in `dispatch'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/lib/bundler/vendor/thor/base.rb:389:in `start'
    	from /Library/Ruby/Gems/1.8/gems/bundler-1.0.15/bin/bundle:13
    	from /usr/bin/bundle:19:in `load'
    	from /usr/bin/bundle:19

But in fact my default Ruby interpreter is version 2.0:

    opencorporates-bot $ ruby --version
    ruby 2.0.0p247 (2013-06-27 revision 41674) [universal.x86_64-darwin13]

It appears the problem is that Bundler was installed by Ruby 1.8:

    opencorporates-bot $ head -1 /usr/bin/bundle
    #!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby

Okay, so let’s reinstall it:

    opencorporates-bot $ sudo gem install bundler
    Password:
    Fetching: bundler-1.5.2.gem (100%)
    Successfully installed bundler-1.5.2
    Parsing documentation for bundler-1.5.2
    Installing ri documentation for bundler-1.5.2
    1 gem installed
    opencorporates-bot $ which bundle
    /usr/bin/bundle
    opencorporates-bot $ head -1 /usr/bin/bundle
    #!/System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/bin/ruby

That looks better. Let’s try running the script again:

    opencorporates-bot $ sh create_simple_licence_bot.sh 
    Updating https://github.com/openc/openc_bot.git
    Fetching gem metadata from https://rubygems.org/.........
    Fetching additional metadata from https://rubygems.org/..
    Resolving dependencies...

    Errno::EACCES: Permission denied - /Library/Ruby/Gems/2.0.0/build_info/i18n-0.6.9.info
    An error occurred while installing i18n (0.6.9), and Bundler cannot continue.
    Make sure that `gem install i18n -v '0.6.9'` succeeds before bundling.

Okay, that didn’t work. The script looks pretty simple, though. Let’s try doing the steps by hand. It looks as though Bundler is trying to install files into a directory that is owned by root, so we’ll try `sudo bundle install`.

Okay. That worked, and the rake task ran apparently successfully. Then I ran `sudo bundle install` again, as instructed, and it installed some gems and then flaked out as follows:

    Installing debugger-ruby_core_source (1.3.1)

    Gem::Installer::ExtensionBuildError: ERROR: Failed to build gem native extension.

        /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/bin/ruby extconf.rb 
    checking for rb_method_entry_t.called_id in method.h... no
    checking for rb_control_frame_t.method_id in method.h... no
    checking for rb_method_entry_t.called_id in method.h... no
    checking for rb_control_frame_t.method_id in method.h... no
    checking for rb_method_entry_t.called_id in method.h... yes
    checking for vm_core.h... yes
    checking for iseq.h... no
    Makefile creation failed
    *************************************************************

      NOTE: If your headers were not found, try passing
            --with-ruby-include=PATH_TO_HEADERS      

    *************************************************************

    *** extconf.rb failed ***
    Could not create Makefile due to some reason, probably lack of necessary
    libraries and/or headers.  Check the mkmf.log file for more details.  You may
    need configuration options.

    Provided configuration options:
    	--with-opt-dir
    	--without-opt-dir
    	--with-opt-include
    	--without-opt-include=${opt-dir}/include
    	--with-opt-lib
    	--without-opt-lib=${opt-dir}/lib
    	--with-make-prog
    	--without-make-prog
    	--srcdir=.
    	--curdir
    	--ruby=/System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/bin/ruby
    	--with-ruby-dir
    	--without-ruby-dir
    	--with-ruby-include
    	--without-ruby-include=${ruby-dir}/include
    	--with-ruby-lib
    	--without-ruby-lib=${ruby-dir}/


    Gem files will remain installed in /Library/Ruby/Gems/2.0.0/gems/debugger-1.6.5 for inspection.
    Results logged to /Library/Ruby/Gems/2.0.0/gems/debugger-1.6.5/ext/ruby_debug/gem_make.out
    An error occurred while installing debugger (1.6.5), and Bundler cannot continue.
    Make sure that `gem install debugger -v '1.6.5'` succeeds before bundling.

The problem appears to be [this issue](https://github.com/cldwalker/debugger/issues/105), for which the only proposed solution is to reinstall Ruby using rvm.
