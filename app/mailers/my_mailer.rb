class MyMailer < Devise::Mailer   
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

def confirmation_instructions(record, token, opts={})
  headers["Custom_header"] = "Email Archive Email Confirmation"
  opts[:from] = 'CSC322_email_archive@Grinnell.edu'
  #opts[:reply_to] = 'CSC322_emailArchive@Grinnell.edu'
  super
end

end