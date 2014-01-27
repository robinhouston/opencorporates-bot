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

So I reinstall Ruby 2.0 using rvm, and then rerun `bundle install`: no need for the sudo this time, of course.

Great! It’s all installed. So let’s run the sample bot:

    opencorporates-bot $ bundle exec openc_bot rake bot:run
    /Users/robin/.rvm/gems/ruby-2.0.0-p353/bundler/gems/openc_bot-efe710e31208/lib/openc_bot/tasks.rb:88:in `require_relative': /Users/robin/Dropbox/Side projects/opencorporates-bot/lib/opencorporates-bot.rb:8: syntax error, unexpected '-', expecting '<' or ';' or '\n' (SyntaxError)
    class Opencorporates-botRecord < SimpleOpencBot::BaseLicenceRecord
                         ^
    /Users/robin/Dropbox/Side projects/opencorporates-bot/lib/opencorporates-bot.rb:54: syntax error, unexpected '-', expecting '<' or ';' or '\n'
    class Opencorporates-bot < SimpleOpencBot
                         ^
    	from /Users/robin/.rvm/gems/ruby-2.0.0-p353/bundler/gems/openc_bot-efe710e31208/lib/openc_bot/tasks.rb:88:in `block (3 levels) in <top (required)>'
    	from /Users/robin/.rvm/gems/ruby-2.0.0-p353/bundler/gems/openc_bot-efe710e31208/lib/openc_bot/tasks.rb:311:in `only_process_running'
    	from /Users/robin/.rvm/gems/ruby-2.0.0-p353/bundler/gems/openc_bot-efe710e31208/lib/openc_bot/tasks.rb:63:in `block (2 levels) in <top (required)>'
    	from /Users/robin/.rvm/rubies/ruby-2.0.0-p353/lib/ruby/2.0.0/rake/task.rb:228:in `call'
    	from /Users/robin/.rvm/rubies/ruby-2.0.0-p353/lib/ruby/2.0.0/rake/task.rb:228:in `block in execute'
    	from /Users/robin/.rvm/rubies/ruby-2.0.0-p353/lib/ruby/2.0.0/rake/task.rb:223:in `each'
    	from /Users/robin/.rvm/rubies/ruby-2.0.0-p353/lib/ruby/2.0.0/rake/task.rb:223:in `execute'
    	from /Users/robin/.rvm/rubies/ruby-2.0.0-p353/lib/ruby/2.0.0/rake/task.rb:166:in `block in invoke_with_call_chain'
    	from /Users/robin/.rvm/rubies/ruby-2.0.0-p353/lib/ruby/2.0.0/monitor.rb:211:in `mon_synchronize'
    	from /Users/robin/.rvm/rubies/ruby-2.0.0-p353/lib/ruby/2.0.0/rake/task.rb:159:in `invoke_with_call_chain'
    	from /Users/robin/.rvm/rubies/ruby-2.0.0-p353/lib/ruby/2.0.0/rake/task.rb:152:in `invoke'
    	from /Users/robin/.rvm/rubies/ruby-2.0.0-p353/lib/ruby/2.0.0/rake/application.rb:143:in `invoke_task'
    	from /Users/robin/.rvm/gems/ruby-2.0.0-p353/bundler/gems/openc_bot-efe710e31208/bin/openc_bot:12:in `<top (required)>'
    	from /Users/robin/.rvm/gems/ruby-2.0.0-p353/bin/openc_bot:23:in `load'
    	from /Users/robin/.rvm/gems/ruby-2.0.0-p353/bin/openc_bot:23:in `<main>'
    	from /Users/robin/.rvm/gems/ruby-2.0.0-p353/bin/ruby_executable_hooks:15:in `eval'
    	from /Users/robin/.rvm/gems/ruby-2.0.0-p353/bin/ruby_executable_hooks:15:in `<main>'

