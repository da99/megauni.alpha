
use(Cuba.new {
  on get, root do
    res.write(
      mu(:FILE_INDEX) { File.read('Public/index.html') }
    )
  end
})


use(Cuba.new {
  on('raise-error-for-test') { something }
}) if ENV['IS_DEV']

