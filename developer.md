# Computer Science Email Archive Development Documentation
**Table of Contents**

[TOCM]

[TOC]
## Status

Hi! We designed an email archive which collected emails on the CSC mailing list. 
Anybody with a grinnell email can make an account and view the archive. In its 
current version, the archive supports search by date and dynamically added tags,
as well as string matching within the author, subject, and content fields. We 
intend to give students a database by which to search for internships or
important information, as well as allow people in the distant future to review
the history of the department. 

There is limited documentation in the actual code. Have fun. 

## User Authentication

There are two separate models;` user` and `admin`. Our account registration is 
handled with `Devise`. User accounts require email verification and the
accounts, mentioned above, need a valid grinnell email. Email verification is
automatically done by devise but the template was edited (can be found in
`my_mailer.rb`).
The admin model was created using the gem `ActiveAdmin`. There is a tendency 
for the program to reroute the user to the user sign in page - this creates a 
problem when the admin tries to login and is redirected. To fix this, there are
lines of code in `ActiveAdmin.rb` and `ApplicationController.rb` to create an 
exception for the admin. These lines should have comments above them specifying
their function. There is also a manually added link on the user sign in page to
redirect to the admin page but the url is as follows:
`Yourc9whatever/admin/login"` or on [heroku]
(https://email-archive.herokuapp.com/admin/login).

The admin page has functions to create new admins (this is the only place where 
admins are added and removed), view emails, edit emails, and delete emails. Feel
free to play with the layout of the admin page. The default admin login is as 
follows:

    Username: admin@example.com
    Password: password

Note that admins do not need email authentication as we are assuming the admin
is a responsible user. My suggestion would be to add Sam as an admin and remove
the dummy user. Sam can then add the rest of the CS dept (or as Sam pleases).
I don't know what will happen if you remove the dummy user without creating a
new admin (0 admins). Please don't try it. Again, we are assuming the CS faculty
as responsible admin. 

## Message Model

The message model has several fields- `id`, `author`, `subject`, `content`,
`created_at`, and `updated_at`. The tags are included through a tagging gem,
`acts_as_taggable_on`, which is accessed through GET requests. You can view 
fields under `Schema.rb`. Attachments are currently not supported.

Messages can be altered or deleted by Admins, or users with the correct
permissions. This may be useful for dealing with tags that have been misspelled 
(“SC Table” instead of “CS Table”, for example).


## Gmail Server and Retrieval

We retrieve emails by popping them from a gmail server at regular intervals.
Our gmail server is `csc322emailarchive@gmail.com` , the same server that 
processes Devise users. The password is located in `user_mailer.rb`. We are 
currently using pop3 to fetch emails. We are using the gem `rufus-scheduler`
for automatically fetching emails from the email server. You can change the
timing of the retrieval (it's set to ‘1m’ meaning every minute but you could 
change it to ‘1h’ or ‘1s’ for every 1 hour or every 1 second respectively).

Emails are only popped if they come from an authorized source, and emails 
without grinnell.edu domains are automatically rejected (see `User_mailer.rb`
for mail retrieval). There were some difficulties maintaining the integrity of 
the original text, and messages were added to the database with some characters
like ‘ changed to other things. If you’re confused by regular expressions 
wizardry, that’s probably why. There are still errors with UTF-8 to Windows-125X
encoding. We are not sure how to fix it for every case.


## Tagging

Tags are added to the messages in the User_mailer.rb using the addTag method.
There are only a discrete number of tags that can be used. You may add or delete
tags as you wish. Tags must be added in the subject line of the email in
brackets likes: [Job]. Multiple tags can be added like: [Job][Internship].

Tagging is handled with a gem called `acts_as_taggable_on`. Tags are not
actually message fields, but are associated with message objects. Tags can 
be added dynamically, and every tag in the archive is shown on the home page.
Professors can add tags to their emails by enclosing them in square brackets 
at the beginning of the subject field. The tags are then added to the message, 
and the subject field is entered into the database with the brackets and tags
stripped off.

Any tag can be accessed through a GET request. To process a GET request for the
tag CS Table, enter the` URL /messages?tag=CS Table`. For Both tags CS Table and
Internship, enter` URL /messages?tag=CS Table`, Internship. At the moment, there
is no way for users to enter several tags beyond typing them in manually. Tags
can be supplemented with searches, but in the same way- only by manually
entering the URL themselves. This seems like an obvious place to improve
on the existing archive. messages_controller and application_controller
may be relevant. 

## Search

We use the `Ransack` gem, which allows us to search the following message
fields- subject, content, author, and created_at. The ransack search code
is located in `home.html.erb` and `search.html.erb `both in static_pages
in the views. For cucumber testing purposes, the f.label and f.search_field
names must match; however, adding a string after f.label will change the name
of the search field on the web page.

The f.search_field must be followed by names of fields within the model being
searched (i.e. ‘subject’ or ‘content’), followed by how the field should be
searched. _cont represents “contains,” so whatever is entered in the search
bar checks the database to see if that field contains anything that matches
that string exactly. For example, passing “break” to the field that calls
subject_cont will check to see if any email subjects contain the word “break.”
Other searching suffixes are provided on the Ransack wiki.

## Layout and Other Details

After a user is authenticated, they are taken to the home page or root
directory. On this page, there are search bars, all existing tags, and 
a "Newest Messages" button. The search bars and tags filter search results,
and the "Newest Messages" button links to the full archive.

The "Newest Messages" button takes users to the` /messages/page`, where archived
emails are actually rendered. Ten emails are rendered per page, with most recent
emails at the top (if the order isn't perfect, it's because emails are sorted
according to when they're popped from Gmail and added to the archive, not
necessarily when they're sent to the Gmail server). Pagination works with
search results and with tagging.

In the index, email content is shortened according to the program under
`messages/helper`.  To see the full message, click on the show button, which
should direct the user to a different page with a single email.

One potential project is integrating the home page with the `/messages/ page`, 
such that search options and tags show up in sidebars or headers in the email
index. This way, users are automatically directed to the most recent messages
and can always easily start a new search. This primarily involves changing HTML. 

Stylesheets are generally found under` /app/assets/stylesheets/messages.css`.
The .scss version is nearly identical but does not seem to have any effect as
of now. 

##Testing

We strongly recommend that you run tests before editing anything, so you can 
make sure that your edits are not interfering with basic functionality. 

All of our testing suites are written in Cucumber and found under features. 
To run the testing suite `home_page.feature`, enter 
`cucumber features/home_page.feature` in the terminal. Passing tests come out 
green, failed tests come out red, and uninterpreted tests come out yellow. Avoid
removing anything from `web_steps.rb` or` paths.rb `if you do not want to
interfere with testing suite functionality. 

If you make alterations to layouts, you will almost certainly have to make
according adjustments to tests. 