Oh dear. It doesn’t like the fact my directory name has a dash in, apparently. I rename `lib/opencorporates-bot.rb` to `lib/opencorporates_bot.rb` and correct the class names. This still doesn’t work:

    /Users/robin/.rvm/gems/ruby-2.0.0-p353/bundler/gems/openc_bot-efe710e31208/lib/openc_bot/tasks.rb:88:in `require_relative': cannot load such file -- /Users/robin/Dropbox/Side projects/opencorporates-bot/lib/opencorporates-bot (LoadError)

So I rename the project directory to `opencorporates_bot` as well, and at last it appears to work:

    opencorporates_bot $ bundle exec openc_bot rake bot:run
    .Got 1 records

## Writing the scraper

I check the list of supported schemas, and the most appropriate schema seems to be *Financial licence*.

It seems to me that the timezone of the machine running the scraper is irrelevant, and that the reporting date would therefore be better to be recorded in UTC. I change the code accordingly..

Next I look at what HTTP requests will have to be made to fetch the data. Unfortunately it is rather opaque: the paging mechanism involves the browser running a JavaScript function that issues a multipart POST request. The structure of this request is opaque. Here, for example, is the request that was made when I clicked to page 2:

    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="StylesheetManager_TSSM"

    ;Telerik.Web.UI, Version=2011.1.519.35, Culture=neutral, PublicKeyToken=121fae78165ba3d4:en-AU:b7b69463-0a06-4063-8ab0-8d180e49bc39:1c2121e:e24b8e95:92753c09:311bfd78
    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="ScriptManager_TSM"

    ;;System.Web.Extensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35:en:eb198dbd-2212-44f6-bb15-882bde414f00:ea597d4b:b25378d2;Telerik.Web.UI, Version=2011.1.519.35, Culture=neutral, PublicKeyToken=121fae78165ba3d4:en:b7b69463-0a06-4063-8ab0-8d180e49bc39:16e4e7cd:f7645509:24ee1bba:f46195d3:1e771326:aa288e2d:874f8ea2:19620875:490a9d4e:bd8f85e4
    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="__EVENTTARGET"

    dnn$ctr1025$Default$gvSearchResult
    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="__EVENTARGUMENT"

    Page$2
    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="__VIEWSTATE"

    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
    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="__VIEWSTATEENCRYPTED"


    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="__EVENTVALIDATION"

    ZF/hQPVOa03/lc2742WM/76gOlktlLQu+3PBg/RVE+yzqdft19n+PjhoUHHOpOaFLVXDCIZdq+W/+rPeWVa+Bpm50hk8VkTMUMqbugsvppIp8JYqb5Y8ZJDpXZ+Xd4nNjUHCtXBeVQnxN0uheKZXe02/MjztpWi0NBJ6OowmuZokb2NcsRcU8WDIYZztiDOSvMuG6PTPEZSehbb8TvW/7w2Hb6GsldhHG+/k4HKdCIcnylHU5TVGvjMVzC0riUPS6WmwbTMkKskbgebNJsEuEe6nVvwCx7jPHUOA4NQsX/dMzhfhXmEc/Xp7ebIpgW9frEllfF497UJQryR6YLzToJP+GGM+ybgeVo1Bae0l08kx1R+BjhEelrnIUWqbUB8NYEwcKTmhlgJWSxWXDw68BLhW5Nk=
    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="dnn$dnnSEARCH$txtSearch"


    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="dnn$ctr1025$Default$rcbSearchBox"


    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="dnn_ctr1025_Default_rcbSearchBox_ClientState"

    {"logEntries":[],"value":"","text":"","enabled":true}
    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="dnn_ctr1025_Default_RadWindow1_ClientState"


    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="dnn_ctr1025_Default_RadWindowManager_ClientState"


    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="ScrollTop"


    ------WebKitFormBoundary9m2X7XhCNexDkR2a
    Content-Disposition: form-data; name="__dnnVariable"


    ------WebKitFormBoundary9m2X7XhCNexDkR2a--

It seems reasonable to start by finding out how to issue these requests. Looking at the HTML source, there is a `<form>` element that has a number of hidden fields matching the names and values of these fields, so perhaps it is not going to be too hard.

Okay. Yes, it’s reasonably easy. The script `test.rb` appears to scrape the first few pages successfully.

Right, now to roll that into the bot framework. Doesn’t seem too hard.
