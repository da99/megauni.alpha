require 'tmail'
require 'net/smtp'

class Pony
  def self.mail opts
    valid_keys = %w{ to from subject body via via_options }.map(&:to_sym)
    invalid_keys = opts.keys - valid_keys
    raise ArgumentError, "Invalid options: #{invalid_keys.inspect}" unless invalid_keys.empty?

    msg = TMail::Mail.new
    msg.to = opts[:to]
    msg.from = opts[:from]
    msg.subject = opts[:subject]
    msg.body = opts[:body]
    msg.date = Time.now.utc
    msg.mime_version = '1.0'
    msg.set_content_type 'text', 'plain', 'charset'=>'UTF-8', 'format'=>'flowed'

    Net::SMTP.start(Uni_App::SMTP_ADDRESS, 25, ::Uni_App::SMTP_DOMAIN, ::Uni_App::SMTP_USER_NAME, Uni_App::SMTP_PASSWORD, Uni_App::SMTP_AUTHENTICATION) do |smtp|
      smtp.send_message msg.to_s, msg.from, msg.to
    end

  end
  
end
