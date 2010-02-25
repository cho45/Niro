use File::Spec;
use strict;
use warnings;
use Test::Base;
use Text::Hatena;

filters {
    text => ['text_hatena', 'omit_indent', 'chomp'],
    line => ['text_hatena_p', 'omit_indent', 'chomp'],
    html => ['omit_indent', 'chomp'],
};

sub text_hatena { Text::Hatena->parse(shift, 'body') }
sub text_hatena_p { Text::Hatena->parse(shift, 'p') }
sub omit_indent {
    (my $text = shift) =~ s/^[\t\s]+//gmo;
    return $text;
}

#use Carp;
#local $SIG{'__WARN__'} = \&Carp::confess;

run_is;

__END__
=== h3
--- text
*Hello, World!
--- html
<div class="section">
  <h3>Hello, World!</h3>
</div>

=== h3_2
--- text
*Hello, World!
This is Text::Hatena.
--- html
<div class="section">
  <h3>Hello, World!</h3>
  <p>This is Text::Hatena.</p>
</div>

=== h3_3
--- text
 *Hello, World!
This is Text::Hatena.
--- html
<div class="section">
  <p> *Hello, World!</p>
  <p>This is Text::Hatena.</p>
</div>

=== h3_4
--- text
*Good morning

It's morning.

*Good afternoon

Beautiful day!
--- html
<div class="section">
<h3>Good morning</h3>

<p>It's morning.</p>
</div>
<div class="section">
<h3>Good afternoon</h3>

<p>Beautiful day!</p>
</div>

=== h4
--- text
**Hello, Japan!

This is Text::Hatena.
--- html
<div class="section">
  <h4>Hello, Japan!</h4>

  <p>This is Text::Hatena.</p>
</div>

=== h5
--- text
***Hello, Tokyo!

This is Text::Hatena.
--- html
<div class="section">
  <h5>Hello, Tokyo!</h5>

  <p>This is Text::Hatena.</p>
</div>

=== blockquote
--- text
>>
quoted
<<
--- html
<div class="section">
  <blockquote>
    <p>quoted</p>
  </blockquote>
</div>

=== blockquote2
--- text
>>
quoted
>>
quoted quoted
<<
<<
--- html
<div class="section">
  <blockquote>
    <p>quoted</p>
    <blockquote>
	  <p>quoted quoted</p>
    </blockquote>
  </blockquote>
</div>

=== blockquote3
--- text
 >>
 unquoted
 <<
--- html
<div class="section">
  <p> >></p>
  <p> unquoted</p>
  <p> <<</p>
</div>

=== blockquote4
--- text
>http://www.hatena.ne.jp/>
Hatena
<<
--- html
<div class="section">
  <blockquote title="http://www.hatena.ne.jp/" cite="http://www.hatena.ne.jp/">
	<p>Hatena</p>
    <cite><a href="http://www.hatena.ne.jp/">http://www.hatena.ne.jp/</a></cite>
  </blockquote>
</div>

=== blockquote5
--- text
>http://www.hatena.ne.jp/:title=Hatena>
Hatena
<<
--- html
<div class="section">
  <blockquote title="Hatena" cite="http://www.hatena.ne.jp/">
	<p>Hatena</p>
    <cite><a href="http://www.hatena.ne.jp/">Hatena</a></cite>
  </blockquote>
</div>

=== dl
--- text
:cinnamon:dog
--- html
<div class="section">
  <dl>
    <dt>cinnamon</dt>
    <dd>dog</dd>
  </dl>
</div>

=== dl2
--- text
:cinnamon:dog
:tama:cat
--- html
<div class="section">
  <dl>
    <dt>cinnamon</dt>
    <dd>dog</dd>
    <dt>tama</dt>
    <dd>cat</dd>
  </dl>
</div>

=== ul
--- text
-komono
-kyoto
-shibuya
--- html
<div class="section">
  <ul>
	<li>komono</li>
	<li>kyoto</li>
	<li>shibuya</li>
  </ul>
</div>

=== ul2
--- text
-komono
--kyoto
---shibuya
--hachiyama
--- html
<div class="section">
  <ul>
	<li>komono
	<ul>
	  <li>kyoto
	  <ul>
		<li>shibuya</li>
	  </ul>
	  </li>
	  <li>hachiyama</li>
	</ul>
	</li>
  </ul>
</div>

=== ul3
--- text
-list
--ul
--ol
-pre
--- html
<div class="section">
  <ul>
	<li>list
	<ul>
	  <li>ul</li>
	  <li>ol</li>
	</ul>
	</li>
	<li>pre</li>
  </ul>
</div>

=== ul4
--- text 
 - wrong list
 - what's happen?
--- html
<div class="section">
<p> - wrong list</p>
<p> - what's happen?</p>
</div>

=== ul5
--- text 
- right list
 - wrong list
 - what's happen?
--- html
<div class="section">
<ul>
<li> right list</li>
</ul>
<p> - wrong list</p>
<p> - what's happen?</p>
</div>

