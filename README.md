#Spamassassin BayesBytes

Spamassassin BayesBytes is a plugin which creates Bayes tokens from 3 byte sequences from email messages. This is intended to give Bayes a more naive Tokens to add to it's calculation stack.

An average message has an increase in token count of at least 5x - this generally turns out to be much more.

##Installation

 - Download zip / Clone repo
 - Move to contents to spamassassin location
	 - Usually /etc/mail/spamassassin or /etc/spamassassin
 - Update Concepts.cf with correct path to the concepts directory
 - Do the test as below
 - Make sure [Bayes](https://wiki.apache.org/spamassassin/BayesFaq) is enabled
 - Restart Spamassassin

###Testing Installation

With a test email run spamassassin in debug mode, searching for the *Concepts* keyword

    $ spamassassin -D -t testemail 2>&1 | grep BayesBytes
    ...
    [12201] dbg: plugin: loading Mail::SpamAssassin::Plugin::BayesBytes from /etc/spamassassin/BayesBytes.pm

This means the plugin has loaded.

##Change Log

###Version 0.01
 - Initial release
 - Known bug: Not able to change sequence length by bayesbytes_length even though the option is set
