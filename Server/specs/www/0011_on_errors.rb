
describe "Custom 404" do

  it "displays link to egg timers" do
    get "/missing-page"
    http_code.should == 404
    html.should.match %r!"/my-egg-timer">!
    html.should.match %r!"/busy-noise">!
  end

  it "displays location" do
    get "/missing-page"
    http_code.should == 404
    html.should.match %r!document.writeln\(window.location.href\);!
  end

end # === 404

describe "Custom 500" do

  it "displays location" do
    get "/raise-error-for-test"
    last_response.status.should == 500
    last_response.body.should.match %r!document.writeln\(window.location.href\);!
  end

end # === Custom 500