=== ul6
--- text
-Japan
--Kyoto
--Tokyo
-USA
--Mountain View
--- html
<div class="section">
  <ul>
	<li>Japan
	<ul>
	  <li>Kyoto</li>
	  <li>Tokyo</li>
	</ul>
	</li>
	<li>USA
	<ul>
	  <li>Mountain View</li>
	</ul>
	</li>
  </ul>
</div>

=== ul7
--- text
-komono
--kyoto
---shibuya
--hachiyama
--- html
<div class="section">
  <ul>
	<li>komono
	  <ul>
		<li>kyoto
		  <ul>
			<li>shibuya</li>
		  </ul>
		</li>
		<li>hachiyama</li>
	  </ul>
	</li>
  </ul>
</div>

=== ol
--- text
+Register
+Login
+Write your blog
--- html
<div class="section">
  <ol>
	<li>Register</li>
    <li>Login</li>
	<li>Write your blog</li>
  </ol>
</div>

=== ol2
--- text
-Steps
++Register
++Login
++Write your blog
-Option
--180pt
--- html
<div class="section">
  <ul>
	<li>Steps
	  <ol>
		<li>Register</li>
		<li>Login</li>
		<li>Write your blog</li>
	  </ol>
	</li>
	<li>Option
	  <ul>
		<li>180pt</li>
	  </ul>
	</li>
  </ul>
</div>

=== super_pre
--- text
>||
#!/usr/bin/perl

my $url = 'http://d.hatena.ne.jp/';
||<
--- html
<div class="section">
	<pre>
#!/usr/bin/perl

my $url = 'http://d.hatena.ne.jp/';
</pre>
</div>

=== super_pre_fail
--- text
>||
#!/usr/bin/perl

my $name = 'jkondo'||<
--- html
<div class="section">
<p>>||</p>
<p>#!/usr/bin/perl</p>

<p>my $name = 'jkondo'||<</p>
</div>

=== super_pre2
--- text
>|perl|
#!/usr/bin/perl

my $url = 'http://d.hatena.ne.jp/';
||<
--- html
<div class="section">
	<pre>
#!/usr/bin/perl

my $url = 'http://d.hatena.ne.jp/';
</pre>
</div>

=== super_pre3
--- text
>||
>>
unquoted
<<
- unlisted
http://www.hatena.com/ unanchored.
||<
--- html
<div class="section">
	<pre>
>>
unquoted
<<
- unlisted
http://www.hatena.com/ unanchored.
</pre>
</div>

=== super_pre4
--- text
>||
>>
unquoted
<<
- unlisted
http://www.hatena.com/ unanchored.
<a href="http://www.hatena.com/">escaped tags</a>
||<
--- html
<div class="section">
	<pre>
>>
unquoted
<<
- unlisted
http://www.hatena.com/ unanchored.
<a href="http://www.hatena.com/">escaped tags</a>
</pre>
</div>

=== pre
--- text
>|
#!/usr/bin/perl
use strict;
use warnings;

say 'Hello, World!';
|<
--- html
<div class="section">
	<pre>
#!/usr/bin/perl
use strict;
use warnings;

say 'Hello, World!';
</pre>
</div>

=== pre2
--- text
>|
To: info@test.com
Subject: This is Test.

Hello, This is test from Text::Hatena.
 Don't reply to this email.

--
jkondo
|<
--- html
<div class="section">
	<pre>
To: info@test.com
Subject: This is Test.

Hello, This is test from Text::Hatena.
 Don't reply to this email.

--
jkondo
</pre>
</div>

=== table
--- text
|*Lang|*Module|
|Perl|Text::Hatena|
--- html
<div class="section">
  <table>
	<tr>
	  <th>Lang</th>
	  <th>Module</th>
	</tr>
	<tr>
	  <td>Perl</td>
	  <td>Text::Hatena</td>
	</tr>
  </table>
</div>

=== cdata
--- text
><div>no paragraph line</div><
paragraph line
--- html
<div class="section">
	<div>no paragraph line</div>
	<p>paragraph line</p>
</div>

=== cdata2
--- text
><blockquote>
<p>Hello I am writing HTML tags by myself</p>
</blockquote><
--- html
<div class="section">
  <blockquote>
	<p>Hello I am writing HTML tags by myself</p>
  </blockquote>
</div>

=== cdata3
--- text
><blockquote><
Please add p tags for me.
It's candy blockquote.
></blockquote><
--- html
<div class="section">
  <blockquote>
	<p>Please add p tags for me.</p>
	<p>It's candy blockquote.</p>
  </blockquote>
</div>

=== autolink
--- text
*Hello World!

Here is Text::Hatena.
CPAN site: http://search.cpan.org/dist/Text-Hatena/
Have fun!
--- html
<div class="section">
<h3>Hello World!</h3>

<p>Here is Text::Hatena.</p>
<p>CPAN site: <a href="http://search.cpan.org/dist/Text-Hatena/">http://search.cpan.org/dist/Text-Hatena/</a></p>
<p>Have fun!</p>
</div>
