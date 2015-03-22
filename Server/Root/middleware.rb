
use(
  Cuba.new {
    on get, root do
      res.write mu(:FILE_INDEX)
    end

    if ENV['IS_DEV']
      on('raise-error-for-test') { something }
    end
  }
) # === use


mu(:FILE_INDEX) {
  WWW_App.new {
    title { 'Almost there...' }
    p { 'Not ready yet.' }
  }.to_html
}
