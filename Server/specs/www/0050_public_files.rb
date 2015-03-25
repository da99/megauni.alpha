
describe "public files" do

  it "retrieves /busy-noise swf with content-type: application/x-shockwave-flash" do
    get(
      "/busy-noise/media/button_player/button/musicplayer_f6.swf" +
      "?&autoplay=true&repeat=true&song_url=http://megauni.s3.amazonaws.com/beeping.mp3"
    )
    content_type.should == "application/x-shockwave-flash"
  end

  it "retrieves /busy-noise js with content-type: application/javascript" do
    get("/busy-noise/javascripts/chicken.js?v122f83805")
    content_type.should == "application/javascript"
  end

  it "retrieves /my-egg-timer js with content-type: application/javascript" do
    get "http://localhost:4567/my-egg-timer/javascripts/mootools.js?v=07.04.2009.07.15.04"
    content_type.should == "application/javascript"
  end

end # === describe "public files"
