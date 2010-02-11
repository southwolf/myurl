class Mail < ActionMailer::Base
  def urge(addressinfo)
    @subject = '友通催报邮件'
    @recipients = addressinfo.email
    @from = 'zcgl001@163.com'
    @headers = {}
    @body = {}
  end
end
