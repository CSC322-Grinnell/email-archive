class UserMailer < ApplicationMailer
  
  require 'mail'

# This is for connecting to gmail account
  Mail.defaults do
    retriever_method :pop3, :address    => "pop.gmail.com",
                            :port       => 995,
                            :user_name  => 'csc322emailarchive',
                            :password   => 'Anklegun322',
                            :enable_ssl => true
  end

#This is a method to grab mail info from each file
  def getMail
#   gets maximum id avoiding nil case
    id = Message.maximum(:id)
    if id.nil?
      id = 0
    else
      id += 1
    end
    allMail = Mail.all #Grab all unread mail
    if !allMail.empty? #Check to see if no new mail
      allMail.each do |mail|
#This is a method to check to see if author is from grinnell domain
#        if mail.from[0].downcase.include? ("@grinnell.edu")
#        if mail.subject.downcase.include? ("csstudent")
          message = Message.new
          message.id = id
          #Grab subject that doesn't include csstudent and other tags
          message.subject = addTag(message, mail.subject)
          message.tag_list.sort!
          message.author = mail.from[0]
          message.content = getContent(mail)
          message.created_at = mail.date.to_s
          # Makes it so both have the same time format
          message.updated_at = Time.now.strftime("%Y-%m-%d %H:%M")
          message.save
          id += 1
#        end
      end
    end
  end
  

# This is for getting content for a mail  
  def getContent(mail)
#Converts some characters back to what they should be
    text = mail.text_part.body.decoded
    text.encode!("UTF-8", "Windows-1250")
    text.gsub!("â€™", "\'") #fixes apostrophe bug for parsing
    text.gsub!(/(\n){3,}/, "\n\n")  #remove excess newlines
    return text
  end
  
  # Add tags using subject
  # Grabs tags between brackets and trims the subject
  # Example format: [csstundets][Tag1][Tag2] This is an example
  def addTag(message, mail)
    subject = mail.sub("[csstudents]", "") #delete csstudents
    subjectLow = subject.downcase
    tags = /[\[].*[\]]/.match(subjectLow)
    if !tags.nil?
      tags = tags[0][1..-2]
      tagArr = tags.split('][') #create array of tags
      tagArr.each do |tag|
       if tag.include? "talk"
          message.tag_list.add("Talk")
        elsif tag.include? "cs table"
          message.tag_list.add("CS Table")
        elsif tag.include? "internship"
          message.tag_list.add("Internship")
        elsif tag.include? "job"
          message.tag_list.add("Job")
        elsif tag.include? "offcampus"
          message.tag_list.add("Off Campus")
        elsif tag.include? "candidate"
          message.tag_list.add("Candidate")
        elsif tag.include? "sepc"
          message.tag_list.add("SEPC")
        else
          message.tag_list.add("Misc.")
       end
      end
    else
      message.tag_list.add("Misc.") #if no tags are attached
    end
    subject.sub!(/[\[].*[\]]/, "") #removes tags from subject
    subject.strip! #removes whitespaces
    return subject.squeeze(" ") #removes extra whitespace from subject
  end
end